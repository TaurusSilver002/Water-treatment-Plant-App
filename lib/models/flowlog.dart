import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';

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

  Future<Map<String, dynamic>> addFlowLog(Map<String, dynamic> log) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final prefs = await SharedPreferences.getInstance();
    final plantId = prefs.getInt('plant_id');
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }

    final inletValue = log['inlet_value']?.toString() ?? '';
    final outletValue = log['outlet_value']?.toString() ?? '';
    final inletImage = log['inlet_image'];
    final outletImage = log['outlet_image'];
    final shift = log['shift']?.toString() ?? '1';

    if (inletValue.isEmpty || outletValue.isEmpty) {
      throw Exception('Inlet and outlet values are required');
    }

    try {
      print('Sending flow log to ${AppConfig.flowlogadd}');
      print('Inlet image size: ${inletImage?.length ?? 0} bytes');
      print('Outlet image size: ${outletImage?.length ?? 0} bytes');
      final response = await dio.post(
        AppConfig.flowlogadd,
        data: {
          'plant_id': plantId,
          'inlet_value': double.tryParse(inletValue) ?? 0.0,
          'outlet_value': double.tryParse(outletValue) ?? 0.0,
          'inlet_image': inletImage,
          'outlet_image': outletImage,
          'shift': int.tryParse(shift) ?? 1,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response: ${response.statusCode}, ${response.data}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to add flow log: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}, Response: ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        // Clear token and prompt re-login
        await prefs.remove('token');
        throw Exception('Session expired. Please log in again.');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> editFlowLog({
    required int flowLogId,
    double? inletValue,
    double? outletValue,
    int? shift,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final Map<String, dynamic> data = {
      'flow_log_id': flowLogId,
    };
    if (inletValue != null) data['inlet_value'] = inletValue;
    if (outletValue != null) data['outlet_value'] = outletValue;
    if (shift != null) data['shift'] = shift;
    try {
      final response = await dio.put(
        AppConfig.flowlogedit,
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
        throw Exception('Failed to edit flow log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
