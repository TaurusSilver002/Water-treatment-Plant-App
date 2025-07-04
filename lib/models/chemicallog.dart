import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watershooters/config.dart';

class ChemicalLogRepository {
  final Dio dio;

  ChemicalLogRepository({Dio? dio}) : dio = dio ?? Dio();

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
        throw Exception('Failed to fetch chemical log data: ${response.statusCode}');
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
  final quantityLeft = log['incomming_quantity'];
  final sludgeDischarge = log['sludge_discharge'];
  final shift = log['shift'];

  // Validate required fields
  if (chemicalId == null || quantityUsed == null || shift == null) {
    throw Exception('Missing required fields: plant_chemical_id, quantity_used, or shift');
  }

  // Prepare the data payload
  final data = <String, dynamic>{
    'plant_id': plantId,
    'plant_chemical_id': int.parse(chemicalId.toString()),
    'quantity_used': double.parse(quantityUsed.toString()),
    'sludge_discharge': sludgeDischarge ?? false,
    'shift': int.parse(shift.toString()),
  };

  // Only include incomming_quantity if it is non-null, non-empty, and a valid double
  if (quantityLeft != null && quantityLeft.toString().isNotEmpty) {
    final parsedQuantityLeft = double.tryParse(quantityLeft.toString());
    if (parsedQuantityLeft == null) {
      throw Exception('Invalid incomming_quantity: must be a valid number');
    }
    data['incomming_quantity'] = parsedQuantityLeft;
  }

  try {
    final response = await dio.post(
      AppConfig.chemicallogadd,
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
    if (quantityLeft != null) data['incomming_quantity'] = quantityLeft;
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
        throw Exception('Failed to edit chemical log: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<bool> deleteChemicalLog(int chemicalLogId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await dio.delete(
        '${AppConfig.chemicallogdelete}/$chemicalLogId',
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

