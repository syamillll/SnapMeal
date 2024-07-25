import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController serviceChargeController = TextEditingController();
  bool _isLoading = false;

  RestaurantProvider() {
    _fetchSettings();
  }

  bool get isLoading => _isLoading;

  Future<void> _fetchSettings() async {
    _isLoading = true;
    final restaurantRef = FirebaseFirestore.instance.collection('restaurants').doc('restaurant_id');
    final restaurantDoc = await restaurantRef.get();

    if (restaurantDoc.exists) {
      final data = restaurantDoc.data();
      final name = data?['name'];
      final serviceCharge = data?['serviceCharge'];
      nameController.text = name;
      serviceChargeController.text = serviceCharge.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSettings() async {
    final String name = nameController.text;
    final double serviceCharge = double.tryParse(serviceChargeController.text) ?? 0.0;

    final restaurantRef = FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc('restaurant_id');

    final restaurantDoc = await restaurantRef.get();

    if (restaurantDoc.exists) {
      await restaurantRef.update({
        'name': name,
        'serviceCharge': serviceCharge,
      });
    } else {
      await restaurantRef.set({
        'name': name,
        'serviceCharge': serviceCharge,
      });
    }

    notifyListeners();
  }
}
