import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterplant/bloc/equipmentlog/equipmentlog_bloc.dart';
import 'package:waterplant/bloc/chemicallog/chemicallog_bloc.dart';
import 'package:waterplant/bloc/flowlog/flowlog_bloc.dart';
import 'package:waterplant/components/customAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';
import 'package:waterplant/models/equiplog.dart';
import 'package:waterplant/models/chemicallog.dart';
import 'package:waterplant/models/flowlog.dart';

class EtpLog extends StatefulWidget {
  final EquipmentBloc? equipmentBloc; // Make equipmentBloc optional
  final ChemicallogBloc? chemicallogBloc;
  final FlowlogBloc? flowlogBloc;

  const EtpLog({super.key, this.equipmentBloc, this.chemicallogBloc, this.flowlogBloc});

  @override
  State<EtpLog> createState() => _EtpLogState();
}

class _EtpLogState extends State<EtpLog> {
  late final EquipmentBloc _equipmentBloc; // Local instance to use
  late final ChemicallogBloc _chemicallogBloc; // Local instance to use
  late final FlowlogBloc _flowlogBloc; // Local instance to use
  int _selectedTab = 0; // 0=Equipment, 1=Chemical, 2=Flow

  @override
  void initState() {
    super.initState();
    _equipmentBloc = widget.equipmentBloc ?? EquipmentBloc(repository: EquipmentRepository());
    _chemicallogBloc = widget.chemicallogBloc ?? ChemicallogBloc(repository: ChemicalLogRepository());
    _flowlogBloc = widget.flowlogBloc ?? FlowlogBloc(repository: FlowLogRepository());

    // Only load equipment logs if the default tab is equipment
    if (_selectedTab == 0) {
      _equipmentBloc.add(FetchEquipment());
    } else if (_selectedTab == 1) {
      _chemicallogBloc.add(FetchChemicallog());
    } else if (_selectedTab == 2) {
      _flowlogBloc.add(FetchFlowlog());
    }
  }

  void _addNewEntry() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String selectedName = 'A';
        String selectedStatus = 'OK';
        String selectedMaintenance = 'Done';
        String selectedShift = '1';
        String selectedQuantity = '';
        String selectedSludge = 'Yes';
        String selectedInlet = '';
        String selectedOutlet = '';

        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text(_getDialogTitle()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _getInputFields(
                    setState,
                    selectedName,
                    selectedStatus,
                    selectedMaintenance,
                    selectedShift,
                    selectedQuantity,
                    selectedSludge,
                    selectedInlet,
                    selectedOutlet,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedName.isNotEmpty) {
                      _addToSelectedList(
                        selectedName,
                        selectedStatus,
                        selectedMaintenance,
                        selectedShift,
                        selectedQuantity,
                        selectedSludge,
                        selectedInlet,
                        selectedOutlet,
                      );
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '${_selectedTab == 0 ? 'Equipment' : _selectedTab == 1 ? 'Chemical' : 'Flow'} log added'),
                        ),
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

  String _getDialogTitle() {
    switch (_selectedTab) {
      case 0:
        return 'Add Equipment Log';
      case 1:
        return 'Add Chemical Log';
      case 2:
        return 'Add Flow Log';
      default:
        return 'Add Log';
    }
  }

  List<Widget> _getInputFields(
    StateSetter setState,
    String selectedName,
    String selectedStatus,
    String selectedMaintenance,
    String selectedShift,
    String selectedQuantity,
    String selectedSludge,
    String selectedInlet,
    String selectedOutlet,
  ) {
    if (_selectedTab == 0) {
      return [
        DropdownButtonFormField<String>(
          value: selectedName,
          items: ['A', 'B', 'C'].map((name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedName = value!),
          decoration: const InputDecoration(
            labelText: 'Equipment Name',
            iconColor: AppColors.yellowochre,
          ),
        ),
        DropdownButtonFormField<String>(
          value: selectedStatus,
          items: ['OK', 'Critical', 'Warning'].map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedStatus = value!),
          decoration: const InputDecoration(labelText: 'Status'),
        ),
        DropdownButtonFormField<String>(
          value: selectedMaintenance,
          items: ['Done', 'Not Done'].map((maintenance) {
            return DropdownMenuItem(
              value: maintenance,
              child: Text(maintenance),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedMaintenance = value!),
          decoration: const InputDecoration(labelText: 'Maintenance'),
        ),
        DropdownButtonFormField<String>(
          value: selectedShift,
          items: ['1', '2', '3'].map((shift) {
            return DropdownMenuItem(
              value: shift,
              child: Text(shift),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedShift = value!),
          decoration: const InputDecoration(labelText: 'Shift'),
        ),
      ];
    } else if (_selectedTab == 1) {
      return [
        DropdownButtonFormField<String>(
          value: selectedName,
          items: ['A', 'B', 'C'].map((name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedName = value!),
          decoration: const InputDecoration(labelText: 'Chemical Name'),
        ),
        TextField(
          onChanged: (value) => setState(() => selectedQuantity = value),
          decoration: const InputDecoration(labelText: 'Quantity'),
          keyboardType: TextInputType.number,
        ),
        DropdownButtonFormField<String>(
          value: selectedSludge,
          items: ['Yes', 'No'].map((sludge) {
            return DropdownMenuItem(
              value: sludge,
              child: Text(sludge),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedSludge = value!),
          decoration: const InputDecoration(labelText: 'Sludge Discharge'),
        ),
        DropdownButtonFormField<String>(
          value: selectedShift,
          items: ['1', '2', '3'].map((shift) {
            return DropdownMenuItem(
              value: shift,
              child: Text(shift),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedShift = value!),
          decoration: const InputDecoration(labelText: 'Shift'),
        ),
      ];
    } else {
      return [
        DropdownButtonFormField<String>(
          value: selectedName,
          items: ['A', 'B', 'C'].map((name) {
            return DropdownMenuItem(
              value: name,
              child: Text(name),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedName = value!),
          decoration: const InputDecoration(labelText: 'Flow Name'),
        ),
        TextField(
          onChanged: (value) => setState(() => selectedInlet = value),
          decoration: const InputDecoration(labelText: 'Inlet'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          onChanged: (value) => setState(() => selectedOutlet = value),
          decoration: const InputDecoration(labelText: 'Outlet'),
          keyboardType: TextInputType.number,
        ),
        DropdownButtonFormField<String>(
          value: selectedShift,
          items: ['1', '2', '3'].map((shift) {
            return DropdownMenuItem(
              value: shift,
              child: Text(shift),
            );
          }).toList(),
          onChanged: (value) => setState(() => selectedShift = value!),
          decoration: const InputDecoration(labelText: 'Shift'),
        ),
      ];
    }
  }

  void _addToSelectedList(
    String name,
    String status,
    String maintenance,
    String shift,
    String quantity,
    String sludge,
    String inlet,
    String outlet,
  ) {
    final entry = {
      'name': name,
      'date': DateTime.now().toString().substring(0, 16),
    };

    if (_selectedTab == 0) {
      entry.addAll({
        'status': status,
        'maintenance': maintenance,
        'shift': shift,
      });
      _equipmentBloc.add(AddEquipmentLog(entry));
    } else if (_selectedTab == 1) {
      entry.addAll({
        'quantity': quantity,
        'sludge': sludge,
        'shift': shift,
      });
      _chemicallogBloc.add(AddChemicallog(entry));
    } else if (_selectedTab == 2) {
      entry.addAll({
        'inlet': inlet,
        'outlet': outlet,
        'shift': shift,
      });
      _flowlogBloc.add(AddFlowlog(entry));
    }
    setState(() {});
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildDetailWidgets(entry),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildDetailWidgets(entry),
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
    } else {
      return BlocBuilder<FlowlogBloc, FlowlogState>(
        bloc: _flowlogBloc,
        builder: (context, state) {
          if (state is FlowlogLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FlowlogLoaded) {
            final flowLogs = (state.flowlogData['logs'] as List<dynamic>?)
                    ?.map((log) => _mapBackendFlowLogToEntry(log))
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildDetailWidgets(entry),
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
      'name': log['chemical_remark'] ?? 'Chemical ${log['chemical_log_id'] ?? ''}',
      'quantity': log['quantity']?.toString() ?? 'N/A',
      'sludge': (log['sludge_discharge'] == true) ? 'Yes' : 'No',
      'shift': (log['shift'] != null) ? log['shift'].toString() : 'N/A',
      'date': _formatDate(log['start_date']),
    };
  }

  Map<String, String> _mapBackendFlowLogToEntry(dynamic log) {
    return {
      'name': log['flow_remark'] ?? 'Flow ${log['flow_log_id'] ?? ''}',
      'inlet': log['inlet']?.toString() ?? 'N/A',
      'outlet': log['outlet']?.toString() ?? 'N/A',
      'shift': (log['shift'] != null) ? log['shift'].toString() : 'N/A',
      'date': _formatDate(log['start_date']),
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
        Text('Quantity: ${entry['quantity']}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Sludge: ${entry['sludge']}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Shift: ${entry['shift']}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Date: ${entry['date']}',
            style: const TextStyle(color: AppColors.cream)),
      ];
    } else {
      return [
        Text('Inlet: ${entry['inlet']}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Outlet: ${entry['outlet']}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Shift: ${entry['shift']}',
            style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Date: ${entry['date']}',
            style: const TextStyle(color: AppColors.cream)),
      ];
    }
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
      floatingActionButton: FloatingActionButton(
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
          color:
              _selectedTab == index ? AppColors.cream : AppColors.darkblue,
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
    _flowlogBloc.close();
    super.dispose();
  }
}