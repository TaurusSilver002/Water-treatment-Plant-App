import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';

class PlantEquipRepository {
  final Dio dio;
  PlantEquipRepository({Dio? dio}) : dio = dio ?? Dio();

  Future<List<Map<String, dynamic>>> fetchPlantEquipments() async {
    final prefs = await SharedPreferences.getInstance();
    final plantId = prefs.getInt('plant_id');
    final token = prefs.getString('token');
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }
    if (token == null) {
      throw Exception('No authentication token found');
    }
    try {
      final response = await dio.get(
        '${AppConfig.plantequip}/$plantId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map) {
          return [Map<String, dynamic>.from(data)];
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to fetch plant equipment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> addPlantequip({
    required String equipmentName,
    required String equipmentType,
    required int status,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final plantId = prefs.getInt('plant_id');
    final token = prefs.getString('token');
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }
    if (token == null) {
      throw Exception('No authentication token found');
    }
    try {
      final response = await dio.post(
        AppConfig.plantequipadd,
        data: {
          'plant_id': plantId,
          'status': status,
          'equipment_name': equipmentName,
          'equipment_type': equipmentType,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to add plant equipment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
