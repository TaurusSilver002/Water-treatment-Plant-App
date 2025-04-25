import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterplant/config.dart';

class AuthRepo {
  final Dio _dio;

  AuthRepo(this._dio);

  Future<String?> registerUser({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String aadharNumber,
    required String phoneNumber,
    required String address,
    required String dateOfBirth,
    required String qualification,
    required int roleId,
  }) async {
    try {
      Map<String, dynamic> data = {
        'email': email,
        'password': password,
        'first_name': firstname,
        'last_name': lastname,
        'aadhar_no': aadharNumber,
        'phone_no': phoneNumber,
        'address': address,
        'DOB': dateOfBirth,
        'qualification': qualification,
        'role_id': roleId,
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
        String token = response.data['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return token; // Registration successful, return no error
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
  } //forgotpass
}