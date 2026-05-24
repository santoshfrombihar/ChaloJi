import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chaloji_driver/core/constants/api_constants.dart';

class AuthService {
  // 1. Login API Call Method
  Future<bool> loginDriver(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        print('Backend Response: ${response.body}');
        return true;
      } else {
        print('Login Fail: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network Error Occurred: $e');
      return false;
    }
  }
}