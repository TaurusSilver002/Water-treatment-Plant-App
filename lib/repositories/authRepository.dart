import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  final String baseUrl;

  AuthRepository(this.baseUrl);

  Future<bool> validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/validate-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Token validation error: ${e.toString()}');
      return false;
    }
  }
}