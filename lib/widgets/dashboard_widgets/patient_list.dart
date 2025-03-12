import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // นำเข้า DateFormat

class PatientList extends StatelessWidget {
  const PatientList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250, // ✅ ปรับขนาดให้เท่ากับ CautionInfoCard และ NCDsChart
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('patients').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildCard(
              title: "Patient List",
              content: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return _buildCard(
              title: "Patient List",
              content: Text("Error loading data"),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildCard(
              title: "Patient List",
              content: Text("No data available"),
            );
          }

          var patients = snapshot.data!.docs.map((doc) {
            return FirebaseFirestore.instance
                .collection('patients')
                .doc(doc.id)
                .collection('personal')
                .snapshots();
          }).toList();

          return _buildCard(
            title: "Patient List",
            content: SizedBox(
              height: 150, // ✅ คงขนาดเนื้อหาให้เหมาะสม
              child: SingleChildScrollView(
                child: Column(
                  children: patients.take(6).map((patientStream) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: patientStream,
                      builder: (context, patientSnapshot) {
                        if (patientSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (patientSnapshot.hasError) {
                          return Text("Error loading personal data");
                        }
                        if (!patientSnapshot.hasData || patientSnapshot.data!.docs.isEmpty) {
                          return Text("No personal data available");
                        }

                        var personalData = patientSnapshot.data!.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();

                        return Column(
                          children: personalData.map((data) {
                            return Container(
                              width: double.infinity,
                              height: 40, // ✅ ปรับขนาดแถวให้อยู่ในกรอบ 250px
                              padding: EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(data['name'] ?? 'Unknown'),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        Icon(
                                          data['status'] == "Stable"
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: data['status'] == "Stable"
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                        SizedBox(width: 5),
                                        Text(data['status'] ?? 'No status'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      data['date'] != null
                                          ? DateFormat('dd-MM-yyyy').format(  //dd-MM-yyyy
                                              (data['date'] as Timestamp).toDate(),
                                            )
                                          : 'No date',
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required Widget content}) {
    return Card(
      color: Colors.white, 
      elevation: 3, // ✅ ลด elevation ให้ตรงกัน
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 8, 64, 110),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold , color: Color.fromARGB(255, 8, 64, 110))),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold , color: Color.fromARGB(255, 8, 64, 110))),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold , color: Color.fromARGB(255, 8, 64, 110))),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: content, // ✅ ทำให้ content ขยายเต็มที่
            ),
          ],
        ),
      ),
    );
  }
}
