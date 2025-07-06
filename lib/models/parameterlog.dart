import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';

class ParameterLogRepository {
  final Dio dio;

  ParameterLogRepository({Dio? dio}) : dio = dio ?? Dio();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> fetchParameterLogData() async {
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
        AppConfig.parameterlog,
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
        throw Exception('Failed to fetch parameter log data: {response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> addParameterLog(Map<String, dynamic> log) async {
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
      final data = <String, dynamic>{
        'plant_flow_parameter_id': log['plant_flow_parameter_id'],
        'shift': log['shift'],
        'plant_id': plantId,
      };
      // Only include 'value' if provided and valid
      if (log.containsKey('value') && log['value'] != null && log['value'].toString().isNotEmpty) {
        final valueParsed = double.tryParse(log['value'].toString());
        if (valueParsed != null) {
          data['value'] = valueParsed;
        }
      }
      // Only include 'outlet_value' if provided and valid
      if (log.containsKey('outlet_value') && log['outlet_value'] != null && log['outlet_value'].toString().isNotEmpty) {
        final outletParsed = double.tryParse(log['outlet_value'].toString());
        if (outletParsed != null) {
          data['outlet_value'] = outletParsed;
        }
      }
      final response = await dio.post(
        AppConfig.parameterlogadd,
        data: data,
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
        throw Exception('Failed to add parameter log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

Future<Map<String, dynamic>> editParameterLog({
  required int flowParameterLogId,
  double? value,
  double? outletValue,
  int? shift,
}) async {
  final token = await _getToken();
  if (token == null) {
    throw Exception('No authentication token found');
  }

  final Map<String, dynamic> data = {
    'flow_parameter_log_id': flowParameterLogId,
  };
  if (value != null) data['value'] = value;
  if (outletValue != null) data['outlet_value'] = outletValue;
  if (shift != null) data['shift'] = shift;

  try {
    final response = await dio.put(
      AppConfig.parameterlogedit,
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
      throw Exception('Failed to edit parameter log: ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception('Network error: ${e.message}');
  }
}
      Future<bool> deleteParameterLog(int parameterLogId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await dio.delete(
        '${AppConfig.parameterlogdelete}/$parameterLogId',
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

}
