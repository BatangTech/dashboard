import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AgeChart extends StatelessWidget {
  const AgeChart({super.key});

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

        // ✅ แบ่งอายุเป็น 4 หมวดหมู่
        Map<String, int> ageGroups = {
          "0-18": 0,
          "19-35": 0,
          "36-50": 0,
          "51+": 0,
        };

        for (var doc in snapshot.data!.docs) {
          var personalData = doc.data() as Map<String, dynamic>;

          if (personalData.containsKey("age") && personalData["age"] is int) {
            int age = personalData["age"];

            // ✅ แบ่งหมวดหมู่อายุ
            if (age <= 18) {
              ageGroups["0-18"] = ageGroups["0-18"]! + 1;
            } else if (age <= 35) {
              ageGroups["19-35"] = ageGroups["19-35"]! + 1;
            } else if (age <= 50) {
              ageGroups["36-50"] = ageGroups["36-50"]! + 1;
            } else {
              ageGroups["51+"] = ageGroups["51+"]! + 1;
            }
          }
        }

        List<String> ageRanges = ageGroups.keys.toList();
        List<Color> barColors = [Colors.blue, Colors.orange, Colors.green, Colors.red];

        return SizedBox(
          child: Card(
            color: Colors.white, 
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Age Distribution",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 8, 64, 110),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 250, // ขนาดของกราฟ
                    child: BarChart(
                      BarChartData(
                        barGroups: ageGroups.entries.map((entry) {
                          int index = ageRanges.indexOf(entry.key);
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
                                return index < ageRanges.length
                                    ? Text(ageRanges[index], style: TextStyle(fontSize: 12))
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
          ),
        );
      },
    );
  }
}
