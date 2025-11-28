import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class HttpClient {
  final AuthService _authService = AuthService();

  // GET request
  Future<http.Response> get(
    String url, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final authHeaders = await _authService.getAuthHeaders();
        headers.addAll(authHeaders);
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return response;
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  // POST request
  Future<http.Response> post(
    String url, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final authHeaders = await _authService.getAuthHeaders();
        headers.addAll(authHeaders);
      }

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return response;
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  // PUT request
  Future<http.Response> put(
    String url, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final authHeaders = await _authService.getAuthHeaders();
        headers.addAll(authHeaders);
      }

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body != null ? json.encode(body) : null,
      );

      return response;
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  // DELETE request
  Future<http.Response> delete(
    String url, {
    bool requiresAuth = true,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (requiresAuth) {
        final authHeaders = await _authService.getAuthHeaders();
        headers.addAll(authHeaders);
      }

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      return response;
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  // Helper method to handle API errors
  static void handleError(http.Response response) {
    if (response.statusCode >= 400) {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] as String? ??
            'An error occurred: ${response.statusCode}';
        throw Exception(errorMessage);
      } catch (e) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    }
  }
}


