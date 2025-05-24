import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:watershooters/config.dart';

class UserModel extends Equatable {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNo;
  final String aadharNo;
  final String qualification;
  final String address;
  final DateTime dob;
  final int roleId;

  const UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNo,
    required this.aadharNo,
    required this.qualification,
    required this.address,
    required this.dob,
    required this.roleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNo: json['phone_no'],
      aadharNo: json['aadhar_no'],
      qualification: json['qualification'],
      address: json['address'],
      dob: DateTime.parse(json['DOB']),
      roleId: json['role_id'],
    );
  }

  static Future<UserModel> fetchFromApi(String userId) async {
    final response = await http.get(
      Uri.parse(AppConfig.userlink),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to load user');
    }
  }

  @override
  List<Object?> get props => [
        userId,
        firstName,
        lastName,
        email,
        phoneNo,
        aadharNo,
        qualification,
        address,
        dob,
        roleId,
      ];
}
