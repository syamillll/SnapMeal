import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapmeal/models/favorite.dart';
import 'package:snapmeal/models/item.dart';
import 'dart:developer' as dev;

import 'package:snapmeal/models/staff.dart';

class AuthService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _currentUserName = '';
  String _currentUserRole = '';
  bool _isVerified = false;
  List<Favorite> _favorites = [];

  AuthService() {
    init();
  }

  String get userId => _auth.currentUser?.uid ?? '';
  String get currentUserName => _currentUserName;
  String get currentUserRole => _currentUserRole;
  bool get isVerified => _isVerified;
  List<Favorite> get favorites => _favorites;

  Future<void> init() async {
    if (_auth.currentUser != null) {
      await getCurrentUserInfo();
      // await isUserVerified();
      await _fetchFavorites();
    }
  }

  Future<void> registerUser(String name, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      await user!.updateDisplayName(name);
      _currentUserName = name;
      _isVerified = false;

      await _firestore.collection('staffs').doc(user.uid).set({
        'name': name,
        'email': email,
        'role': 'staff',
        'isVerified': false,
      });

      notifyListeners();
    } catch (e) {
      dev.log('Error registering user: $e');
      rethrow;
    }
  }

  Future<User?> logInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      _currentUserName = 'Guest';
      _currentUserRole = 'guest';
      _isVerified = false;
      await _fetchFavorites();
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      dev.log('Error logging in anonymously: $e');
      return null;
    }
  }

  Future<User?> logInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential =
                              await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await init();
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      dev.log('Error logging in with email: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    _favorites.clear();
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> getCurrentUserInfo() async {
    if (userId.isNotEmpty) {
      DocumentSnapshot snapshot = await _firestore.collection('staffs').doc(userId).get();
      if (snapshot.exists) {
        _currentUserName = (snapshot.data() as Map<String, dynamic>)['name'];
        _currentUserRole = (snapshot.data() as Map<String, dynamic>)['role'];
        _isVerified = (snapshot.data() as Map<String, dynamic>)['isVerified'];
      } else {
        _currentUserName = 'Guest';
        _currentUserRole = 'guest';
        _isVerified = false;
      }
    }
  }

  // Future<void> isUserVerified() async {
  //   if (userId.isNotEmpty) {
  //     DocumentSnapshot snapshot = await _firestore.collection('staffs').doc(userId).get();
  //     _isVerified = (snapshot.data() as Map<String, dynamic>)['isVerified'];
  //   }
  // }

  Stream<List<Staff>> get unverifiedUsers {
    return _firestore
        .collection('staffs')
        .where('isVerified', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Staff.fromDocumentSnapshot(doc)).toList());
  }

  Future<void> verifyUser(String userId) async {
    await _firestore.collection('staffs').doc(userId).update({'isVerified': true});
    notifyListeners();
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('staffs').doc(userId).delete();
    notifyListeners();
  }

  Future<void> updateUserProfile(String name, String? password) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await user.updateDisplayName(name);

        if (password != null && password.isNotEmpty) {
          await user.updatePassword(password);
        }

        await _firestore.collection('staffs').doc(user.uid).update({
          'name': name,
        });

        _currentUserName = name;
        notifyListeners();
      }
    } catch (e) {
      dev.log('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> _fetchFavorites() async {
    if (userId.isNotEmpty) {
      try {
        final snapshot = await _firestore.collection('favorites').doc(userId).collection('items').get();
        _favorites = snapshot.docs.map((doc) => Favorite.fromMap(doc.data())).toList();
        notifyListeners();
      } catch (error) {
        dev.log('Error fetching favorites: $error');
      }
    }
  }

  Future<List<Item>> getFavoriteItems() async {
    try {
      List<Item> favoriteItems = [];
      for (var favorite in _favorites) {
        final itemSnapshot = await _firestore.collection('items').doc(favorite.itemId).get();
        if (itemSnapshot.exists) {
          favoriteItems.add(Item.fromDocumentSnapshot(itemSnapshot));
        }
      }
      return favoriteItems;
    } catch (error) {
      dev.log('Error fetching favorite items: $error');
      rethrow;
    }
  }

  // Store favorite item to database
  Future<void> addFavorite(Favorite favorite) async {
    try {
      await _firestore.collection('favorites')
                      .doc(userId)
                      .collection('items')
                      .doc(favorite.itemId)
                      .set(favorite.toMap());
      _favorites.add(favorite);
      notifyListeners();
    } catch (error) {
      dev.log('Error adding favorite: $error');
      rethrow;
    }
  }

  Future<void> removeFavorite(String itemId) async {
    try {
      await _firestore.collection('favorites').doc(userId).collection('items').doc(itemId).delete();
      _favorites.removeWhere((fav) => fav.itemId == itemId);
      notifyListeners();
    } catch (error) {
      dev.log('Error removing favorite: $error');
      rethrow;
    }
  }
}
