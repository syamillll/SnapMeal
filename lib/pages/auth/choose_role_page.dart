import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/providers/auth_service.dart';

class ChooseRolePage extends StatefulWidget {
  const ChooseRolePage({super.key});

  @override
  _ChooseRolePageState createState() => _ChooseRolePageState();
}

class _ChooseRolePageState extends State<ChooseRolePage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Text(
                'Choose Your Role',
                style: TextStyle(fontSize: 28, color: secColor, fontWeight: FontWeight.bold),
                
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  child: Card(
                    surfaceTintColor: Colors.green,
                    elevation: 2,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/waiter.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Staff',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await context.read<AuthService>().logInAnonymously();
                    Navigator.pushNamed(context, '/main_page');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Anonymous Login Successful')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Anonymous Login Failed: $e')),
                    );
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                  child: Card(
                    surfaceTintColor: Colors.blue,
                    elevation: 2,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Image.asset(
                          'assets/customer.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Customer',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              if (_isLoading) const Center(child: CircularProgressIndicator()), // Show the loading indicator if _isLoading is true
            ],
          ),
        ),
      ),
    );
  }
}
