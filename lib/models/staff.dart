import 'package:cloud_firestore/cloud_firestore.dart';

class Staff {
  // Properties
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isVerified;

  // Constructor
  Staff({
    required this.id, 
    required this.name, 
    required this.email, 
    required this.role, 
    required this.isVerified, 
  });

  // Factory method to convert a Firestore document to an instance
  factory Staff.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Staff(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      role: data['role'],
      isVerified: data['isVerified'],
    );
  }

  // Method to convert an instance to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'isVerified': isVerified,
    };
  }
}