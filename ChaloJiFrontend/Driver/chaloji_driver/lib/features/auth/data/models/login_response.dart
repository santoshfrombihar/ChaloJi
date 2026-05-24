class LoginResponse {
  final String token; 
  final String email;
  final String name;

  LoginResponse({required this.token, required this.email, required this.name});


  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }
}