import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';


class PlantType {
  final int id;
  final String name;

  PlantType({
    required this.id,
    required this.name,
  });

  factory PlantType.fromJson(Map<String, dynamic> json) {
    return PlantType(
      id: json['plant_type_id'] as int,
      name: json['plant_type_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plant_type_id': id,
      'plant_type_name': name,
    };
  }
}

class PlantRepo {
  final Dio _dio;

  PlantRepo(this._dio);

Future<List<Map<String, dynamic>>> fetchAllPlants() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await _dio.get(
      AppConfig.plantlink,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load plant data: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching all plant data: ${e.toString()}');
  }
}
}

class PlantModel {
  final List<int> clientId;
  final List<int> operatorId;
  final int plantTypeId;
  final String plantName;
  final String address;
  final int plantCapacity;
  final bool operationalStatus;
  final String plantDescription;
  final String hotelName;

  PlantModel({
    required this.clientId,
    required this.operatorId,
    required this.plantTypeId,
    required this.plantName,
    required this.address,
    required this.plantCapacity,
    required this.operationalStatus,
    required this.plantDescription,
    required this.hotelName,
  });

  Map<String, dynamic> toJson() => {
        'client_id': clientId,
        'operator_id': operatorId,
        'plant_type_id': plantTypeId,
        'plant_name': plantName,
        'address': address,
        'plant_capacity': plantCapacity,
        'operational_status': operationalStatus,
        'plant_description': plantDescription,
        'hotel_name': hotelName,
      };
}
class PlantRepository {
  final Dio _dio;
PlantRepository(this._dio);
 Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  Future<bool> postPlant(PlantModel plant) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await _dio.post(
      AppConfig.createplantlink,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
      data: jsonEncode(plant.toJson()),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  } catch (e) {
    throw Exception('Error posting plant data: ${e.toString()}');
  }
}
     Future<bool> deleteplant(int plantId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await _dio.delete(
        '${AppConfig.plantdelete}/$plantId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete chemical log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
Future<Map<String, dynamic>> editplant({
  required int plantId,
  int? plantTypeId,
  String? plantName,
  String? address,
  int? plantCapacity,
  bool? operationalStatus,
  String? plantDescription,
  String? hotelName,
  List<int>? clientIds,
  List<int>? operatorIds,
}) async {
  final token = await _getToken();
  if (token == null) {
    throw Exception('No authentication token found');
  }

  final Map<String, dynamic> data = {
    'plant_id': plantId,
  };

  if (plantTypeId != null) data['plant_type_id'] = plantTypeId;
  if (plantName != null) data['plant_name'] = plantName;
  if (address != null) data['address'] = address;
  if (plantCapacity != null) data['plant_capacity'] = plantCapacity;
  if (operationalStatus != null) data['operational_status'] = operationalStatus;
  if (plantDescription != null) data['plant_description'] = plantDescription;
  if (hotelName != null) data['hotel_name'] = hotelName;
  if (clientIds != null && clientIds.isNotEmpty) data['client_id'] = clientIds;
  if (operatorIds != null && operatorIds.isNotEmpty) data['operator_id'] = operatorIds;

  try {
    final response = await _dio.put(
      '${AppConfig.plantedit}/$plantId',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to edit plant: ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception('Network error: ${e.message}');
  }
}


}