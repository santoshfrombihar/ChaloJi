import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chaloji_driver/core/constants/api_constants.dart';
import 'package:chaloji_driver/features/auth/data/models/login_response.dart';
import 'package:chaloji_driver/features/auth/data/models/register_response.dart';

class AuthService {
  // ── Headers ──────────────────────────────────────
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── 1. Login ──────────────────────────────────────
  Future<LoginResponse?> loginDriver(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return LoginResponse.fromJson(json['data']); // .NET ApiResponse wrapper
      } else {
        final json = jsonDecode(response.body);
        print('Login Failed: ${json['message']}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

  // ── 2. Register ────────────────────────────────────
  Future<RegisterResponse?> registerDriver({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register), // login nahi, register URL
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'phoneNumber': phone,
          'password': password,
          'role': 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return RegisterResponse.fromJson(
          json['data'],
        ); // .NET ApiResponse wrapper
      } else {
        final json = jsonDecode(response.body);
        print('Register Failed: ${json['message']}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }
}
