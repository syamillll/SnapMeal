import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/auth/forget_password_page.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/providers/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 8),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Login Button
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      User? user = await context.read<AuthService>().logInWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (user != null) {
                        // Navigate to the home page
                        Navigator.pushNamedAndRemoveUntil(context, '/main_page', (route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login Successful')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Login Failed')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.07),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 8),

                // Register Button
                TextButton (
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text("Don't have an account?"),
                ),

                // Forgot Password
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ForgetPasswordPage()),
                    );
                  },
                  child: const Text('Forgot password?'),
                ),
                const SizedBox(height: 8),

                // OR Divider
                const Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider()
                    ),       
                    Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "OR",
                      style: TextStyle(
                      color: Colors.blueGrey,
                      ),
                    ),
                    ),        
                    Expanded(
                      child: Divider()
                    ),
                  ]
                ),
                const SizedBox(height: 16),

                // Login as Customer Button
                ElevatedButton(
                  onPressed: () async {
                    User? user = await context.read<AuthService>().logInAnonymously();
                    if (user != null) {
                      Navigator.pushNamed(context, '/main_page');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anonymous Login Successful')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Anonymous Login Failed')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.07),
                  ),
                  child: const Text('Login as Customer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
