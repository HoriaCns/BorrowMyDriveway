import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:borrow_my_driveway/service_locator.dart';
import 'package:flutter/material.dart';

enum AuthStatus { Uninitialized, Authenticated, Unauthenticated }

class AuthProvider with ChangeNotifier {
  final Account _account = getIt<Account>();

  AuthStatus _status = AuthStatus.Uninitialized;
  models.User? _user;

  AuthStatus get status => _status;
  models.User? get user => _user;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      _user = await _account.get();
      _status = AuthStatus.Authenticated;
    } catch (e) {
      _status = AuthStatus.Unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(email: email, password: password);
      _user = await _account.get();
      _status = AuthStatus.Authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      rethrow; // Re-throw the exception to be caught in the UI
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _account.create(userId: ID.unique(), email: email, password: password);
      await login(email, password); // Log in the user after successful registration
    } catch (e) {
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      _user = null;
      _status = AuthStatus.Unauthenticated;
      notifyListeners();
    } catch (e) {
      // Even if logout fails on the server, we update the UI
      _status = AuthStatus.Unauthenticated;
      _user = null;
      notifyListeners();
      rethrow;
    }
  }
}
