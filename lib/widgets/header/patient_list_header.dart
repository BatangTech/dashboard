import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientListHeader extends StatelessWidget {
  final String status; // เพิ่มพารามิเตอร์ status
  const PatientListHeader({super.key, required this.status}); // รับพารามิเตอร์ status

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 150, child: _buildStatusCard(status)), // ใช้ status เพื่อสร้าง Card
        const SizedBox(width: 16),
        SizedBox(width: 750, child: _buildSummaryCard()),
        Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.account_circle),
                onPressed: () {},
              ),
              Text('Profile', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String status) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.only(top: 10, left: 16, right: 16),
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              status == "Critical" ? Icons.cancel : Icons.check_circle,
              color: status == "Critical" ? Colors.red : Colors.green,
              size: 50,
            ),
            const SizedBox(height: 5),
            Text(
              status,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 8, 64, 110),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('patients').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorCard();
        }

        var patientDocs = snapshot.data!.docs;

        return FutureBuilder<List<QuerySnapshot>>(
          future: Future.wait(patientDocs.map((doc) {
            return FirebaseFirestore.instance
                .collection('patients')
                .doc(doc.id)
                .collection('personal')
                .get();
          }).toList()),
          builder: (context, personalSnapshots) {
            if (personalSnapshots.connectionState == ConnectionState.waiting) {
              return _buildLoadingCard();
            }
            if (personalSnapshots.hasError) {
              return _buildErrorCard();
            }

            int criticalCount = 0;
            int stableCount = 0;

            for (var personalSnapshot in personalSnapshots.data!) {
              for (var doc in personalSnapshot.docs) {
                var data = doc.data() as Map<String, dynamic>;
                if (data['status'] == "Critical") {
                  criticalCount++;
                } else if (data['status'] == "Stable") {
                  stableCount++;
                }
              }
            }

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.only(top: 15, left: 16, right: 16),
              color: Colors.white,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color: Color.fromARGB(255, 8, 64, 110)),
                    ),
                    Divider(),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusBox(Icons.cancel, "Critical", criticalCount, Colors.red),
                        _buildStatusBox(Icons.check_circle, "Stable", stableCount, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBox(IconData icon, String label, int count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
        Text(
          "$count",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(child: Text("Error loading data")),
      ),
    );
  }
}