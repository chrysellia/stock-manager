import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  final Duration timeout = const Duration(seconds: 30);

  // Helper method to handle GET requests
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/$endpoint'),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to handle POST requests
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to handle PUT requests
  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/$endpoint'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to handle DELETE requests
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/$endpoint'),
          )
          .timeout(timeout);

      return _handleResponse(response);
    } on SocketException {
      throw Exception('No Internet connection');
    } catch (e) {
      rethrow;
    }
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
