import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';

class PlantParamRepository {
  final Dio dio;
  PlantParamRepository({Dio? dio}) : dio = dio ?? Dio();

  Future<List<Map<String, dynamic>>> fetchPlantParams() async {
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
        '${AppConfig.plantparam}/$plantId',
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
        throw Exception('Failed to fetch plant parameters: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> addPlantParam({
    required String parameterName,
    required String parameterUnit,
    required double targetValue,
    required double tolerance,
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
        AppConfig.plantparamadd,
        data: {
          'plant_id': plantId,
          'parameter_name': parameterName,
          'parameter_unit': parameterUnit,
          'target_value': targetValue,
          'tolerance': tolerance,
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
        throw Exception('Failed to add plant parameter: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
