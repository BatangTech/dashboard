import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NCDsChart extends StatelessWidget {
  const NCDsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('personal').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading data"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No data available"));
        }

        // นับจำนวนคนที่เป็นโรค
        Map<String, int> diseaseCount = {
          "Cancer": 0,
          "Hypertension": 0,
          "Diabetes": 0,
          "Obesity": 0,
          "CVD": 0,
        };

        for (var doc in snapshot.data!.docs) {
          var personalData = doc.data() as Map<String, dynamic>;

          if (personalData.containsKey("diseases") && personalData["diseases"] is String) {
            String disease = personalData["diseases"];
            if (diseaseCount.containsKey(disease)) {
              diseaseCount[disease] = diseaseCount[disease]! + 1;
            }
          }
        }

        // เรียงลำดับจากมากไปน้อย
        var sortedDiseases = diseaseCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // คำนวณจำนวนผู้ป่วยรวม
        int totalPatients = sortedDiseases.fold(0, (sum, entry) => sum + entry.value);

        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: Center( // จัดวางกล่องให้อยู่กึ่งกลาง
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 300, // กำหนดความกว้างของกล่องให้สั้นลง
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // หัวข้อ "NCDs Disease Tracking"
                    Text(
                      "Disease Tracking",
                      style: TextStyle(
                        fontFamily: 'Nunito', // กำหนดฟอนต์r
                        fontSize: 25, // ปรับขนาดตัวอักษรให้เล็กลง
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    
                    Text(
                      "จำนวนผู้ป่วยทั้งหมด: $totalPatients คน",
                      style: TextStyle(
                        fontSize: 16, // ปรับขนาดตัวอักษรให้เล็กลง
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 20), // ลดระยะห่าง
                    // รายละเอียดโรค
                    ...sortedDiseases.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0), // ลดระยะห่าง
                        child: Row(
                          children: [
                            // แสดงไอคอนแทนสี
                            _getIconForDisease(entry.key),
                            SizedBox(width: 8), // ลดระยะห่าง
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 20, // ปรับขนาดตัวอักษรให้เล็กลง
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            Spacer(),
                            Text(
                              '${entry.value} คน',
                              style: TextStyle(
                                fontSize: 16, // ปรับขนาดตัวอักษรให้เล็กลง
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ฟังก์ชันคืนค่า Icon ตามโรค
  Icon _getIconForDisease(String disease) {
    switch (disease) {
      case "Cancer":
        return Icon(Icons.coronavirus_rounded, color: Colors.red[400]);
      case "Hypertension":
        return Icon(Icons.monitor_heart, color: Colors.blue[400]);
      case "Diabetes":
        return Icon(Icons.bloodtype, color: Colors.green[400]);
      case "Obesity":
        return Icon(Icons.fastfood, color: Colors.orange[400]);
      case "CVD":
        return Icon(Icons.favorite, color: Colors.purple[400]);
      default:
        return Icon(Icons.medical_services, color: Colors.grey[400]);
    }
  }
}