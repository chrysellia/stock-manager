import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestion_stock_epicerie/services/api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _prefs;
  bool _isInitialized = false;

  AuthService._internal()
      : _apiService = ApiService(),
        _secureStorage = const FlutterSecureStorage();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return false;

      // Verify the token is still valid by making an authenticated request
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Login user with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Call your API to authenticate the user
      final response = await _apiService.post(
        'auth/login',
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response['token'] == null || response['refreshToken'] == null) {
        throw Exception('Invalid response from server');
      }

      // Save tokens to secure storage
      await _secureStorage.write(key: 'auth_token', value: response['token']);
      await _secureStorage.write(
        key: 'refresh_token',
        value: response['refreshToken'],
      );

      // Update API service with new tokens
      await _apiService.setAuthTokens(
        response['token'],
        response['refreshToken'],
      );

      // Save user data
      final userData = response['user'];
      if (userData != null) {
        await _prefs.setString('user_data', jsonEncode(userData));
      }

      return {
        'success': true,
        'user': userData,
      };
    } catch (e) {
      // Clear any partial auth data on error
      await logout();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _ensureInitialized();
    try {
      // Invalidate the token on the server if possible
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          await _apiService.post(
            'auth/revoke-token',
            body: {'token': refreshToken},
          );
        } catch (e) {
          // Ignore errors when revoking token
        }
      }
    } finally {
      // Clear all auth data
      await _secureStorage.deleteAll();
      await _prefs.remove('user_data');
      await _apiService.clearTokens();
    }
  }

  // Get auth token
  Future<String?> getToken() async {
    return _secureStorage.read(key: 'auth_token');
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: 'refresh_token');
  }

  // Set auth tokens
  Future<void> setTokens(String token, String refreshToken) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    await _apiService.setAuthTokens(token, refreshToken);
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    await _ensureInitialized();
    try {
      // Check if we have a token first
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return null;

      // Get user data from storage
      final userData = _prefs.getString('user_data');
      if (userData == null) return null;

      return jsonDecode(userData);
    } catch (e) {
      await logout(); // Clear invalid data
      return null;
    }
  }
}
