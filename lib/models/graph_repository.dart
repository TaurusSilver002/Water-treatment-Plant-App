import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';

class GraphRepository {
  final Dio dio;
  GraphRepository({Dio? dio}) : dio = dio ?? Dio();

  Future<Map<String, dynamic>> fetchEquipGraphData({
    required DateTime startDate,
    required DateTime endDate,
    required String logType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final plantId = prefs.getInt('plant_id');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }
    final data = {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'plant_id': plantId,
      'log_type': logType,
    };
    try {
      final response = await dio.post(
        AppConfig.graphDataEquip, 
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
        throw Exception('Failed to fetch graph data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> fetchParamGraphData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final plantId = prefs.getInt('plant_id');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }
    final data = {
      'start_date': "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
      'end_date': "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
      'plant_id': plantId,
      'log_type': 'flowparameter',
    };
    try {
      final response = await dio.post(
        AppConfig.graphDataParam,
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
        throw Exception('Failed to fetch parameter graph data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> fetchFlowGraphData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final plantId = prefs.getInt('plant_id');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }
    final data = {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'plant_id': plantId,
      'log_type': 'flow',
    };
    try {
      final response = await dio.post(
        AppConfig.graphDataFlow,
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
        throw Exception('Failed to fetch flow graph data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> fetchChemUsedGraphData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final plantId = prefs.getInt('plant_id');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }
    final data = {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'plant_id': plantId,
      'log_type': 'chemical',
    };
    try {
      final response = await dio.post(
        AppConfig.graphDataChemUsed,
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
        throw Exception('Failed to fetch chemical used graph data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> fetchChemRemGraphData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final plantId = prefs.getInt('plant_id');
    if (token == null) {
      throw Exception('No authentication token found');
    }
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }
    final data = {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'plant_id': plantId,
      'log_type': 'chemical',
    };
    try {
      final response = await dio.post(
        AppConfig.graphDataChemRem,
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
        throw Exception('Failed to fetch chemical remaining graph data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
