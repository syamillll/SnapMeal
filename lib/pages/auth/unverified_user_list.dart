import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/models/staff.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/providers/auth_service.dart';

class UnverifiedUserList extends StatelessWidget {
  const UnverifiedUserList({super.key});

  @override
  Widget build(BuildContext context) {
    final users = Provider.of<List<Staff>>(context);

    if (users.isEmpty) {
      return const Center(child: Text('No unverified users'));
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return GestureDetector(
          onTap: () {
            showUserDetails(context, user);
          },
          child: Dismissible(
            key: Key(user.id),
            direction: DismissDirection.horizontal,
            confirmDismiss: (direction) async {
              return await confirmDismissDirection(context, direction, user);
            },
            onDismissed: (direction) async {
              await handleDismiss(context, direction, user);
            },
            background: Container(
              color: errorColor,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
            secondaryBackground: Container(
              color: Colors.lightGreen,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.check,
                color: Colors.white,
              ),
            ),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(user.name),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool?> confirmDismissDirection(
      BuildContext context, DismissDirection direction, Staff user) async {
    if (direction == DismissDirection.startToEnd) {
      return await showConfirmationDialog(
        context,
        'Reject User',
        'Are you sure you want to reject ${user.name}?',
      );
    } else if (direction == DismissDirection.endToStart) {
      return await showConfirmationDialog(
        context,
        'Verify User',
        'Are you sure you want to verify ${user.name}?',
      );
    }
    return false;
  }

  Future<void> handleDismiss(
    BuildContext context, 
    DismissDirection direction, 
    Staff user
  ) async {
    // Get the AuthService instance
    final authService = Provider
                        .of<AuthService>(context, listen: false);
    // If swiped from left to right, reject user
    if (direction == DismissDirection.startToEnd) {
      await authService.deleteUser(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} has been rejected')),
      );

      // If swiped from right to left, verify user
    } else if (direction == DismissDirection.endToStart) {
      await authService.verifyUser(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${user.name} has been verified')),
      );
    }
  }

  void showUserDetails(BuildContext context, Staff user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${user.name}'),
              Text('Email: ${user.email}'),
              // Add more user details here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showConfirmationDialog(
      BuildContext context, String title, String content) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
