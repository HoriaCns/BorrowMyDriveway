import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';

class AppwriteClient extends ChangeNotifier {
  Client client = Client();
  late Account account;
  late Databases databases;
  late Storage storage;
  late Realtime realtime;

  // Appwrite Project Details - REPLACE WITH YOURS
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = '688795acbbfe317f481a'; // Replace with your Project ID
  static const String databaseId = '68878cb5003c518d7758'; // Replace with your Database ID
  static const String drivewaysCollectionId = '68878cc8002c9aefa049'; // Replace
  static const String storageBucketId = '68878db4000a2b4431c0'; // Replace

  User? _user;
  User? get user => _user;

  AppwriteClient() {
    client
        .setEndpoint(endpoint)
        .setProject(projectId)
        .setSelfSigned(status: true); // For testing in dev mode

    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    realtime = Realtime(client);

    // Check for an existing session
    fetchUser();
  }

  Future<void> fetchUser() async {
    try {
      _user = await account.get();
    } catch (_) {
      _user = null;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await account.createEmailPasswordSession(email: email, password: password);
    await fetchUser();
  }

  Future<void> register(String email, String password, String name) async {
    await account.create(userId: ID.unique(), email: email, password: password, name: name);
    await login(email, password); // Log in after registration
  }

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
    _user = null;
    notifyListeners();
  }
}