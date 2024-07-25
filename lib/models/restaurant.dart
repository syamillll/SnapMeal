import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  // Properties
  final String id;
  final String name;
  final double serviceCharge;

  // Constructor
  Restaurant({
    required this.id,
    required this.name,
    required this.serviceCharge,
  });

  // Convert a Firestore document to an instance
  factory Restaurant.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Restaurant(
      id: doc.id,
      name: doc['name'],
      serviceCharge: doc['serviceCharge'],
    );
  }

  // Convert an instance to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'serviceCharge': serviceCharge,
    };
  }

}
