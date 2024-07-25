import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  // Properties
  String id;
  final String image;
  final String name;
  final String description;
  final double price;
  final List<String> options;
  final bool availability;
  final String category;
  final String? labelId;

  // Constructor
  Item({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.options,
    required this.availability,
    required this.category,
    required this.labelId,
  });

  // Convert a Firestore document to an instance
  factory Item.fromDocumentSnapshot(DocumentSnapshot doc) {
    return Item(
      id: doc.id,
      image: doc['image'],
      name: doc['name'],
      description: doc['description'],
      price: doc['price'],
      options: List<String>.from(doc['options'] ?? []),
      availability: doc['availability'],
      category: doc['category'],
      labelId: doc['labelId'],
    );
  }

  // Convert an instance to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'image': image,
      'name': name,
      'description': description,
      'price': price,
      'options': options,
      'availability': availability,
      'category': category,
      'labelId': labelId,
    };
  }

}
