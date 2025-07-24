import 'package:borrow_my_driveway/screens/auth/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_or_register.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Listen to the authentication state changes
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the user is not logged in, show the login/register page
          if (!snapshot.hasData) {
            return const LoginOrRegister();
          }
          // If the user is logged in, show the home screen
          return const HomeScreen();
        },
      ),
    );
  }
}
