import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String itemId;
  final String userId;
  final String image;
  final double price;
  final String selectedOption;
  int quantity;

  CartItem({
    required this.id,
    required this.itemId, 
    required this.userId, 
    required this.image, 
    required this.price, 
    required this.selectedOption, 
    required this.quantity,
  });

  // Create CartItem from JSON
  factory CartItem.fromMap(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      itemId: json['itemId'],
      userId: json['userId'],
      image: json['image'],
      price: json['price'],
      selectedOption: json['selectedOption'],
      quantity: json['quantity'],
    );
  }

  // Convert CartItem to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'userId': userId,
      'image': image,
      'price': price,
      'selectedOption': selectedOption,
      'quantity': quantity,
    };
  }

  // Factory method to convert a Firestore document to an instance
  factory CartItem.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CartItem(
      id: doc.id,
      itemId: data['itemId'],
      userId: data['userId'],
      image: data['image'],
      price: data['price'],
      selectedOption: data['selectedOption'],
      quantity: data['quantity'],
    );
  }
}
