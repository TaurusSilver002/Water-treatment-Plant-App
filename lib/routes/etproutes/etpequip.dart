import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';
import 'package:watershooters/bloc/plantequip_bloc.dart';
import 'package:watershooters/models/plantequip_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EtpEquip extends StatefulWidget {
  const EtpEquip({super.key});

  @override
  State<EtpEquip> createState() => _EtpEquipState();
}

class _EtpEquipState extends State<EtpEquip> {
  List<Map<String, dynamic>> etpData = [];
  late final PlantequipBloc _plantequipBloc;
  int? _userRole;

  @override
  void initState() {
    super.initState();
    _plantequipBloc = PlantequipBloc(repository: PlantEquipRepository());
    _plantequipBloc.add(FetchPlantequip());
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getInt('role');
    });
  }

  @override
  void dispose() {
    _plantequipBloc.close();
    super.dispose();
  }

  void _updateEtpData(List<Map<String, dynamic>> equipList) {
    setState(() {
      etpData = equipList.map((item) => {
        'name': item['equipment_name'] ?? 'Unknown',
        'status': _statusToString(item['status']),
        'maintenance': item['last_maintenance'] ?? 'N/A',
        'plant_equipment_id': item['plant_equipment_id']?.toString() ?? 'N/A',
        'plant_id': item['plant_id']?.toString() ?? 'N/A',
        'equipment_type': item['equipment_type']?.toString() ?? 'N/A',
        'created_at': item['created_at']?.toString() ?? 'N/A',
        'updated_at': item['updated_at']?.toString() ?? 'N/A',
        'del_flag': item['del_flag']?.toString() ?? 'N/A',
      }).toList();
    });
  }

  String _statusToString(dynamic status) {
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ok':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _addNewEquipment() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    String selectedStatus = 'OK';
    final statusMap = {'OK': 0, 'Warning': 1, 'Critical': 2};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Equipment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Equipment Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Equipment Type'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: ['OK', 'Warning', 'Critical']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
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
                  if (nameController.text.isNotEmpty && typeController.text.isNotEmpty) {
                    try {
                      await PlantEquipRepository().addPlantequip(
                        equipmentName: nameController.text,
                        equipmentType: typeController.text,
                        status: statusMap[selectedStatus] ?? 0,
                      );
                      _plantequipBloc.add(FetchPlantequip());
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Equipment added successfully')),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add equipment: $e')),
                      );
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _plantequipBloc,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: const CustomAppBar(),
        drawer: const CustomDrawer(),
        body: BlocListener<PlantequipBloc, PlantequipState>(
          listener: (context, state) {
            if (state is PlantequipLoaded) {
              _updateEtpData(state.equipList);
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                BlocBuilder<PlantequipBloc, PlantequipState>(
                  builder: (context, state) {
                    if (state is PlantequipLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PlantequipError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: etpData.length,
                      itemBuilder: (context, index) {
                        final item = etpData[index];
                        return Card(
                          color: AppColors.lightblue,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ExpansionTile(
                            iconColor: AppColors.yellowochre,
                            collapsedIconColor: AppColors.yellowochre,
                            leading: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _getStatusColor(item['status']!),
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(
                              item['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.cream,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Status: ${item['status']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Last Maintenance: ${item['maintenance']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Plant Equipment ID: ${item['plant_equipment_id']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Plant ID: ${item['plant_id']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Equipment Type: ${item['equipment_type']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Created At: ${item['created_at']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Updated At: ${item['updated_at']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Deleted Flag: ${item['del_flag']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        floatingActionButton: (_userRole == 2)
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  backgroundColor: AppColors.darkblue,
                  onPressed: _addNewEquipment,
                  child: const Icon(Icons.add, color: AppColors.yellowochre),
                ),
              ),
      ),
    );
  }
}