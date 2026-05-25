class RegisterResponse {
  final int id;
  final String name;
  final String email;
  final String role;
  final String message;

  // Constructor to initialize the final fields
  RegisterResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.message,
  });

  // Factory constructor to map .NET JSON response safely to this Dart class
  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      message: json['message'] ?? '',
    );
  }
}