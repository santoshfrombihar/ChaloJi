class LoginResponse {
  final String token;
  final String email;
  final String role;
  final String message;

  LoginResponse({
    required this.token,
    required this.email,
    required this.role,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      message: json['message'] ?? '',
    );
  }
}