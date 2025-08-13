import 'package:borrow_my_driveway/providers/auth_provider.dart';
import 'package:borrow_my_driveway/screens/auth/login_or_register.dart';
import 'package:borrow_my_driveway/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the AuthProvider for changes in authentication state
    final authProvider = Provider.of<AuthProvider>(context);

    switch (authProvider.status) {
      case AuthStatus.Uninitialized:
      // Show a loading spinner while checking for a session
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      case AuthStatus.Authenticated:
      // If authenticated, show the main screen with bottom navigation
        return const MainScreen();
      case AuthStatus.Unauthenticated:
      // If not authenticated, show the login/register screen
        return const LoginOrRegister();
    }
  }
}
