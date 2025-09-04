import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestion_stock_epicerie/models/user_model.dart';
import 'package:gestion_stock_epicerie/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  // Initialize auth state - SAFE VERSION
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);

    try {
      // Add a small delay to prevent build conflicts
      await Future.delayed(const Duration(milliseconds: 100));

      // Add timeout to prevent hanging
      final userData = await _authService.getCurrentUser().timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          if (kDebugMode) {
            print('AuthService.getCurrentUser() timed out');
          }
          return null;
        },
      );
      
      if (userData != null) {
        _user = UserModel.fromJson(userData);
      }
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize authentication. Please check your connection.';
      if (kDebugMode) {
        print('Auth initialization error: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.login(email, password);
      if (result['success'] == true) {
        _user = UserModel.fromJson(result['user']);
        _safeNotifyListeners();
        return true;
      }
      _error = result['message'] ?? 'Login failed';
      _safeNotifyListeners();
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print('Login error: $e');
      }
      _safeNotifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _authService.logout();
      _user = null;
      _error = null;
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Failed to logout';
      if (kDebugMode) {
        print('Logout error: $e');
      }
      _safeNotifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _clearError();
    _safeNotifyListeners();
  }

  // SAFE HELPER METHODS
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  void _clearError() {
    _error = null;
  }

  void _safeNotifyListeners() {
    // Use WidgetsBinding to ensure we're not in the middle of a build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Reset provider state (useful for testing)
  void reset() {
    _user = null;
    _isLoading = false;
    _isInitialized = false;
    _error = null;
    notifyListeners();
  }
}
