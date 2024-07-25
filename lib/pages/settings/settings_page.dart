import 'package:flutter/material.dart';
import 'package:snapmeal/pages/settings/edit_profile_page.dart';
import 'package:snapmeal/pages/settings/qr_code_page.dart';
import 'package:snapmeal/pages/settings/restaurant_settings_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text('Update Restaurant Info'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantSettingsPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Update Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text('SnapMeal QR Code'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRCodePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
