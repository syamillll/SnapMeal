
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/auth/choose_role_page.dart';
import 'package:snapmeal/providers/auth_service.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    String? userName = authService.currentUserName;
    String? userRole = authService.currentUserRole; // Assuming you have this in your AuthService

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer header
            DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blueGrey,
            ),
            child: Column(
              children: [
              Image.asset(
                'assets/app_icon.png',
                width: 72,
                height: 72,
              ),
              const Spacer(),
              Text(
                'Welcome, ${userName.length > 10 ? '${userName.substring(0, 10)}...' : userName}\n',
                style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                ),
              ), 
              ],
            ),
            ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // Admin drawer options
          if (userRole == 'admin') ...[
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Manage Menu'),
              onTap: () {
                Navigator.pushNamed(context, '/manage_menu');
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Verify Staff'),
              onTap: () {
                Navigator.pushNamed(context, '/verify_user');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
            },
          ),

          // Staff drawer options
          ] else if (userRole == 'staff') ...[
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
            },
          ),

          // Guest drawer options
          ] else if (userRole == 'guest') ...[
            // // Navigate to the favorites page
            // ListTile(
            //   leading: const Icon(Icons.favorite),
            //   title: const Text('Favorite Items'),
            //   onTap: () {
            //     Navigator.pushNamed(context, '/favorite');
            //   },
            // ),

            // // Navigate to the scan image page
            // ListTile(
            //   leading: const Icon(Icons.camera_alt),
            //   title: const Text('Scan Image'),
            //   onTap: () {
            //     Navigator.pushNamed(context, '/scan');
            //   },
            // ),
          ],
          
          // Sign out
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              await authService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ChooseRolePage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
