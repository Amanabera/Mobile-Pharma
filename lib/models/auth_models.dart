class SignupData {
  final String fullName;
  final String email;
  final String password;
  final String? role;

  SignupData({
    required this.fullName,
    required this.email,
    required this.password,
    this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName.trim(),
      'email': email.trim().toLowerCase(),
      'password': password.trim(),
      if (role != null) 'role': role,
    };
  }
}

class LoginData {
  final String email;
  final String password;

  LoginData({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email.trim(),
      'password': password.trim(),
    };
  }
}

class AuthResponse {
  final String message;
  final String fullName;
  final String role;
  final String token;
  final String status; // 'Active' | 'Pending' | 'Blocked'
  final String? email;

  AuthResponse({
    required this.message,
    required this.fullName,
    required this.role,
    required this.token,
    required this.status,
    this.email,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      token: json['token'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      email: json['email'] as String?,
    );
  }

  bool get isActive => status == 'Active';
  bool get isPending => status == 'Pending';
  bool get isBlocked => status == 'Blocked';
}

class StatusResponse {
  final String status;

  StatusResponse({required this.status});

  factory StatusResponse.fromJson(Map<String, dynamic> json) {
    return StatusResponse(
      status: json['status'] as String? ?? 'Pending',
    );
  }
}


