import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapmeal/models/cart_item.dart';
import 'package:snapmeal/models/item.dart';
import 'dart:developer' as dev;

class CartProvider with ChangeNotifier {
  String? userId;
  List<CartItem> _cartItems = [];
  double serviceCharge = 0;
  String _invoiceId = '';

  CartProvider() {
    _initialize();
  }

  List<CartItem> get cartItems => _cartItems;
  double get serviceChargeAmount => serviceCharge;
  String get invoiceId => _invoiceId;

  Future<void> _initialize() async {
    await fetchServiceCharge();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      userId = user?.uid;
      if (userId != null) {
        loadCartItems();
      } else {
        _cartItems.clear();
        notifyListeners();
      }
    });
  }

  Future<void> fetchServiceCharge() async {
    try {
      final restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc('restaurant_id')
          .get();
      if (restaurantDoc.exists) {
        serviceCharge = restaurantDoc['serviceCharge'];
      } else {
        serviceCharge = 0.0;
      }
    } catch (e) {
      dev.log('Error fetching service charge: $e');
      serviceCharge = 0.0;
    }
  }

  Future<void> loadCartItems() async {
    if (userId == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('cart_items')
          .get();
      _cartItems = snapshot.docs.map((doc) => CartItem.fromDocumentSnapshot(doc)).toList();
      notifyListeners();
    } catch (e) {
      dev.log('Error loading cart items: $e');
    }
  }

  Future<Item?> fetchItem(String itemId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('items').doc(itemId).get();
      if (doc.exists) {
        return Item.fromDocumentSnapshot(doc);
      }
    } catch (e) {
      dev.log('Error fetching item: $e');
    }
    return null;
  }

  // Upload image on firebase storage
  Future<String> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('cart_images/${DateTime.now()}.jpg');
      await imageRef.putFile(image);
      return await imageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }

  Future<void> addToCart(Item item, String selectedOption, int itemQuantity, File? cartImage) async {
    if (userId == null) return;

    final existingItemIndex = _cartItems.indexWhere((cartItem) =>
        cartItem.itemId == item.id && cartItem.selectedOption == selectedOption);

    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity += itemQuantity;
      await _updateCartItem(_cartItems[existingItemIndex]);
    } else {
      // Use the item image if no cart image is provided
      String imageUrl = item.image;
      if (cartImage != null) {
        imageUrl = await _uploadImage(cartImage);
      }

      // Create a new cart item
      final newCartItem = CartItem(
        id: FirebaseFirestore.instance.collection('carts').doc().id,
        itemId: item.id,
        userId: userId!,
        image: imageUrl,
        price: item.price,
        selectedOption: selectedOption,
        quantity: itemQuantity,
      );

      _cartItems.add(newCartItem);
      await _saveCartItem(newCartItem);
    }

    notifyListeners();
  }

  Future<void> _updateCartItem(CartItem cartItem) async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('cart_items')
          .doc(cartItem.id)
          .update({'quantity': cartItem.quantity});
    } catch (e) {
      dev.log('Error updating cart item: $e');
    }
  }

  Future<void> _saveCartItem(CartItem cartItem) async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('cart_items')
          .doc(cartItem.id)
          .set(cartItem.toMap());
    } catch (e) {
      dev.log('Error saving cart item: $e');
    }
  }

  Future<void> increaseQuantity(CartItem cartItem) async {
    if (userId == null) return;

    final index = _cartItems.indexOf(cartItem);
    if (index != -1) {
      _cartItems[index].quantity++;
      await _updateCartItem(_cartItems[index]);
      notifyListeners();
    }
  }

  Future<void> decreaseQuantity(CartItem cartItem) async {
    if (userId == null) return;

    final index = _cartItems.indexOf(cartItem);
    if (index != -1 && _cartItems[index].quantity > 1) {
      _cartItems[index].quantity--;
      await _updateCartItem(_cartItems[index]);
      notifyListeners();
    }
  }

  Future<void> removeItem(CartItem cartItem) async {
    if (userId == null) return;

    _cartItems.remove(cartItem);
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('cart_items')
          .doc(cartItem.id)
          .delete();
      notifyListeners();
    } catch (e) {
      dev.log('Error removing cart item: $e');
    }
  }

  Future<void> removeAllItems() async {
    if (userId == null) return;

    _cartItems.clear();
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .collection('cart_items')
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });
      notifyListeners();
    } catch (e) {
      dev.log('Error removing all cart items: $e');
    }
  }

  double getSubtotal() {
    return _cartItems.fold(0.0, (total, cartItem) 
          => total + cartItem.price * cartItem.quantity);
  }

  double getTotalPrice() {
    double subtotal = getSubtotal();
    return subtotal + (subtotal * serviceCharge / 100);
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<void> saveInvoice(String restaurantName
                          ,String tableNumber) async {

    // Get the subtotal, total price, and current date time
    double subtotal = getSubtotal();
    double total = getTotalPrice();
    DateTime dateTime = DateTime.now();

    try {
      // Save the invoice to Firestore
      DocumentReference invoiceRef = await FirebaseFirestore
                            .instance.collection('invoices').add({
        'restaurantName': restaurantName,
        'tableNumber': tableNumber,
        'dateTime': dateTime,
        'items': _cartItems.map((item) => item.toMap()).toList(),
        'subtotal': subtotal,
        'serviceCharge': serviceCharge,
        'total': total,
      });
      _invoiceId = invoiceRef.id;
      notifyListeners();
    } catch (e) {
      dev.log('Error saving invoice: $e');
    }
  }

  Future<DocumentSnapshot> fetchInvoice(String invoiceId) async {
    try {
      return await FirebaseFirestore.instance.collection('invoices').doc(invoiceId).get();
    } catch (e) {
      dev.log('Error fetching invoice: $e');
      rethrow;
    }
  }
}
