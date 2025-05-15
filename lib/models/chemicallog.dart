import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';

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

Future<Map<String, dynamic>> addChemicalLog(Map<String, dynamic> log) async {
  final token = await _getToken();
  if (token == null) {
    throw Exception('No authentication token found');
  }

  final prefs = await SharedPreferences.getInstance();
  final plantId = prefs.getInt('plant_id');
  if (plantId == null) {
    throw Exception('No plant_id found in shared preferences');
  }

  final chemicalId = log['plant_chemical_id'];
  final quantityUsed = log['quantity_used'];
  final quantityLeft = log['quantity_left'];
  final sludgeDischarge = log['sludge_discharge'];
  final shift = log['shift'];

  try {
    final response = await dio.post(
      AppConfig.chemicallogadd,
      data: {
        'plant_id': plantId,
        'plant_chemical_id': int.parse(chemicalId.toString()),
        'quantity_used': double.parse(quantityUsed.toString()),
        'quantity_left': double.parse(quantityLeft.toString()),
        'sludge_discharge': sludgeDischarge,
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
      throw Exception('Failed to add chemical log: ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception('Network error: ${e.message}');
  }
}

  Future<Map<String, dynamic>> editChemicalLog({
    required int chemicalLogId,
    double? quantityUsed,
    double? quantityLeft,
    bool? sludgeDischarge,
    int? shift,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    final Map<String, dynamic> data = {
      'chemical_log_id': chemicalLogId,
    };
    if (quantityUsed != null) data['quantity_used'] = quantityUsed;
    if (quantityLeft != null) data['quantity_left'] = quantityLeft;
    if (sludgeDischarge != null) data['sludge_discharge'] = sludgeDischarge;
    if (shift != null) data['shift'] = shift;
    try {
      final response = await dio.put(
        AppConfig.chemicallogedit,
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
        throw Exception('Failed to edit chemical log: {response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: {e.message}');
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

