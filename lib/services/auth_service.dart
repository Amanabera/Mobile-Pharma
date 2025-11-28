import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String _tokenKey = 'token';
  static const String _roleKey = 'role';
  static const String _emailKey = 'email';
  static const String _fullNameKey = 'fullName';

  // ===== SIGNUP =====
  Future<AuthResponse> signup(SignupData data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signupEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
          return AuthResponse.fromJson(jsonResponse);
        } catch (e) {
          throw Exception('Invalid response format from server');
        }
      } else {
        String errorMessage = 'Signup failed: ${response.statusCode}';
        try {
          if (response.body.isNotEmpty) {
            final errorBody = json.decode(response.body) as Map<String, dynamic>;
            errorMessage = errorBody['message'] as String? ?? errorMessage;
          }
        } catch (_) {
          // If JSON decode fails, use default error message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error during signup: $e');
    }
  }

  // ===== LOGIN =====
  Future<AuthResponse> login(LoginData data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
          return AuthResponse.fromJson(jsonResponse);
        } catch (e) {
          throw Exception('Invalid response format from server');
        }
      } else {
        String errorMessage = 'Login failed: ${response.statusCode}';
        try {
          if (response.body.isNotEmpty) {
            final errorBody = json.decode(response.body) as Map<String, dynamic>;
            errorMessage = errorBody['message'] as String? ?? errorMessage;
          }
        } catch (_) {
          // If JSON decode fails, use default error message
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error during login: $e');
    }
  }

  // ===== CHECK USER STATUS =====
  Future<StatusResponse> checkUserStatus(String email) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.statusEndpoint}/$email'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
          return StatusResponse.fromJson(jsonResponse);
        } catch (e) {
          throw Exception('Invalid response format from server');
        }
      } else {
        throw Exception('Failed to check user status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error checking user status: $e');
    }
  }

  // ===== TOKEN MANAGEMENT =====
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fullNameKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> storeLoginInfo(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, response.token);
    await prefs.setString(_roleKey, response.role);
    await prefs.setString(_emailKey, response.email ?? '');
    await prefs.setString(_fullNameKey, response.fullName);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_fullNameKey);
  }

  // ===== AUTH HEADERS =====
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get auth headers for making authenticated requests
  Future<Map<String, String>> getAuthHeaders() async {
    return await _getAuthHeaders();
  }
}

