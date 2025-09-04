import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService with ChangeNotifier {
  // TODO : Change this to your API URL
  static const String baseUrl = 'http://192.168.130.1:5234/api';
  final Duration timeout = const Duration(seconds: 30);

  String? _token;
  String? _refreshToken;

  // Create a custom HTTP client with retry logic
  Future<http.Response> _retryRequest(Future<http.Response> Function() request,
      {int maxRetries = 3}) async {
    int attempt = 0;
    http.Response? lastResponse;

    while (attempt < maxRetries) {
      try {
        lastResponse = await request();

        // If 401 Unauthorized, try to refresh token and retry
        if (lastResponse.statusCode == 401) {
          final refreshed = await _refreshAuthToken();
          if (refreshed) {
            // Update the request with the new token and retry
            attempt++;
            continue;
          }
        }

        // If we get here, either the request was successful or we can't retry
        return lastResponse;
      } catch (e) {
        // On any error, increment the attempt counter
        attempt++;
        if (attempt >= maxRetries) {
          rethrow; // Re-throw if we've reached max retries
        }
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: 1 * attempt));
      }
    }

    return lastResponse ?? http.Response('No response received', 500);
  }

  // Set authentication tokens
  Future<void> setAuthTokens(String? token, String? refreshToken) async {
    _token = token;
    _refreshToken = refreshToken;

    // Save tokens to shared preferences
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    }
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }

    notifyListeners();
  }

  // Load tokens from shared preferences
  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // Clear authentication tokens
  Future<void> clearTokens() async {
    _token = null;
    _refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');

    notifyListeners();
  }

  // Refresh authentication token
  Future<bool> _refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await setAuthTokens(data['token'], data['refreshToken']);
        return true;
      }

      // If refresh token is invalid, clear all tokens
      await clearTokens();
      return false;
    } catch (e) {
      await clearTokens();
      return false;
    }
  }

  // Helper method to handle GET requests
  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    // Ensure tokens are loaded
    if (_token == null) {
      await loadTokens();
    }

    // Prepare headers
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add auth header if required
    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    // Make the request with retry logic
    final response = await _retryRequest(
      () => http
          .get(
            Uri.parse('$baseUrl/$endpoint'),
            headers: headers,
          )
          .timeout(timeout),
    );

    return _handleResponse(response);
  }

  // Helper method to handle POST requests
  Future<dynamic> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requiresAuth = true,
  }) async {
    // Ensure tokens are loaded
    if (_token == null) {
      await loadTokens();
    }

    // Prepare headers
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Add auth header if required
    if (requiresAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    // Make the request with retry logic
    final response = await _retryRequest(
      () => http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout),
    );

    return _handleResponse(response);
  }

  // Helper method to handle PUT requests
  Future<dynamic> put(String endpoint,
      {required Map<String, dynamic> body}) async {
    // Make the request with retry logic
    final response = await _retryRequest(
      () => http
          .put(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout),
    );

    return _handleResponse(response);
  }

  // Helper method to handle DELETE requests
  Future<dynamic> delete(String endpoint) async {
    // Make the request with retry logic
    final response = await _retryRequest(
      () => http
          .delete(
            Uri.parse('$baseUrl/$endpoint'),
          )
          .timeout(timeout),
    );

    return _handleResponse(response);
  }

  // Handle the HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Something went wrong');
    }
  }
}
