// combind card in caution and NCDs togather
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// start thr caution card 
class CautionInfoCard extends StatelessWidget {
  const CautionInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity, // ให้ Container ขยายความกว้างเต็มที่
        height: 300, // กำหนดความสูงของกล่อง
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Health Status Trends",
              style: TextStyle(
                fontFamily: 'Nunito', // กำหนดฟอนต์
                fontSize: 25, // ปรับขนาดตัวอักษร
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            Text(
              "แนวโน้มสถานะสุขภาพ",
              style: TextStyle(
                fontFamily: 'Bai_Jamjuree', // กำหนดฟอนต์
                fontSize: 16, // ปรับขนาดตัวอักษรให้เล็กลง
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('personal')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text("No data available",
                        style: TextStyle(color: Colors.grey.shade600)),
                  );
                }

                var docs = snapshot.data!.docs;

                // ลำดับเดือนที่ถูกต้อง
                List<String> monthOrder = [
                  "Jan",
                  "Feb",
                  "Mar",
                  "Apr",
                  "May",
                  "Jun",
                  "Jul",
                  "Aug",
                  "Sep",
                  "Oct",
                  "Nov",
                  "Dec"
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

                List<String> sortedMonths = monthOrder
                    .where((m) =>
                        stableCounts.containsKey(m) ||
                        criticalCounts.containsKey(m))
                    .toList();

                return SizedBox(
                  height: 180, // ความสูงของกราฟ
                  width: double.infinity, // ให้กราฟขยายความกว้างเต็มที่
                  child: LineChart(
                    LineChartData(
                      maxY: null, // ไม่กำหนดค่าสูงสุดของแกน Y
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              );
                            },
                            interval: 1,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < sortedMonths.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    sortedMonths[value.toInt()],
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                            interval: 1,
                          ),
                        ),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false), // ปิดเส้นกริด
                      borderData: FlBorderData(show: false), // ปิดเส้นขอบ
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (LineBarSpot touchedSpot) => Colors
                              .blueGrey
                              .withOpacity(0.8), // กำหนดสีพื้นหลังของ Tooltip
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              // ตรวจสอบว่าเป็นเส้น Stable หรือ Critical
                              String status = spot.barIndex == 0 ? "Stable" : "Critical";
                              return LineTooltipItem(
                                '$status: ${spot.y.toInt()} คน',
                                TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                      ),
                      lineBarsData: [
                        // เส้น Green Zone (Stable)
                        LineChartBarData(
                          spots: List.generate(
                            sortedMonths.length,
                            (index) => FlSpot(
                                index.toDouble(),
                                (stableCounts[sortedMonths[index]] ?? 0)
                                    .toDouble()),
                          ),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.green.withOpacity(0.1),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 5, // ปรับขนาดจุดให้ใหญ่ขึ้น
                                color: Colors.green,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        ),
                        // เส้น Red Zone (Critical)
                        LineChartBarData(
                          spots: List.generate(
                            sortedMonths.length,
                            (index) => FlSpot(
                                index.toDouble(),
                                (criticalCounts[sortedMonths[index]] ?? 0)
                                    .toDouble()),
                          ),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.red.withOpacity(0.1),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 5, // ปรับขนาดจุดให้ใหญ่ขึ้น
                                color: Colors.red,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        ),
                      ],
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

// start the NCDs card
class NCDsChart extends StatelessWidget {
  const NCDsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collectionGroup('personal').snapshots(),
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

          if (personalData.containsKey("diseases") &&
              personalData["diseases"] is String) {
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
        int totalPatients =
            sortedDiseases.fold(0, (sum, entry) => sum + entry.value);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: double.infinity, // ให้ Container ขยายความกว้างเต็มที่
            height: 300, // กำหนดความสูงของกล่อง
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
                  "NCDs Disease Tracking",
                  style: TextStyle(
                    fontFamily: 'Nunito', // กำหนดฟอนต์
                    fontSize: 25, // ปรับขนาดตัวอักษรให้เล็กลง
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),

                // จำนวนผู้ป่วยทั้งหมด
                Text(
                  "จำนวนผู้ป่วยทั้งหมด: $totalPatients คน",
                  style: TextStyle(
                    fontFamily: 'Bai_Jamjuree', // กำหนดฟอนต์
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
                            fontSize: 18, // ปรับขนาดตัวอักษรให้เล็กลง
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
        );
      },
    );
  }

   // ฟังก์ชันคืนค่า Icon ตามโรค
  Icon _getIconForDisease(String disease) {
    switch (disease) {
      case "Cancer":
        return Icon(Icons.local_hospital, color: Colors.red[400]);
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
