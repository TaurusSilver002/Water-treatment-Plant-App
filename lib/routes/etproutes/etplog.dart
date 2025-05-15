import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watershooters/bloc/equipmentlog/equipmentlog_bloc.dart';
import 'package:watershooters/bloc/chemicallog/chemicallog_bloc.dart';
import 'package:watershooters/bloc/flowlog/flowlog_bloc.dart';
import 'package:watershooters/bloc/parameterlog/parameterlog_bloc.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';
import 'package:watershooters/models/equiplog.dart';
import 'package:watershooters/models/chemicallog.dart';
import 'package:watershooters/models/flowlog.dart';
import 'package:watershooters/models/parameterlog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EtpLog extends StatefulWidget {
  final EquipmentBloc? equipmentBloc;
  final ChemicallogBloc? chemicallogBloc;
  final FlowlogBloc? flowlogBloc;
  final ParameterlogBloc? parameterlogBloc;

  const EtpLog({super.key, this.equipmentBloc, this.chemicallogBloc, this.flowlogBloc, this.parameterlogBloc});

  @override
  State<EtpLog> createState() => _EtpLogState();
}

class _EtpLogState extends State<EtpLog> {
  late final EquipmentBloc _equipmentBloc;
  late final ChemicallogBloc _chemicallogBloc;
  late final FlowlogBloc _flowlogBloc;
  late final ParameterlogBloc _parameterlogBloc;
  int _selectedTab = 0; // 0=Equipment, 1=Chemical, 2=Flow, 3=Parameter
  int? _userRole;

  @override
  void initState() {
    super.initState();
    _equipmentBloc = widget.equipmentBloc ?? EquipmentBloc(repository: EquipmentRepository());
    _chemicallogBloc = widget.chemicallogBloc ?? ChemicallogBloc(repository: ChemicalLogRepository());
    _flowlogBloc = widget.flowlogBloc ?? FlowlogBloc(repository: FlowLogRepository());
    _parameterlogBloc = widget.parameterlogBloc ?? ParameterlogBloc(repository: ParameterLogRepository());
    _loadUserRole();
    if (_selectedTab == 0) {
      _equipmentBloc.add(FetchEquipment());
    } else if (_selectedTab == 1) {
      _chemicallogBloc.add(FetchChemicallog());
    } else if (_selectedTab == 2) {
      _flowlogBloc.add(FetchFlowlog());
    } else if (_selectedTab == 3) {
      _parameterlogBloc.add(FetchParameterlog());
    }
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getInt('role');
    });
  }

  void _addNewEntry() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // State for dialog fields
        int selectedEquipmentId = 0;
        int selectedStatus = 0; // 0=OK, 1=Warning, 2=Critical
        bool selectedMaintenanceDone = true;
        String selectedRemark = '';
        int selectedShift = 1;
        // --- Chemical log fields ---
        int selectedChemicalId = 0;
        String selectedQuantityUsed = '';
        String selectedQuantityLeft = '';
        bool selectedSludgeDischarge = false;
        int selectedChemicalShift = 1;
        // --- Flow log fields ---
        String selectedInletValue = '';
        String selectedOutletValue = '';
        String? inletImageBase64;
        String? outletImageBase64;
        int selectedFlowShift = 1;
        String? errorText;
        // --- Parameter log fields ---
        int selectedParameterId = 0;
        String selectedParameterValue = '';
        int selectedParameterShift = 1;

        Future<void> pickImage(bool isInlet) async {
          final ImagePicker picker = ImagePicker();
          // Show dialog to choose camera or gallery
          final source = await showDialog<ImageSource>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Select Image Source'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  child: const Text('Camera'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  child: const Text('Gallery'),
                ),
              ],
            ),
          );

          if (source == null) return;

          try {
            final XFile? image = await picker.pickImage(
              source: source,
              maxWidth: 800, // Resize to reduce size
              maxHeight: 800,
              imageQuality: 75, // Compress to balance quality and size
            );

            if (image != null) {
              final bytes = await File(image.path).readAsBytes();
              final base64Image = base64Encode(bytes);
              setState(() {
                if (isInlet) {
                  inletImageBase64 = base64Image;
                  errorText = null; // Clear any previous errors
                } else {
                  outletImageBase64 = base64Image;
                  errorText = null;
                }
                // Log size for debugging
                print('Base64 ${isInlet ? "inlet" : "outlet"} image size: ${base64Image.length} bytes');
              });
            }
          } catch (e) {
            setState(() {
              errorText = 'Error picking image: $e';
            });
            print('Image pick error: $e');
          }
        }

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text(_getDialogTitle()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedTab == 0) ...[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Equipment ID (int)'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            selectedEquipmentId = int.tryParse(val) ?? 0;
                          });
                        },
                      ),
                      DropdownButtonFormField<int>(
                        value: selectedStatus,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('OK')),
                          DropdownMenuItem(value: 1, child: Text('Warning')),
                          DropdownMenuItem(value: 2, child: Text('Critical')),
                        ],
                        onChanged: (val) => setState(() => selectedStatus = val ?? 0),
                        decoration: const InputDecoration(labelText: 'Equipment Status'),
                      ),
                      SwitchListTile(
                        title: const Text('Maintenance Done'),
                        value: selectedMaintenanceDone,
                        onChanged: (val) => setState(() => selectedMaintenanceDone = val),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Equipment Remark'),
                        onChanged: (val) => setState(() => selectedRemark = val),
                      ),
                      DropdownButtonFormField<int>(
                        value: selectedShift,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1')),
                          DropdownMenuItem(value: 2, child: Text('2')),
                          DropdownMenuItem(value: 3, child: Text('3')),
                        ],
                        onChanged: (val) => setState(() => selectedShift = val ?? 1),
                        decoration: const InputDecoration(labelText: 'Shift'),
                      ),
                    ] else if (_selectedTab == 1) ...[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Chemical ID (int)'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            selectedChemicalId = int.tryParse(val) ?? 0;
                          });
                        },
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Quantity Used'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() => selectedQuantityUsed = val),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Quantity Left'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() => selectedQuantityLeft = val),
                      ),
                      SwitchListTile(
                        title: const Text('Sludge Discharge'),
                        value: selectedSludgeDischarge,
                        onChanged: (val) => setState(() => selectedSludgeDischarge = val),
                      ),
                      DropdownButtonFormField<int>(
                        value: selectedChemicalShift,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1')),
                          DropdownMenuItem(value: 2, child: Text('2')),
                          DropdownMenuItem(value: 3, child: Text('3')),
                        ],
                        onChanged: (val) => setState(() => selectedChemicalShift = val ?? 1),
                        decoration: const InputDecoration(labelText: 'Shift'),
                      ),
                    ] else if (_selectedTab == 2) ...[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Inlet Value'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() => selectedInletValue = val),
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Outlet Value'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() => selectedOutletValue = val),
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => pickImage(true),
                            child: Text(inletImageBase64 == null ? 'Add Inlet Image' : 'Change Inlet Image'),
                          ),
                          if (inletImageBase64 != null)
                            const Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () => pickImage(false),
                            child: Text(outletImageBase64 == null ? 'Add Outlet Image' : 'Change Outlet Image'),
                          ),
                          if (outletImageBase64 != null)
                            const Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                      DropdownButtonFormField<int>(
                        value: selectedFlowShift,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1')),
                          DropdownMenuItem(value: 2, child: Text('2')),
                          DropdownMenuItem(value: 3, child: Text('3')),
                        ],
                        onChanged: (val) => setState(() => selectedFlowShift = val ?? 1),
                        decoration: const InputDecoration(labelText: 'Shift'),
                      ),
                    ] else if (_selectedTab == 3) ...[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Parameter ID (int)'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            selectedParameterId = int.tryParse(val) ?? 0;
                          });
                        },
                      ),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Value'),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => setState(() => selectedParameterValue = val),
                      ),
                      DropdownButtonFormField<int>(
                        value: selectedParameterShift,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1')),
                          DropdownMenuItem(value: 2, child: Text('2')),
                          DropdownMenuItem(value: 3, child: Text('3')),
                        ],
                        onChanged: (val) => setState(() => selectedParameterShift = val ?? 1),
                        decoration: const InputDecoration(labelText: 'Shift'),
                      ),
                    ],
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(errorText!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final plantId = prefs.getInt('plant_id') ?? 0;
                    if (_selectedTab == 0) {
                      if (selectedEquipmentId <= 0 || selectedRemark.isEmpty) {
                        setState(() => errorText = 'Please fill all required fields.');
                        return;
                      }
                      final entry = {
                        'plant_id': plantId,
                        'plant_equipment_id': selectedEquipmentId,
                        'status': selectedStatus,
                        'maintenance_done': selectedMaintenanceDone,
                        'equipment_remark': selectedRemark,
                        'shift': selectedShift,
                      };
                      _addEquipmentLogEntry(entry);
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Equipment log added')),
                      );
                    } else if (_selectedTab == 1) {
                      if (selectedChemicalId <= 0 || selectedQuantityUsed.isEmpty || selectedQuantityLeft.isEmpty) {
                        setState(() => errorText = 'Please fill all required fields.');
                        return;
                      }
                      final entry = {
                        'plant_id': plantId,
                        'plant_chemical_id': selectedChemicalId,
                        'quantity_used': selectedQuantityUsed,
                        'quantity_left': selectedQuantityLeft,
                        'sludge_discharge': selectedSludgeDischarge,
                        'shift': selectedChemicalShift,
                      };
                      _addChemicalLogEntry(entry);
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chemical log added')),
                      );
                    } else if (_selectedTab == 2) {
                      if (selectedInletValue.isEmpty || selectedOutletValue.isEmpty) {
                        setState(() => errorText = 'Please fill all required fields.');
                        return;
                      }
                      final entry = {
                        'plant_id': plantId,
                        'inlet_value': selectedInletValue,
                        'outlet_value': selectedOutletValue,
                        'inlet_image': inletImageBase64,
                        'outlet_image': outletImageBase64,
                        'shift': selectedFlowShift,
                      };
                      _addFlowLogEntry(entry);
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Flow log added')),
                      );
                    } else if (_selectedTab == 3) {
                      if (selectedParameterId <= 0 || selectedParameterValue.isEmpty) {
                        setState(() => errorText = 'Please fill all required fields.');
                        return;
                      }
                      final entry = {
                        'plant_id': plantId,
                        'plant_flow_parameter_id': selectedParameterId,
                        'value': selectedParameterValue,
                        'shift': selectedParameterShift,
                      };
                      _addParameterLogEntry(entry);
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Parameter log added')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addEquipmentLogEntry(Map<String, dynamic> entry) {
    _equipmentBloc.add(AddEquipmentLog(entry));
    setState(() {});
  }

  void _addChemicalLogEntry(Map<String, dynamic> entry) {
    _chemicallogBloc.add(AddChemicallog(entry));
    setState(() {});
  }

  void _addFlowLogEntry(Map<String, dynamic> entry) {
    _flowlogBloc.add(AddFlowlog(entry));
    setState(() {});
  }

  void _addParameterLogEntry(Map<String, dynamic> entry) {
    _parameterlogBloc.add(AddParameterlog(entry));
    setState(() {});
  }

  String _getDialogTitle() {
    switch (_selectedTab) {
      case 0:
        return 'Add Equipment Log';
      case 1:
        return 'Add Chemical Log';
      case 2:
        return 'Add Flow Log';
      case 3:
        return 'Add Parameter Log';
      default:
        return 'Add Log';
    }
  }

  Widget _buildLogList() {
    if (_selectedTab == 0) {
      return BlocBuilder<EquipmentBloc, EquipmentState>(
        bloc: _equipmentBloc,
        builder: (context, state) {
          if (state is EquipmentLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EquipmentLoaded) {
            final equipmentLogs = (state.equipmentData['logs'] as List<dynamic>?)
                    ?.map((log) => _mapBackendLogToEntry(log))
                    .toList() ??
                [];
            if (equipmentLogs.isEmpty) {
              return const Center(child: Text('No equipment logs available'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: equipmentLogs.length,
              itemBuilder: (context, index) {
                final entry = equipmentLogs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.lightblue,
                  child: ExpansionTile(
                    title: Text(
                      entry['name'] ?? 'Unknown',
                      style: const TextStyle(color: AppColors.cream),
                    ),
                    iconColor: AppColors.yellowochre,
                    collapsedIconColor: AppColors.yellowochre,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._buildDetailWidgets(entry),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.yellowochre,
                                  foregroundColor: AppColors.darkblue,
                                ),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      // Extract current values from entry
                                      int statusVal = _statusStringToInt(entry['status'] ?? 'OK');
                                      bool maintenanceVal = (entry['maintenance'] == 'Done');
                                      int shiftVal = int.tryParse(entry['shift'] ?? '') ?? 1;
                                      // Defensive: ensure statusVal and shiftVal are valid
                                      final statusOptions = [0, 1, 2];
                                      final shiftOptions = [1, 2, 3];
                                      if (!statusOptions.contains(statusVal)) statusVal = 0;
                                      if (!shiftOptions.contains(shiftVal)) shiftVal = 1;
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('Edit Equipment Log'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                DropdownButtonFormField<int>(
                                                  value: statusVal,
                                                  items: const [
                                                    DropdownMenuItem(value: 0, child: Text('OK')),
                                                    DropdownMenuItem(value: 1, child: Text('Warning')),
                                                    DropdownMenuItem(value: 2, child: Text('Critical')),
                                                  ],
                                                  onChanged: (val) => setState(() {
                                                    statusVal = val ?? 0;
                                                  }),
                                                  decoration: const InputDecoration(labelText: 'Equipment Status'),
                                                ),
                                                SwitchListTile(
                                                  title: const Text('Maintenance Done'),
                                                  value: maintenanceVal,
                                                  onChanged: (val) => setState(() => maintenanceVal = val),
                                                ),
                                                DropdownButtonFormField<int>(
                                                  value: shiftVal,
                                                  items: const [
                                                    DropdownMenuItem(value: 1, child: Text('1')),
                                                    DropdownMenuItem(value: 2, child: Text('2')),
                                                    DropdownMenuItem(value: 3, child: Text('3')),
                                                  ],
                                                  onChanged: (val) => setState(() => shiftVal = val ?? 1),
                                                  decoration: const InputDecoration(labelText: 'Shift'),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    // Extract equipment_log_id from entry['name'] or another unique field
                                                    final equipmentLogId = _extractEquipmentLogId(entry['name'] ?? '');
                                                    if (equipmentLogId != null) {
                                                      await EquipmentRepository().editEquipmentLog(
                                                        equipmentLogId: equipmentLogId,
                                                        equipmentStatus: statusVal,
                                                        maintenanceDone: maintenanceVal,
                                                        shift: shiftVal,
                                                      );
                                                      _equipmentBloc.add(FetchEquipment());
                                                    }
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Equipment log updated')),
                                                    );
                                                  } catch (e) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to update: $e')),
                                                    );
                                                  }
                                                },
                                                child: const Text('Done'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is EquipmentError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => _equipmentBloc.add(FetchEquipment()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
      );
    } else if (_selectedTab == 1) {
      return BlocBuilder<ChemicallogBloc, ChemicallogState>(
        bloc: _chemicallogBloc,
        builder: (context, state) {
          if (state is ChemicallogLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChemicallogLoaded) {
            final chemicalLogs = (state.chemicallogData['logs'] as List<dynamic>?)
                    ?.map((log) => _mapBackendChemicalLogToEntry(log))
                    .toList() ??
                [];
            if (chemicalLogs.isEmpty) {
              return const Center(child: Text('No chemical logs available'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: chemicalLogs.length,
              itemBuilder: (context, index) {
                final entry = chemicalLogs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.lightblue,
                  child: ExpansionTile(
                    title: Text(
                      entry['name'] ?? 'Unknown',
                      style: const TextStyle(color: AppColors.cream),
                    ),
                    iconColor: AppColors.yellowochre,
                    collapsedIconColor: AppColors.yellowochre,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._buildDetailWidgets(entry),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.yellowochre,
                                  foregroundColor: AppColors.darkblue,
                                ),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      // Defensive parse for preloaded values
                                      double quantityUsed = double.tryParse(entry['quantity_consumed'] ?? '') ?? 0;
                                      double quantityLeft = double.tryParse(entry['quantity_left'] ?? '') ?? 0;
                                      bool sludgeDischarge = (entry['sludge_discharge'] == 'true');
                                      int shiftVal = int.tryParse(entry['shift'] ?? '') ?? 1;
                                      final shiftOptions = [1, 2, 3];
                                      if (!shiftOptions.contains(shiftVal)) shiftVal = 1;
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('Edit Chemical Log'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  initialValue: quantityUsed.toString(),
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(labelText: 'Quantity Used'),
                                                  onChanged: (val) => setState(() => quantityUsed = double.tryParse(val) ?? 0),
                                                ),
                                                TextFormField(
                                                  initialValue: quantityLeft.toString(),
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(labelText: 'Quantity Left'),
                                                  onChanged: (val) => setState(() => quantityLeft = double.tryParse(val) ?? 0),
                                                ),
                                                SwitchListTile(
                                                  title: const Text('Sludge Discharge'),
                                                  value: sludgeDischarge,
                                                  onChanged: (val) => setState(() => sludgeDischarge = val),
                                                ),
                                                DropdownButtonFormField<int>(
                                                  value: shiftVal,
                                                  items: const [
                                                    DropdownMenuItem(value: 1, child: Text('1')),
                                                    DropdownMenuItem(value: 2, child: Text('2')),
                                                    DropdownMenuItem(value: 3, child: Text('3')),
                                                  ],
                                                  onChanged: (val) => setState(() => shiftVal = val ?? 1),
                                                  decoration: const InputDecoration(labelText: 'Shift'),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    // Extract chemical_log_id from entry['name']
                                                    final chemicalLogId = _extractChemicalLogId(entry['name'] ?? '');
                                                    if (chemicalLogId != null) {
                                                      await ChemicalLogRepository().editChemicalLog(
                                                        chemicalLogId: chemicalLogId,
                                                        quantityUsed: quantityUsed,
                                                        quantityLeft: quantityLeft,
                                                        sludgeDischarge: sludgeDischarge,
                                                        shift: shiftVal,
                                                      );
                                                      _chemicallogBloc.add(FetchChemicallog());
                                                    }
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Chemical log updated')),
                                                    );
                                                  } catch (e) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to update: $e')),
                                                    );
                                                  }
                                                },
                                                child: const Text('Done'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is ChemicallogError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => _chemicallogBloc.add(FetchChemicallog()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
      );
    } else if (_selectedTab == 2) {
      return BlocBuilder<FlowlogBloc, FlowlogState>(
        bloc: _flowlogBloc,
        builder: (context, state) {
          if (state is FlowlogLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FlowlogLoaded) {
            final flowLogs = (state.flowlogData['logs'] as List<dynamic>?)
                    ?.map((log) => _mapBackendFlowLogToEntry(log))
                    .where((entry) => entry.isNotEmpty)
                    .toList() ??
                [];
            if (flowLogs.isEmpty) {
              return const Center(child: Text('No flow logs available'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: flowLogs.length,
              itemBuilder: (context, index) {
                final entry = flowLogs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.lightblue,
                  child: ExpansionTile(
                    title: Text(
                      entry['name'] ?? 'Unknown',
                      style: const TextStyle(color: AppColors.cream),
                    ),
                    iconColor: AppColors.yellowochre,
                    collapsedIconColor: AppColors.yellowochre,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._buildDetailWidgets(entry),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.yellowochre,
                                  foregroundColor: AppColors.darkblue,
                                ),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      double inletValue = double.tryParse(entry['inlet'] ?? '') ?? 0;
                                      double outletValue = double.tryParse(entry['outlet'] ?? '') ?? 0;
                                      int shiftVal = int.tryParse(entry['shift'] ?? '') ?? 1;
                                      final shiftOptions = [1, 2, 3];
                                      if (!shiftOptions.contains(shiftVal)) shiftVal = 1;
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('Edit Flow Log'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  initialValue: inletValue.toString(),
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(labelText: 'Inlet Value'),
                                                  onChanged: (val) => setState(() => inletValue = double.tryParse(val) ?? 0),
                                                ),
                                                TextFormField(
                                                  initialValue: outletValue.toString(),
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(labelText: 'Outlet Value'),
                                                  onChanged: (val) => setState(() => outletValue = double.tryParse(val) ?? 0),
                                                ),
                                                DropdownButtonFormField<int>(
                                                  value: shiftVal,
                                                  items: const [
                                                    DropdownMenuItem(value: 1, child: Text('1')),
                                                    DropdownMenuItem(value: 2, child: Text('2')),
                                                    DropdownMenuItem(value: 3, child: Text('3')),
                                                  ],
                                                  onChanged: (val) => setState(() => shiftVal = val ?? 1),
                                                  decoration: const InputDecoration(labelText: 'Shift'),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    final flowLogId = _extractFlowLogId(entry['name'] ?? '');
                                                    if (flowLogId != null) {
                                                      await FlowLogRepository().editFlowLog(
                                                        flowLogId: flowLogId,
                                                        inletValue: inletValue,
                                                        outletValue: outletValue,
                                                        shift: shiftVal,
                                                      );
                                                      _flowlogBloc.add(FetchFlowlog());
                                                    }
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Flow log updated')),
                                                    );
                                                  } catch (e) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to update: $e')),
                                                    );
                                                  }
                                                },
                                                child: const Text('Done'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is FlowlogError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => _flowlogBloc.add(FetchFlowlog()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
      );
    } else {
      return BlocBuilder<ParameterlogBloc, ParameterlogState>(
        bloc: _parameterlogBloc,
        builder: (context, state) {
          if (state is ParameterlogLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ParameterlogLoaded) {
            final parameterLogs = (state.parameterlogData['logs'] as List<dynamic>? ?? [])
                .map((log) => _mapBackendParameterLogToEntry(log))
                .toList();
            if (parameterLogs.isEmpty) {
              return const Center(child: Text('No parameter logs available'));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: parameterLogs.length,
              itemBuilder: (context, index) {
                final entry = parameterLogs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.lightblue,
                  child: ExpansionTile(
                    title: Text(
                      entry['name'] ?? 'Unknown',
                      style: const TextStyle(color: AppColors.cream),
                    ),
                    iconColor: AppColors.yellowochre,
                    collapsedIconColor: AppColors.yellowochre,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._buildDetailWidgets(entry),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.yellowochre,
                                  foregroundColor: AppColors.darkblue,
                                ),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      double value = double.tryParse(entry['value'] ?? '') ?? 0;
                                      int shiftVal = int.tryParse(entry['shift'] ?? '') ?? 1;
                                      final shiftOptions = [1, 2, 3];
                                      if (!shiftOptions.contains(shiftVal)) shiftVal = 1;
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            title: const Text('Edit Parameter Log'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  initialValue: value.toString(),
                                                  keyboardType: TextInputType.number,
                                                  decoration: const InputDecoration(labelText: 'Value'),
                                                  onChanged: (val) => setState(() => value = double.tryParse(val) ?? 0),
                                                ),
                                                DropdownButtonFormField<int>(
                                                  value: shiftVal,
                                                  items: const [
                                                    DropdownMenuItem(value: 1, child: Text('1')),
                                                    DropdownMenuItem(value: 2, child: Text('2')),
                                                    DropdownMenuItem(value: 3, child: Text('3')),
                                                  ],
                                                  onChanged: (val) => setState(() => shiftVal = val ?? 1),
                                                  decoration: const InputDecoration(labelText: 'Shift'),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    final paramLogId = _extractParameterLogId(entry['name'] ?? '');
                                                    if (paramLogId != null) {
                                                      await ParameterLogRepository().editParameterLog(
                                                        flowParameterLogId: paramLogId,
                                                        value: value,
                                                        shift: shiftVal,
                                                      );
                                                      _parameterlogBloc.add(FetchParameterlog());
                                                    }
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(content: Text('Parameter log updated')),
                                                    );
                                                  } catch (e) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Failed to update: $e')),
                                                    );
                                                  }
                                                },
                                                child: const Text('Done'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is ParameterlogError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => _parameterlogBloc.add(FetchParameterlog()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No data available'));
        },
      );
    }
  }

  Map<String, String> _mapBackendLogToEntry(dynamic log) {
    return {
      'name': log['equipment_remark'] ?? 'Equipment ${log['equipment_log_id'] ?? ''}',
      'status': _mapStatus(log['equipment_status'] ?? 0),
      'maintenance': (log['maintenance_done'] == true) ? 'Done' : 'Not Done',
      'shift': (log['shift'] != null) ? log['shift'].toString() : 'N/A',
      'date': _formatDate(log['start_date']),
    };
  }

  Map<String, String> _mapBackendChemicalLogToEntry(dynamic log) {
    return {
      'name': 'Chemical Log ${log['chemical_log_id'] ?? ''}',
      'quantity_left': log['quantity_left']?.toString() ?? 'N/A',
      'quantity_consumed': log['quantity_consumed']?.toString() ?? 'N/A',
      'sludge_discharge': (log['sludge_discharge'] == true) ? 'true' : 'false',
      'shift': (log['shift'] != null) ? log['shift'].toString() : 'N/A',
      'date': _formatDate(log['created_at']),
    };
  }

  Map<String, String> _mapBackendFlowLogToEntry(dynamic log) {
    if (log['del_flag'] == true) {
      return {};
    }
    return {
      'name': log['flow_remark'] ?? 'Flow ${log['flow_log_id'] ?? ''}',
      'inlet': log['inlet_value']?.toString() ?? 'N/A',
      'outlet': log['outlet_value']?.toString() ?? 'N/A',
      'shift': (log['shift'] != null) ? log['shift'].toString() : 'N/A',
      'date': _formatDate(log['start_date']),
      'inlet_image': log['inlet_image']?.toString() ?? 'N/A',
      'outlet_image': log['outlet_image']?.toString() ?? 'N/A',
    };
  }

  Map<String, String> _mapBackendParameterLogToEntry(dynamic log) {
    return {
      'name': 'Parameter Log ${log['flow_parameter_log_id'] ?? ''}',
      'value': log['value']?.toString() ?? 'N/A',
      'shift': (log['shift'] != null) ? log['shift'].toString() : 'N/A',
      'date': _formatDate(log['created_at']),
    };
  }

  String _mapStatus(int status) {
    switch (status) {
      case 0:
        return 'OK';
      case 1:
        return 'Warning';
      case 2:
        return 'Critical';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date).toLocal();
      return dateTime.toString().substring(0, 16);
    } catch (_) {
      return 'N/A';
    }
  }

  List<Widget> _buildDetailWidgets(Map<String, String> entry) {
    if (_selectedTab == 0) {
      return [
        Text('Status: ${entry['status'] ?? 'N/A'}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Maintenance: ${entry['maintenance'] ?? 'N/A'}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Shift: ${entry['shift'] ?? 'N/A'}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Date: ${entry['date'] ?? 'N/A'}',
            style: const TextStyle(color: AppColors.cream)),
      ];
    } else if (_selectedTab == 1) {
      return [
        Text('Quantity Left: ${entry['quantity_left']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Quantity Consumed: ${entry['quantity_consumed']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Sludge Discharge: ${entry['sludge_discharge']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Shift: ${entry['shift']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Date: ${entry['date']}', style: const TextStyle(color: AppColors.cream)),
      ];
    } else if (_selectedTab == 2) {
      return [
        Text('Inlet: ${entry['inlet']}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        if (entry['inlet_image'] != 'N/A') ...[
          const Text('Inlet Image:',
              style: TextStyle(color: AppColors.cream)),
          const SizedBox(height: 8),
          CachedNetworkImage(
            imageUrl: entry['inlet_image']!,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Text('Error loading image',
                    style: TextStyle(color: AppColors.cream)),
          ),
          const SizedBox(height: 8),
        ],
        Text('Outlet: ${entry['outlet']}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        if (entry['outlet_image'] != 'N/A') ...[
          const Text('Outlet Image:',
              style: TextStyle(color: AppColors.cream)),
          const SizedBox(height: 8),
          CachedNetworkImage(
            imageUrl: entry['outlet_image']!,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) =>
                const Text('Error loading image',
                    style: TextStyle(color: AppColors.cream)),
          ),
          const SizedBox(height: 8),
        ],
        Text('Shift: ${entry['shift']}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Date: ${entry['date']}',
            style: const TextStyle(color: AppColors.cream)),
      ];
    } else {
      return [
        Text('Value: ${entry['value']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Shift: ${entry['shift']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Date: ${entry['date']}', style: const TextStyle(color: AppColors.cream)),
      ];
    }
  }

  int _statusStringToInt(String status) {
    switch (status.toLowerCase()) {
      case 'ok':
        return 0;
      case 'warning':
        return 1;
      case 'critical':
        return 2;
      default:
        return 0;
    }
  }

  int? _extractEquipmentLogId(String name) {
    final match = RegExp(r'(\d+)').firstMatch(name);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  int? _extractChemicalLogId(String name) {
    final match = RegExp(r'(\d+)').firstMatch(name);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  int? _extractFlowLogId(String name) {
    final match = RegExp(r'(\d+)').firstMatch(name);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  int? _extractParameterLogId(String name) {
    final match = RegExp(r'(\d+)').firstMatch(name);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabButton(0, 'Equipment'),
              _buildTabButton(1, 'Chemical'),
              _buildTabButton(2, 'Flow'),
              _buildTabButton(3, 'Parameter'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildLogList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: (_userRole == 2)
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.darkblue,
              onPressed: _addNewEntry,
              child: const Icon(Icons.add, color: AppColors.yellowochre),
            ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTab = index;
          if (index == 0) {
            _equipmentBloc.add(FetchEquipment());
          } else if (index == 1) {
            _chemicallogBloc.add(FetchChemicallog());
          } else if (index == 2) {
            _flowlogBloc.add(FetchFlowlog());
          } else if (index == 3) {
            _parameterlogBloc.add(FetchParameterlog());
          }
        });
      },
      style: TextButton.styleFrom(
        backgroundColor:
            _selectedTab == index ? AppColors.darkblue : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _selectedTab == index ? AppColors.cream : AppColors.darkblue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.equipmentBloc == null) {
      _equipmentBloc.close();
    }
    if (widget.chemicallogBloc == null) {
      _chemicallogBloc.close();
    }
    if (widget.flowlogBloc == null) {
      _flowlogBloc.close();
    }
    if (widget.parameterlogBloc == null) {
      _parameterlogBloc.close();
    }
    super.dispose();
  }
}