import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class CautionInfoCard extends StatelessWidget {
  const CautionInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // ✅ Padding ขอบของ Card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Caution",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 8, 64, 110),
              ),
            ),
            const SizedBox(height: 20), // ✅ เพิ่มช่องว่างระหว่าง "Caution" กับกราฟ
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collectionGroup('personal').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("No data available", style: TextStyle(color: Colors.grey.shade600)),
                  );
                }

                var docs = snapshot.data!.docs;

                // 🔹 ลำดับเดือนที่ถูกต้อง
                List<String> monthOrder = [
                  "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                ];

                Map<String, int> stableCounts = {};
                Map<String, int> criticalCounts = {};

                for (var doc in docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  if (data.containsKey('status') && data.containsKey('date')) {
                    var status = data['status'];
                    var date = (data['date'] as Timestamp).toDate();
                    String month = DateFormat('MMM').format(date);

                    if (status == "Stable") {
                      stableCounts[month] = (stableCounts[month] ?? 0) + 1;
                    } else if (status == "Critical") {
                      criticalCounts[month] = (criticalCounts[month] ?? 0) + 1;
                    }
                  }
                }

                List<String> sortedMonths = monthOrder.where((m) => stableCounts.containsKey(m) || criticalCounts.containsKey(m)).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16), // ✅ เพิ่ม padding ซ้ายขวาของกราฟ
                  child: SizedBox(
                    height: 220, // ✅ ขยายพื้นที่ด้านล่างนิดหน่อย
                    child: LineChart(
                      LineChartData(
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // ❌ ซ่อนตัวเลขแกน Y
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30, // ✅ ควบคุมระยะห่างด้านล่าง
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10), // ✅ ใช้ Padding แทน margin
                                    child: Text(
                                      sortedMonths[value.toInt()],
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                              interval: 1,
                            ),
                          ),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false), // ❌ ลบเส้นขอบออก
                        lineBarsData: [
                          // เส้น Green Zone (Stable)
                          LineChartBarData(
                            spots: List.generate(
                              sortedMonths.length,
                              (index) => FlSpot(index.toDouble(), (stableCounts[sortedMonths[index]] ?? 0).toDouble()),
                            ),
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: false),
                            dotData: FlDotData(show: true),
                          ),
                          // เส้น Red Zone (Critical)
                          LineChartBarData(
                            spots: List.generate(
                              sortedMonths.length,
                              (index) => FlSpot(index.toDouble(), (criticalCounts[sortedMonths[index]] ?? 0).toDouble()),
                            ),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: false),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
