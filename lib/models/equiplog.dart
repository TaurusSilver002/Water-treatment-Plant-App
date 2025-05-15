import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';

class EquipmentRepository {
  final Dio dio;

  EquipmentRepository({Dio? dio})
      : dio = dio ?? Dio(); 

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> fetchEquipmentData() async {
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
        AppConfig.equiplog,
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

  Future<Map<String, dynamic>> addEquipmentLog(Map<String, dynamic> log) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final prefs = await SharedPreferences.getInstance();
    final plantId = prefs.getInt('plant_id');
    if (plantId == null) {
      throw Exception('No plant_id found in shared preferences');
    }
    // Extract and validate fields
    final plantEquipmentId = log['plant_equipment_id'];
    // Accept both 'status' and 'equipment_status' for compatibility
final rawStatus = log['status'] ?? log['equipment_status'];
final statusValue = rawStatus is int
    ? rawStatus
    : int.tryParse(rawStatus.toString()) ?? _mapStatusToInt(rawStatus.toString());
    final maintenanceDone = log['maintenance_done'];
    final remark = log['equipment_remark'];
    final shift = log['shift'];
    try {
      final response = await dio.post(
        AppConfig.equiplogadd,
        data: {
          'plant_id': plantId,
          'plant_equipment_id': int.parse(plantEquipmentId.toString()),
          'equipment_status': statusValue,
          'maintenance_done': maintenanceDone,
          'equipment_remark': remark,
          'shift': int.parse(shift.toString()),
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

  Future<Map<String, dynamic>> editEquipmentLog({
    required int equipmentLogId,
    int? equipmentStatus,
    bool? maintenanceDone,
    int? shift,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final Map<String, dynamic> data = {
      'equipment_log_id': equipmentLogId,
    };
    if (equipmentStatus != null) data['equipment_status'] = equipmentStatus;
    if (maintenanceDone != null) data['maintenance_done'] = maintenanceDone;
    if (shift != null) data['shift'] = shift;
    try {
      final response = await dio.put(
        AppConfig.equiplogedit,
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
        throw Exception('Failed to edit equipment log: ${response.statusCode}');
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




