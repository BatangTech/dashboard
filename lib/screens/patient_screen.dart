import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widgets/header/patient_list_header.dart';
import '../widgets/sidebar.dart';

class PatientScreen extends StatefulWidget {
  static const String routeName = "/patient";
  const PatientScreen({super.key});

  @override
  _PatientScreenState createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // เพิ่มตัวแปรเพื่อติดตามหน้าปัจจุบัน

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(), // Sidebar ติดขอบซ้ายของหน้าจอ
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16), // เว้นขอบเฉพาะเนื้อหาฝั่งขวา
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PatientListHeader(
                    status: _currentPage == 0 ? "Critical" : "Stable", // ส่งค่าสถานะตามหน้าปัจจุบัน
                  ),
                  SizedBox(height: 20),

                  // PageView สำหรับสลับระหว่าง "Critical" & "Stable"
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index; // อัปเดตหน้าปัจจุบันเมื่อผู้ใช้เลื่อน
                        });
                      },
                      children: [
                        _buildPatientListPage("Critical"),
                        _buildPatientListPage("Stable"),
                      ],
                    ),
                  ),

                  // SmoothPageIndicator แสดงจุดด้านล่าง
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center, // จัดให้อยู่ตรงกลาง
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 2,
                        effect: ExpandingDotsEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor:Colors.indigo ,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientListPage(String statusFilter) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Patient List - $statusFilter",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 8, 64, 110)),
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
                  child: Text("Date and Time", style: TextStyle(fontWeight: FontWeight.bold , color: Color.fromARGB(255, 8, 64, 110))),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('patients').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text("Error loading patient data");
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text("No patients available");
                  }

                  var patients = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      var doc = patients[index];

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('patients')
                            .doc(doc.id)
                            .collection('personal')
                            .snapshots(),
                        builder: (context, personalSnapshot) {
                          if (personalSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (personalSnapshot.hasError) {
                            return Text("Error loading personal data");
                          }
                          if (!personalSnapshot.hasData || personalSnapshot.data!.docs.isEmpty) {
                            return SizedBox();
                          }

                          var personalData = personalSnapshot.data!.docs
                              .map((doc) => doc.data() as Map<String, dynamic>)
                              .where((data) => data['status'] == statusFilter)
                              .toList();

                          if (personalData.isEmpty) {
                            return Center(child: Text("No $statusFilter patients available"));
                          }

                          return Column(
                            children: personalData.map((data) {
                              return Container(
                                width: double.infinity,
                                height: 40,
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(flex: 2, child: Text(data['name'] ?? 'Unknown')),
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Icon(
                                            data['status'] == "Stable" ? Icons.check_circle : Icons.cancel,
                                            color: data['status'] == "Stable" ? Colors.green : Colors.red,
                                          ),
                                          SizedBox(width: 5),
                                          Text(data['status'] ?? 'No status'),
                                        ],
                                      ),
                                    ),
                                    Expanded(flex: 1, child:Text(data['date']?.toDate().toString() ?? 'No date')),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}