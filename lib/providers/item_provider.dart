import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapmeal/models/item.dart';

class ItemProvider extends ChangeNotifier {
  // Properties
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'items';
  final bool _isLoading = false;
  List<Item> _items = [];

  // Getters
  String get collectionName => _collectionName;
  List<Item> get items => _items;
  bool get isLoading => _isLoading;

  // Constructor
  ItemProvider() {
    fetchItems();
  }

  // Fetch items
  Future<void> fetchItems() async {
    final snapshot = await _firestore
                            .collection(_collectionName).get();
    _items = snapshot.docs.map((doc) 
                    => Item.fromDocumentSnapshot(doc)).toList();
    notifyListeners();
  }

  // Get items by category
  List<Item> getItemsByCategory(String categoryId) {
    return _items.where((item) 
                  => item.category == categoryId).toList();
  }

  // Add item
  Future<void> addItem(Item item) async {
    final docRef =
        await _firestore.collection(_collectionName)
                        .add(item.toFirestore());
    item.id = docRef.id;
    _items.add(item);
    notifyListeners();
  }

  // Upload image on firebase storage
  Future<String> uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
                    .child('item_images/${DateTime.now()}.jpg');
      await imageRef.putFile(image);

      // Return the image URL
      return await imageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  // Update item
  Future<void> updateItem(Item updatedItem) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(updatedItem.id)
          .update(updatedItem.toFirestore());
      int index = _items.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _items[index] = updatedItem;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // Delete item
  Future<void> deleteItem(String itemId) async {
    try {
      var itemsBatch = _firestore.batch();

      // Delete item from main collection
      itemsBatch.delete(_firestore.collection(_collectionName)
                                  .doc(itemId));

      // Get all cart items with the same item id 
      // and delete them
      var queryCartItems = await _firestore
                          .collectionGroup('cart_items').get();
      for (var doc in queryCartItems.docs) {
        if (doc['itemId'] == itemId) {
          itemsBatch.delete(doc.reference);
        }
      }

      // Commit the batched delete operation
      await itemsBatch.commit();

      // Update local items list
      _items.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  // Check if item with label id exists
  bool isItemExists(String labelId) {
    return _items.any((item) => item.labelId == labelId);
  }

  // Get item by label id
  Item getItemByLabelId(String? labelId) {
    return _items.firstWhere((item) => item.labelId == labelId);
  }
}
