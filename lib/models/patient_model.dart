import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  String id;
  String name;
  String status;
  DateTime lastUpdated;

  Patient({required this.id, required this.name, required this.status, required this.lastUpdated});

  factory Patient.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Patient(
      id: doc.id,
      name: data['name'] ?? '',
      status: data['status'] ?? 'ปกติ',
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }
}
