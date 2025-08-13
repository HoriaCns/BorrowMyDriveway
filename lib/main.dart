import 'package:borrow_my_driveway/providers/auth_provider.dart';
import 'package:borrow_my_driveway/screens/auth/auth_gate.dart';
import 'package:borrow_my_driveway/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure that the Flutter bindings are initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Load the environment variables from the .env file.
  await dotenv.load(fileName: ".env");

  // Initialize the service locator.
  setupLocator();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Borrow My Driveway',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthGate(),
    );
  }
}
