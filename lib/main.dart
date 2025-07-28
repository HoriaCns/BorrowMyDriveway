import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_gate.dart';
import 'services/appwrite_client.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppwriteClient(),
      child: const BorrowMyDrivewayApp(),
    ),
  );
}

class BorrowMyDrivewayApp extends StatelessWidget {
  const BorrowMyDrivewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Borrow My Driveway',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( // Your theme data remains the same...
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0052D4),
          primary: const Color(0xFF0052D4),
          secondary: const Color(0xFF65C7F7),
          surface: Colors.grey[100],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0052D4),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0052D4), width: 2)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}