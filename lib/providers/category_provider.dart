import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapmeal/models/category.dart';

class CategoryProvider with ChangeNotifier {
  // Properties
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'categories';
  List<Category> _categories = [];
  bool _isLoading = false;

  // Getters
  String get collectionName => _collectionName;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  // Constructor
  CategoryProvider() {
    fetchCategories();
  }

  // Fetch categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    // Get categories from database and order by updated datetime
    QuerySnapshot snapshot = await _firestore
        .collection(collectionName)
        .orderBy('updated_at', descending: true)
        .get();

    // Convert documents to category objects
    _categories = snapshot.docs.map((doc) 
                => Category.fromDocumentSnapshot(doc)).toList();
    
    _isLoading = false;
    notifyListeners();
  }

  // Add category to database
  Future<void> addCategory(String name) async {
    CollectionReference categories = 
                      _firestore.collection(collectionName);
    await categories.add({
      'name': name,
      'created_at': Timestamp.now(),
      'updated_at': Timestamp.now(),
    });

    // Fetch categories again to update the list
    fetchCategories();
  }

  // Update category
  Future<void> updateCategory(String id, String name) async {
    CollectionReference categories = 
                      _firestore.collection(collectionName);
    await categories.doc(id).update({
      'name': name,
      'updated_at': Timestamp.now(),
    });
    fetchCategories();
  }

  // Delete category
  Future<void> deleteCategory(String id) async {
    CollectionReference categories = 
                        _firestore.collection(collectionName);
    await categories.doc(id).delete();

    // Delete items and cart items under the category
    QuerySnapshot items = await _firestore.collection('items').where('category', isEqualTo: id).get();
    var queryCartItems = await _firestore.collectionGroup('cart_items').get();
    for (var itemDoc in items.docs) {
      itemDoc.reference.delete();
      // Get all cart items with the same item id and delete them
      for (var cartDoc in queryCartItems.docs) {
        if (cartDoc['itemId'] == itemDoc.id) {
          cartDoc.reference.delete();
        }
      }
    }


    fetchCategories();
  }
}
