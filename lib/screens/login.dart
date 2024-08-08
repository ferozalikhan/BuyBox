// ****************************************************************************************************
// Login Screen
// This screen will display the login form and signup form
// The user can switch between the login and signup forms using the toggle button
// The login form and signup form are implemented as separate widgets
// The login form and signup form will be displayed based on the value of the _isLogin variable
// ****************************************************************************************************

import 'package:buybox/widgets/login_form.dart';
import 'package:buybox/widgets/signup_form.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  // accept an optinal argument isLogin
  const LoginScreen({super.key, this.isLogin = true});

  final bool isLogin;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _isLogin = true;

  // intialize teh isLogin property in initState
  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actionsIconTheme: IconThemeData(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0, // Adjust elevation as needed
          backgroundColor: Colors.blueGrey[900], // Example background color
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pages_rounded,
                  color: Colors.white), // Example icon for illustration
              const SizedBox(width: 8),
              Text(
                _isLogin ? "Login Page" : "Signup Page",
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                // Add your action here
              },
              icon: Icon(Icons.settings, color: Colors.white),
            ),
            IconButton(
              onPressed: () {
                // Add your action here
              },
              icon: Icon(Icons.notifications, color: Colors.white),
            ),
          ],
        ),
        body: _isLogin == true
            ? LoginForm(
                isLogin: (value) {
                  setState(() {
                    _isLogin = value;
                  });
                },
              )
            : SignupForm(
                isLogin: (value) {
                  setState(() {
                    _isLogin = value;
                  });
                },
              ));
  }
}
