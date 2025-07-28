import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/appwrite_client.dart';
import 'home_screen.dart';
import 'login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appwriteClient = context.watch<AppwriteClient>();

    // If user is null, show login, otherwise show home
    return appwriteClient.user == null ? const LoginOrRegister() : const HomeScreen();
  }
}