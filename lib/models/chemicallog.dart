import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterplant/config.dart';

class ChemicalLogRepository {
  final Dio dio;

  ChemicalLogRepository({Dio? dio})
      : dio = dio ?? Dio(); // Remove baseUrl from BaseOptions

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> fetchChemicalLogData() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final prefs = await SharedPreferences.getInstance();
    final plantId = prefs.getInt('plant_id');
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }
    try {
      final response = await dio.post(
        AppConfig.chemicallog,
        data: {'plant_id': plantId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return {'logs': data};
        } else {
          return {'logs': [data]};
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception('Failed to fetch equipment data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> addChemicalLog(Map<String, String> log) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await dio.post(
        AppConfig.chemicallog, // Use the full URL directly
        data: {
          'chemical_name': log['name'],
          'chemical_status': _mapStatusToInt(log['status']!),
          'maintenance_done': log['maintenance'] == 'Done',
          'shift': int.parse(log['shift']!),
          'start_date': DateTime.parse(log['date']!).toUtc().toIso8601String(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to add equipment log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  int _mapStatusToInt(String status) {
    switch (status) {
      case 'OK':
        return 0;
      case 'Warning':
        return 1;
      case 'Critical':
        return 2;
      default:
        return 0;
    }
  }

  
}



//chemical log

