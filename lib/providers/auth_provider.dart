import 'package:flutter/material.dart';
import 'package:h2s/models/user_model.dart';
import 'package:h2s/services/mock_data_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final MockDataService _dataService = MockDataService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAdmin => _user?.isAdmin ?? false;

  AuthProvider() {
    _user = _dataService.currentUser;
    _status = _user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || password.isEmpty) {
      _error = 'Please fill in all fields.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    final user = _dataService.login(email, password);
    if (user != null) {
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } else {
      _error = 'Invalid email or password.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String email,
    required String name,
    required String password,
    required String role,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      _error = 'Please fill in all fields.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _error = 'Password must be at least 6 characters.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    try {
      final user = _dataService.signup(
        email: email,
        name: name,
        password: password,
        role: role,
      );
      _user = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _dataService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
