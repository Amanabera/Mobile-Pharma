import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // Host selection based on platform
  static String get _host => kIsWeb ? 'localhost:5000' : '10.0.2.2:5000';

  // Base URL
  static String get baseUrl => 'http://$_host/api';

  // Endpoints
  static String get pharmacyEndpoint => '$baseUrl/pharmacy';
  static String get stockEndpoint => '$baseUrl/stock';
  static String get loginEndpoint => '$baseUrl/auth/login';
  static String get signupEndpoint => '$baseUrl/auth/signup';
  static String get statusEndpoint => '$baseUrl/auth/status';
}
