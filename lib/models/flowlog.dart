import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterplant/config.dart';

class FlowLogRepository {
  final Dio dio;

  FlowLogRepository({Dio? dio}) : dio = dio ?? Dio();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> fetchFlowLogData() async {
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
        AppConfig.flowlog,
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
        throw Exception('Failed to fetch flow data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> addFlowLog(Map<String, String> log) async {
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
        AppConfig.flowlog,
        data: {
          'plant_id': plantId,
          'flow_name': log['name'],
          'inlet': log['inlet'],
          'outlet': log['outlet'],
          'shift': int.tryParse(log['shift'] ?? '1') ?? 1,
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
        throw Exception('Failed to add flow log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
