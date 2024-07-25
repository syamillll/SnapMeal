import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  // Properties
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor
  Category({
    required this.id, 
    required this.name, 
    required this.createdAt,
    required this.updatedAt,
    });

  // Factory method to convert a Firestore document to an instance
  factory Category.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  // Method to convert an instance to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

}
