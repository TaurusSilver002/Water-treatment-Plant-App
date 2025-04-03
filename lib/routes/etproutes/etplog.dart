import 'package:flutter/material.dart';
import 'package:waterplant/components/customAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';

class EtpLog extends StatefulWidget {
  const EtpLog({super.key});

  @override
  State<EtpLog> createState() => _EtpLogState();
}

class _EtpLogState extends State<EtpLog> {
  int _selectedTab = 0; // 0=Equipment, 1=Chemical, 2=Flow
  
  // Pre-populated dummy data
  final List<Map<String, String>> equipmentLogs = [
    {
      'name': 'A',
      'status': 'Working',
      'maintenance': 'Done',
      'shift': '1',
      'date': '2023-05-15 08:30',
    },
    {
      'name': 'B',
      'status': 'Maintenance',
      'maintenance': 'Not Done',
      'shift': '2',
      'date': '2023-05-14 14:15',
    },
    {
      'name': 'C',
      'status': 'Critical',
      'maintenance': 'Not Done',
      'shift': '3',
      'date': '2023-05-13 10:45',
    },
  ];

  final List<Map<String, String>> chemicalLogs = [
    {
      'name': 'A',
      'quantity': '79',
      'sludge': 'Yes',
      'shift': '1',
      'date': '2023-05-15 09:00',
    },
    {
      'name': 'B',
      'quantity': '79',
      'sludge': 'Yes',
      'shift': '1',
      'date': '2023-05-14 16:30',
    },
    {
      'name': 'C',
      'quantity': '79',
      'sludge': 'Yes',
      'shift': '1',
      'date': '2023-05-13 11:20',
    },
  ];

  final List<Map<String, String>> flowLogs = [
    {
      'name': 'A',
      'inlet': '40',
      'outlet': '13',
      'shift': '2',
      'date': '2023-05-15 07:45',
    },
    {
      'name': 'B',
      'inlet': '40',
      'outlet': '13',
      'shift': '2',
      'date': '2023-05-14 15:30',
    },
    {
      'name': 'C',
      'inlet': '40',
      'outlet': '13',
      'shift': '2',
      'date': '2023-05-13 12:15',
    },
  ];

  void _addNewEntry() {
    String selectedName = 'A';
    String selectedStatus = 'OK';
    String selectedMaintenance = 'Done';
    String selectedShift = '1';
    String selectedQuantity = '';
    String selectedSludge = 'Yes';
    String selectedInlet = '';
    String selectedOutlet = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedName.isNotEmpty) {
                      setState(() {
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
                      });
                      Navigator.pop(context);
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
    if (_selectedTab == 0) { // Equipment
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
          decoration: const InputDecoration(labelText: 'Equipment Name',iconColor: AppColors.yellowochre,),
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
    } else if (_selectedTab == 1) { // Chemical
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
          onChanged: (value) => selectedQuantity = value,
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
    } else { // Flow
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
          onChanged: (value) => selectedInlet = value,
          decoration: const InputDecoration(labelText: 'Inlet'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          onChanged: (value) => selectedOutlet = value,
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
      equipmentLogs.add(entry);
    } else if (_selectedTab == 1) {
      entry.addAll({
        'quantity': quantity,
        'sludge': sludge,
        'shift': shift,
      });
      chemicalLogs.add(entry);
    } else {
      entry.addAll({
        'inlet': inlet,
        'outlet': outlet,
        'shift': shift,
      });
      flowLogs.add(entry);
    }
    setState(() {});
  }

  Widget _buildLogList() {
    final currentList = _selectedTab == 0
        ? equipmentLogs
        : _selectedTab == 1
            ? chemicalLogs
            : flowLogs;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentList.length,
      itemBuilder: (context, index) {
        final entry = currentList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.lightblue,
          child: ExpansionTile(
            title: Text(
              entry['name']!,
              style: const TextStyle(color: AppColors.cream),
            ),
            iconColor: AppColors.yellowochre,
            collapsedIconColor: AppColors.yellowochre,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  }

  List<Widget> _buildDetailWidgets(Map<String, String> entry) {
    if (_selectedTab == 0) { // Equipment
      return [
        Text('Status: ${entry['status']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Maintenance: ${entry['maintenance']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Shift: ${entry['shift']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Date: ${entry['date']}', style: const TextStyle(color: AppColors.cream)),
      ];
    } else if (_selectedTab == 1) { // Chemical
      return [
        Text('Quantity: ${entry['quantity']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Sludge: ${entry['sludge']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Shift: ${entry['shift']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Date: ${entry['date']}', style: const TextStyle(color: AppColors.cream)),
      ];
    } else { // Flow
      return [
        Text('Inlet: ${entry['inlet']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Outlet: ${entry['outlet']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Shift: ${entry['shift']}', style: const TextStyle(color: AppColors.cream)),
        const SizedBox(height: 8),
        Text('Date: ${entry['date']}', style: const TextStyle(color: AppColors.cream)),
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
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: _selectedTab == index
            ? AppColors.darkblue
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _selectedTab == index
              ? AppColors.cream
              : AppColors.darkblue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}