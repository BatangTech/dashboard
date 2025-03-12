import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

        // 📌 ✅ แก้ให้รองรับ `String` แทน `List`
        Map<String, int> diseaseCount = {
          "Cancer": 0,
          "Hypertension": 0,
          "Diabetes": 0,
          "Obesity": 0,
          "CVD": 0,
        };

        for (var doc in snapshot.data!.docs) {
          var personalData = doc.data() as Map<String, dynamic>;

          // ✅ ตรวจสอบว่า `diseases` เป็น String
          if (personalData.containsKey("diseases") && personalData["diseases"] is String) {
            String disease = personalData["diseases"];

            // ✅ อัปเดตจำนวนโรค
            if (diseaseCount.containsKey(disease)) {
              diseaseCount[disease] = diseaseCount[disease]! + 1;
            }
          }
        }

        List<String> diseaseNames = diseaseCount.keys.toList();
        List<Color> barColors = [Colors.blue, Colors.orange, Colors.green, Colors.red, Colors.purple];

        return Card(
          color: Colors.white, 
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NCDs Disease Tracking",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold , color: const Color.fromARGB(255, 8, 64, 110)),
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 250, // ขนาดของกราฟ
                  child: BarChart(
                    BarChartData(
                      barGroups: diseaseCount.entries.map((entry) {
                        int index = diseaseNames.indexOf(entry.key);
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: barColors[index % barColors.length],
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              int index = value.toInt();
                              return index < diseaseNames.length
                                  ? Text(diseaseNames[index], style: TextStyle(fontSize: 12))
                                  : Container();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
