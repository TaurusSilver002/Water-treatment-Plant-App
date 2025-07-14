import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:watershooters/config.dart';

// Models
class ReportData {
  final List<ChemicalLog> chemicalLogs;
  final List<EquipmentLog> equipmentLogs;
  final List<FlowParameterLog> flowParameterLogs;
  final List<FlowLog> flowLogs;

  ReportData({
    required this.chemicalLogs,
    required this.equipmentLogs,
    required this.flowParameterLogs,
    required this.flowLogs,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      chemicalLogs: (json['chemical_logs'] as List)
          .map((item) => ChemicalLog.fromJson(item))
          .toList(),
      equipmentLogs: (json['equipment_logs'] as List)
          .map((item) => EquipmentLog.fromJson(item))
          .toList(),
      flowParameterLogs: (json['flow_parameter_logs'] as List)
          .map((item) => FlowParameterLog.fromJson(item))
          .toList(),
      flowLogs: (json['flow_logs'] as List)
          .map((item) => FlowLog.fromJson(item))
          .toList(),
    );
  }
}

class ChemicalLog {
  final int plantChemicalId;
  final String chemicalName;
  final double quantityLeft;
  final bool sludgeDischarge;
  final int dailyLogId;
  final int plantId;
  final int chemicalLogId;
  final int createdBy;
  final int shift;
  final double quantityUsed;
  final String createdAt;

  ChemicalLog({
    required this.plantChemicalId,
    required this.chemicalName,
    required this.quantityLeft,
    required this.sludgeDischarge,
    required this.dailyLogId,
    required this.plantId,
    required this.chemicalLogId,
    required this.createdBy,
    required this.shift,
    required this.quantityUsed,
    required this.createdAt,
  });

  factory ChemicalLog.fromJson(Map<String, dynamic> json) {
    return ChemicalLog(
      plantChemicalId: json['plant_chemical_id'],
      chemicalName: json['chemical_name'],
      quantityLeft: json['quantity_left'],
      //.toDouble(),
      sludgeDischarge: json['sludge_discharge'],
      dailyLogId: json['daily_log_id'],
      plantId: json['plant_id'],
      chemicalLogId: json['chemical_log_id'],
      createdBy: json['created_by'],
      shift: json['shift'],
      quantityUsed: json['quantity_used'],
      //.toDouble(),
      createdAt: json['created_at'],
    );
  }
}

class EquipmentLog {
  final int equipmentLogId;
  final int plantId;
  final String equipmentName;
  final int equipmentStatus;
  final bool maintenanceDone;
  final int plantEquipmentId;
  final int dailyLogId;
  final int createdBy;
  final int shift;
  final String? equipmentRemark;
  final String createdAt;

  EquipmentLog({
    required this.equipmentLogId,
    required this.plantId,
    required this.equipmentName,
    required this.equipmentStatus,
    required this.maintenanceDone,
    required this.plantEquipmentId,
    required this.dailyLogId,
    required this.createdBy,
    required this.shift,
    this.equipmentRemark,
    required this.createdAt,
  });

  factory EquipmentLog.fromJson(Map<String, dynamic> json) {
    return EquipmentLog(
      equipmentLogId: json['equipment_log_id'],
      plantId: json['plant_id'],
      equipmentName: json['equipment_name'],
      equipmentStatus: json['equipment_status'],
      maintenanceDone: json['maintenance_done'],
      plantEquipmentId: json['plant_equipment_id'],
      dailyLogId: json['daily_log_id'],
      createdBy: json['created_by'],
      shift: json['shift'],
      equipmentRemark: json['equipment_remark'],
      createdAt: json['created_at'],
    );
  }
}

class FlowParameterLog {
  final int flowParameterLogId;
  final int plantId;
  final int plantFlowParameterId;
  final String parameterName;
  final int shift;
  final double outletValue;
  final int dailyLogId;
  final int createdBy;
  final double inletValue;
  final String createdAt;

  FlowParameterLog({
    required this.flowParameterLogId,
    required this.plantId,
    required this.plantFlowParameterId,
    required this.parameterName,
    required this.shift,
    required this.outletValue,
    required this.dailyLogId,
    required this.createdBy,
    required this.inletValue,
    required this.createdAt,
  });

  factory FlowParameterLog.fromJson(Map<String, dynamic> json) {
    return FlowParameterLog(
      flowParameterLogId: json['flow_parameter_log_id'],
      plantId: json['plant_id'],
      plantFlowParameterId: json['plant_flow_parameter_id'],
      parameterName: json['parameter_name'],
      shift: json['shift'],
      outletValue: json['outlet_value'],
      //.toDouble(),
      dailyLogId: json['daily_log_id'],
      createdBy: json['created_by'],
      inletValue: json['inlet_value'],
      //.toDouble(),
      createdAt: json['created_at'],
    );
  }
}

class FlowLog {
  final int dailyLogId;
  final double inletValue;
  final String? inletImage;
  final int createdBy;
  final String updatedAt;
  final int flowLogId;
  final int plantId;
  final double outletValue;
  final String? outletImage;
  final String createdAt;
  final int shift;

  FlowLog({
    required this.dailyLogId,
    required this.inletValue,
    this.inletImage,
    required this.createdBy,
    required this.updatedAt,
    required this.flowLogId,
    required this.plantId,
    required this.outletValue,
    this.outletImage,
    required this.createdAt,
    required this.shift,
  });

  factory FlowLog.fromJson(Map<String, dynamic> json) {
    return FlowLog(
      dailyLogId: json['daily_log_id'],
      inletValue: json['inlet_value'],//.toDouble(),
      inletImage: json['inlet_image'],
      createdBy: json['created_by'],
      updatedAt: json['updated_at'],
      flowLogId: json['flow_log_id'],
      plantId: json['plant_id'],
      outletValue: json['outlet_value'],//.toDouble(),
      outletImage: json['outlet_image'],
      createdAt: json['created_at'],
      shift: json['shift'],
    );
  }
}

// BLoC
enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  final ReportStatus status;
  final ReportData? reportData;
  final String? errorMessage;
  final DateTime? startDate;
  final DateTime? endDate;

  ReportState({
    this.status = ReportStatus.initial,
    this.reportData,
    this.errorMessage,
    this.startDate,
    this.endDate,
  });

  ReportState copyWith({
    ReportStatus? status,
    ReportData? reportData,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ReportState(
      status: status ?? this.status,
      reportData: reportData ?? this.reportData,
      errorMessage: errorMessage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object?> get props => [status, reportData, errorMessage, startDate, endDate];
}

abstract class ReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportDateSelected extends ReportEvent {
  final DateTime startDate;
  final DateTime endDate;

  ReportDateSelected({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class ReportFetched extends ReportEvent {}

class DownloadPdf extends ReportEvent {
  final BuildContext context;

  DownloadPdf({required this.context});

  @override
  List<Object?> get props => [context];
}

class DownloadCsv extends ReportEvent {
  final BuildContext context;

  DownloadCsv({required this.context});

  @override
  List<Object?> get props => [context];
}

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  // Initialize Connectivity instance
  final Connectivity _connectivity = Connectivity();

  ReportBloc() : super(ReportState()) {
    on<ReportDateSelected>(_onDateSelected);
    on<ReportFetched>(_onReportFetched);
    on<DownloadPdf>(_onDownloadPdf);
    on<DownloadCsv>(_onDownloadCsv);
  }

  static String getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Working';
      case 1:
        return 'Not Working';
      case 2:
        return 'Under Maintenance';
      default:
        return 'Unknown';
    }
  }

  void _onDateSelected(ReportDateSelected event, Emitter<ReportState> emit) {
    emit(state.copyWith(
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _onReportFetched(ReportFetched event, Emitter<ReportState> emit) async {
    if (state.startDate == null || state.endDate == null) {
      emit(state.copyWith(
        status: ReportStatus.failure,
        errorMessage: 'Please select start and end dates',
      ));
      return;
    }

    // Check network connectivity
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(state.copyWith(
        status: ReportStatus.failure,
        errorMessage: 'No internet connection',
      ));
      return;
    }

    emit(state.copyWith(status: ReportStatus.loading));

    try {
      final token = await _getToken();
      if (token == null) {
        emit(state.copyWith(
          status: ReportStatus.failure,
          errorMessage: 'Authentication token not found',
        ));
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final plantId = prefs.getInt('plant_id');
      if (plantId == null) {
        emit(state.copyWith(
          status: ReportStatus.failure,
          errorMessage: 'Plant ID not found',
        ));
        return;
      }

      final response = await http.post(
        Uri.parse(AppConfig.alllogs),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'plant_id': plantId,
          'start_date': DateFormat('yyyy-MM-dd').format(state.startDate!),
          'end_date': DateFormat('yyyy-MM-dd').format(state.endDate!),
        }),
      );

      if (response.statusCode == 200) {
        final data = ReportData.fromJson(json.decode(response.body));
        emit(state.copyWith(
          status: ReportStatus.success,
          reportData: data,
          errorMessage: null,
        ));
      } else {
        print('Report fetch failed: ${response.statusCode}, body: ${response.body}');
        emit(state.copyWith(
          status: ReportStatus.failure,
          errorMessage: 'Failed to fetch report: ${response.statusCode}',
        ));
      }
    } catch (e) {
      print('Report fetch error: $e');
      emit(state.copyWith(
        status: ReportStatus.failure,
        errorMessage: 'Error fetching report: $e',
      ));
    }
  }

Future<void> _onDownloadPdf(DownloadPdf event, Emitter<ReportState> emit) async {
  if (state.startDate == null || state.endDate == null) {
    emit(state.copyWith(
      status: ReportStatus.failure,
      errorMessage: 'Please select start and end dates',
    ));
    return;
  }

  emit(state.copyWith(status: ReportStatus.loading));

  try {
    // Get token
    final token = await _getToken();
    if (token == null) {
      emit(state.copyWith(
        status: ReportStatus.failure,
      ));
      return;
    }

    // Get plant_id from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final plantId = prefs.getInt('plant_id');
    if (plantId == null) {
      emit(state.copyWith(
        status: ReportStatus.failure,
      ));
      return;
    }

    final startDate = DateFormat('yyyy-MM-dd').format(state.startDate!);
    final endDate = DateFormat('yyyy-MM-dd').format(state.endDate!);

    // Fetch report data (similar to _onReportFetched)
    final reportResponse = await http.post(
      Uri.parse(AppConfig.alllogs),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'plant_id': plantId,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );

    ReportData? reportData;
    if (reportResponse.statusCode == 200) {
      reportData = ReportData.fromJson(json.decode(reportResponse.body));
    } else {
      emit(state.copyWith(
        status: ReportStatus.failure,
        errorMessage: 'Failed to fetch report data: ${reportResponse.statusCode}',
      ));
      return;
    }

    // Download PDF
    final url = Uri.parse('${AppConfig.pdf}?plant_id=$plantId&start_date=$startDate&end_date=$endDate');
    final pdfResponse = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (pdfResponse.statusCode == 200) {
      try {
        final fileName = 'report_${startDate}_to_${endDate}.pdf';
        String? filePath;

        if (Platform.isAndroid) {
          filePath = await FilePicker.platform.saveFile(
            dialogTitle: 'Save PDF',
            fileName: fileName,
            bytes: pdfResponse.bodyBytes,
          );
        } else if (Platform.isIOS) {
          final directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(pdfResponse.bodyBytes);
        } else {
          throw Exception('Unsupported platform');
        }

        if (filePath != null) {
          if (Platform.isIOS) {
            final file = File(filePath);
            if (!await file.exists()) {
              throw Exception('File was not saved properly');
            }
          }

          emit(state.copyWith(
            status: ReportStatus.success,
            reportData: reportData,
          ));

          await Share.shareXFiles(
            [XFile(filePath)],
            text: 'Report Downloaded to $filePath',
          );
        } else {
          emit(state.copyWith(
            status: ReportStatus.failure,
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          status: ReportStatus.failure,
        ));
      }
    } else {
      emit(state.copyWith(
        status: ReportStatus.failure,
      ));
    }
  } catch (e) {
    emit(state.copyWith(
      status: ReportStatus.failure,
    ));
  }
}
Future<void> _onDownloadCsv(DownloadCsv event, Emitter<ReportState> emit) async {
  if (state.startDate == null || state.endDate == null) {
    emit(state.copyWith(
      status: ReportStatus.failure,
      errorMessage: 'Please select start and end dates',
    ));
    return;
  }

  emit(state.copyWith(status: ReportStatus.loading));

  try {
    // Get token
    final token = await _getToken();
    if (token == null) {
      emit(state.copyWith(
        status: ReportStatus.failure,
      ));
      return;
    }

    // Get plant_id from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final plantId = prefs.getInt('plant_id');
    if (plantId == null) {
      emit(state.copyWith(
        status: ReportStatus.failure,
      ));
      return;
    }

    final startDate = DateFormat('yyyy-MM-dd').format(state.startDate!);
    final endDate = DateFormat('yyyy-MM-dd').format(state.endDate!);

    // Fetch report data (similar to _onReportFetched)
    final reportResponse = await http.post(
      Uri.parse(AppConfig.alllogs),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'plant_id': plantId,
        'start_date': startDate,
        'end_date': endDate,
      }),
    );

    ReportData? reportData;
    if (reportResponse.statusCode == 200) {
      reportData = ReportData.fromJson(json.decode(reportResponse.body));
    } else {
      emit(state.copyWith(
        status: ReportStatus.failure,
        errorMessage: 'Failed to fetch report data: ${reportResponse.statusCode}',
      ));
      return;
    }

    // Download CSV
    final url = Uri.parse('${AppConfig.downcsv}?plant_id=$plantId&start_date=$startDate&end_date=$endDate');
    final csvResponse = await http.get(
      url,
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (csvResponse.statusCode == 200) {
      try {
        final fileName = 'report_${startDate}_to_${endDate}.csv';
        String? filePath;

        if (Platform.isAndroid) {
          filePath = await FilePicker.platform.saveFile(
            dialogTitle: 'Save CSV',
            fileName: fileName,
            bytes: csvResponse.bodyBytes,
          );
        } else if (Platform.isIOS) {
          final directory = await getApplicationDocumentsDirectory();
          filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(csvResponse.bodyBytes);
        } else {
          throw Exception('Unsupported platform');
        }

        if (filePath != null) {
          if (Platform.isIOS) {
            final file = File(filePath);
            if (!await file.exists()) {
              throw Exception('File was not saved properly');
            }
          }

          emit(state.copyWith(
            status: ReportStatus.success,
            reportData: reportData,
          ));

          await Share.shareXFiles(
            [XFile(filePath, mimeType: 'text/csv')],
            text: 'Report Downloaded to $filePath',
          );
        } else {
          emit(state.copyWith(
            status: ReportStatus.failure,
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          status: ReportStatus.failure,
        ));
      }
    } else {
      emit(state.copyWith(
        status: ReportStatus.failure,
      ));
    }
  } catch (e) {
    emit(state.copyWith(
      status: ReportStatus.failure,
    ));
  }
}
}

// UI Page
class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportBloc(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _DateSelectionSection(),
            const SizedBox(height: 16),
            _ReportContent(),
          ],
        ),
      ),
    );
  }
}

class _DateSelectionSection extends StatelessWidget {
  const _DateSelectionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReportBloc>().state;

    Future<void> _selectDateRange(BuildContext context) async {
      final initialDateRange = DateTimeRange(
        start: state.startDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: state.endDate ?? DateTime.now(),
      );

      final DateTimeRange? pickedDateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        initialDateRange: initialDateRange,
      );

      if (pickedDateRange != null) {
        context.read<ReportBloc>().add(
              ReportDateSelected(
                startDate: pickedDateRange.start,
                endDate: pickedDateRange.end,
              ),
            );
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Date Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.startDate != null && state.endDate != null
                        ? '${DateFormat('yyyy-MM-dd').format(state.startDate!)} to ${DateFormat('yyyy-MM-dd').format(state.endDate!)}'
                        : 'No date range selected',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: const Text('Select Dates'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<ReportBloc>().add(ReportFetched());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Generate Report'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: state.startDate != null && state.endDate != null
                  ? () => context.read<ReportBloc>().add(DownloadPdf(context: context))
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf),
                  SizedBox(width: 8),
                  Text('Download PDF'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasData) {
                  final role = snapshot.data!.getInt('role');
                  print('User role in UI: $role');
                  if (role == 1) {
                    return ElevatedButton(
                      onPressed: state.startDate != null && state.endDate != null
                          ? () => context.read<ReportBloc>().add(DownloadCsv(context: context))
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_download),
                          SizedBox(width: 8),
                          Text('Download CSV'),
                        ],
                      ),
                    );
                  } else {
                    print('CSV button hidden due to role: $role');
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportContent extends StatelessWidget {
  const _ReportContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReportBloc>().state;

    switch (state.status) {
      case ReportStatus.initial:
        return const Center(child: Text('Select dates and generate report'));
      case ReportStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ReportStatus.failure:
        return Center(child: Text(state.errorMessage ?? 'Select dates and generate report'));
      case ReportStatus.success:
        return Expanded(
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Chemicals'),
                    Tab(text: 'Equipment'),
                    Tab(text: 'Flow Parameters'),
                    Tab(text: 'Flow'),
                  ],
                  labelColor: Colors.black,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _ChemicalLogsTab(logs: state.reportData!.chemicalLogs),
                      _EquipmentLogsTab(logs: state.reportData!.equipmentLogs),
                      _FlowParameterLogsTab(logs: state.reportData!.flowParameterLogs),
                      _FlowLogsTab(logs: state.reportData!.flowLogs),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}

class _ChemicalLogsTab extends StatelessWidget {
  final List<ChemicalLog> logs;

  const _ChemicalLogsTab({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return logs.isEmpty
        ? const Center(child: Text('No chemical logs found'))
        : ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(log.chemicalName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity Used: ${log.quantityUsed}'),
                      Text('Quantity Left: ${log.quantityLeft}'),
                      Text('Shift: ${log.shift}'),
                      Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(log.createdAt))}'),
                    ],
                  ),
                  trailing: Text(
                    log.sludgeDischarge ? 'Sludge: Yes' : 'Sludge: No',
                    style: TextStyle(
                      color: log.sludgeDischarge ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          );
  }
}

class _EquipmentLogsTab extends StatelessWidget {
  final List<EquipmentLog> logs;

  const _EquipmentLogsTab({Key? key, required this.logs}) : super(key: key);

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Working';
      case 1:
        return 'Not Working';
      case 2:
        return 'Under Maintenance';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return logs.isEmpty
        ? const Center(child: Text('No equipment logs found'))
        : ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(log.equipmentName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${_getStatusText(log.equipmentStatus)}'),
                      Text('Maintenance Done: ${log.maintenanceDone ? 'Yes' : 'No'}'),
                      if (log.equipmentRemark != null)
                        Text('Remark: ${log.equipmentRemark}'),
                      Text('Shift: ${log.shift}'),
                      Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(log.createdAt))}'),
                    ],
                  ),
                  trailing: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getStatusColor(log.equipmentStatus),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
  }
}

class _FlowParameterLogsTab extends StatelessWidget {
  final List<FlowParameterLog> logs;

  const _FlowParameterLogsTab({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return logs.isEmpty
        ? const Center(child: Text('No flow parameter logs found'))
        : ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(log.parameterName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inlet Value: ${log.inletValue}'),
                      Text('Outlet Value: ${log.outletValue}'),
                      Text('Shift: ${log.shift}'),
                      Text('Daily Log ID: ${log.dailyLogId}'),
                      Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(log.createdAt))}'),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

class _FlowLogsTab extends StatelessWidget {
  final List<FlowLog> logs;

  const _FlowLogsTab({Key? key, required this.logs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return logs.isEmpty
        ? const Center(child: Text('No flow logs found'))
        : ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Flow Log #${log.flowLogId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inlet Value: ${log.inletValue}'),
                      Text('Outlet Value: ${log.outletValue}'),
                      Text('Shift: ${log.shift}'),
                      Text('Daily Log ID: ${log.dailyLogId}'),
                      Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(log.createdAt))}'),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

// Main entry point for the reports page
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ReportsPage();
  }
}
