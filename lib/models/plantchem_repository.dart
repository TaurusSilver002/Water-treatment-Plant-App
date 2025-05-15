import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';

class PlantChemRepository {
  final Dio dio;
  PlantChemRepository({Dio? dio}) : dio = dio ?? Dio();

  Future<List<Map<String, dynamic>>> fetchPlantChemicals() async {
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
        '${AppConfig.plantchem}/$plantId',
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
        throw Exception('Failed to fetch plant chemicals: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> addPlantChem({
    required String chemicalName,
    required double quantity,
    required String chemicalUnit,
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
        AppConfig.plantchemadd,
        data: {
          'chemical_name': chemicalName,
          'quantity': quantity,
          'plant_id': plantId,
          'chemical_unit': chemicalUnit,
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
        throw Exception('Failed to add plant chemical: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
