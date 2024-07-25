import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapmeal/models/cart_item.dart';

class Invoice {
  // Properties
  final String id;
  final String restaurantName;
  final String tableNumber;
  final DateTime dateTime;
  final List<CartItem> items;
  final String total;
  final String subtotal;
  final String serviceCharge;

  // Constructor
  Invoice({
    required this.id, 
    required this.restaurantName, 
    required this.tableNumber,
    required this.dateTime,
    required this.items,
    required this.total,
    required this.subtotal,
    required this.serviceCharge,
  });

  // Factory method to convert a Firestore document to an instance
  factory Invoice.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      restaurantName: data['restaurantName'],
      tableNumber: data['tableNumber'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      items: List<CartItem>.from(data['items'].map((item) => CartItem.fromMap(item))),
      total: data['total'],
      subtotal: data['subtotal'],
      serviceCharge: data['serviceCharge'],
    );
  }

  // Method to convert an instance to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'restaurantName': restaurantName,
      'tableNumber': tableNumber,
      'dateTime': dateTime,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'subtotal': subtotal,
      'serviceCharge': serviceCharge,
    };
  }
}
