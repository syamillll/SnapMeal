import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/models/staff.dart';
import 'package:snapmeal/providers/auth_service.dart';
import '../components/instructional_text.dart';
import 'unverified_user_list.dart';

class VerifyUserPage extends StatelessWidget {
  const VerifyUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Staff'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
      ),
      body: StreamProvider<List<Staff>>(
        create: (context) => Provider.of<AuthService>(context, listen: false).unverifiedUsers,
        initialData: const [],
        child: const Column(
          children: [
            InstructionalText(text: 'Tap on a user to view details. Swipe right to reject a user. Swipe left to verify a user.'),
            Expanded(
              child: UnverifiedUserList(),
            ),
          ],
        ),
      ),
    );
  }
}
