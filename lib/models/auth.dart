import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterplant/config.dart';

class AuthRepo {
  final Dio _dio;

  AuthRepo(this._dio);
Future<String?> registerUser({
  required String email,
  required String password,
  required String name,
  String? referralCode,
}) async {
  try {
    Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'full_name': name,
      'referral_code': referralCode ?? '',
    };

    final response = await _dio.post(
      AppConfig.signlink,
      data: data,
      options: Options(
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    print("Response Data: ${response.data}");

    if (response.statusCode == 200) {
      return null; // Registration successful, return no error
    } else {
      return response.data["message"] ?? "Unknown error occurred"; // Extract error message
    }
  } on DioException catch (e) {
    if (e.response != null) {
      // ✅ Debugging: Print the full error response
      print("Error Response Data: ${e.response?.data}");

      return e.response?.data["message"] ?? "Something went wrong.";
    } else {
      return "No response from server. Check your internet connection.";
    }
  } catch (e) {
    return "Unexpected error: ${e.toString()}";
  }
}


  
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      Map<String, dynamic> data = {
        'email': email,
        'password': password,
      };

      final response = await _dio.post(
        AppConfig.loginlink,
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        String token = response.data['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);

      return token;
      } else {
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }  //forgotpass
}