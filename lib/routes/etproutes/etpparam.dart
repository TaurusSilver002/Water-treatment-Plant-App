import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';
import 'package:watershooters/bloc/plantparam_bloc.dart';
import 'package:watershooters/models/plantparam_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EtpParam extends StatefulWidget {
  const EtpParam({super.key});

  @override
  State<EtpParam> createState() => _EtpParamState();
}

class _EtpParamState extends State<EtpParam> {
  List<Map<String, dynamic>> paramData = [];
  late final PlantparamBloc _plantparamBloc;
  int? _userRole;

  @override
  void initState() {
    super.initState();
    _plantparamBloc = PlantparamBloc(repository: PlantParamRepository());
    _plantparamBloc.add(FetchPlantparam());
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
    _plantparamBloc.close();
    super.dispose();
  }

  void _updateParamData(List<Map<String, dynamic>> paramList) {
    setState(() {
      paramData = paramList.map((item) => {
        'name': item['parameter_name'] ?? 'Unknown',
        'target_value': item['target_value']?.toString() ?? 'N/A',
        'tolerance': item['tolerance']?.toString() ?? 'N/A',
        'unit': item['parameter_unit']?.toString() ?? 'N/A',
        'plant_flow_parameter_id': item['plant_flow_parameter_id']?.toString() ?? 'N/A',
        'plant_id': item['plant_id']?.toString() ?? 'N/A',
        'created_at': item['created_at']?.toString() ?? 'N/A',
        'updated_at': item['updated_at']?.toString() ?? 'N/A',
        'del_flag': item['del_flag']?.toString() ?? 'N/A',
      }).toList();
    });
  }

  void _addNewParam() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    final TextEditingController targetValueController = TextEditingController();
    final TextEditingController toleranceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Parameter'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Parameter Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: 'Parameter Unit'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetValueController,
                  decoration: const InputDecoration(labelText: 'Target Value'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: toleranceController,
                  decoration: const InputDecoration(labelText: 'Tolerance'),
                  keyboardType: TextInputType.number,
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
                  if (nameController.text.isNotEmpty &&
                      unitController.text.isNotEmpty &&
                      targetValueController.text.isNotEmpty &&
                      toleranceController.text.isNotEmpty) {
                    try {
                      await PlantParamRepository().addPlantParam(
                        parameterName: nameController.text,
                        parameterUnit: unitController.text,
                        targetValue: double.tryParse(targetValueController.text) ?? 0.0,
                        tolerance: double.tryParse(toleranceController.text) ?? 0.0,
                      );
                      _plantparamBloc.add(FetchPlantparam());
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Parameter added successfully')),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add parameter: $e')),
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
      value: _plantparamBloc,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: const CustomAppBar(),
        drawer: const CustomDrawer(),
        body: BlocListener<PlantparamBloc, PlantparamState>(
          listener: (context, state) {
            if (state is PlantparamLoaded) {
              _updateParamData(state.paramList);
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                BlocBuilder<PlantparamBloc, PlantparamState>(
                  builder: (context, state) {
                    if (state is PlantparamLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PlantparamError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paramData.length,
                      itemBuilder: (context, index) {
                        final item = paramData[index];
                        return Card(
                          color: AppColors.lightblue,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ExpansionTile(
                            iconColor: AppColors.yellowochre,
                            collapsedIconColor: AppColors.yellowochre,
                            leading: const Icon(Icons.tune, color: AppColors.yellowochre),
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
                                    Text('Target Value: ${item['target_value']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Tolerance: ${item['tolerance']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Unit: ${item['unit']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Plant Flow Parameter ID: ${item['plant_flow_parameter_id']}', style: const TextStyle(color: AppColors.cream)),
                                    const SizedBox(height: 8),
                                    Text('Plant ID: ${item['plant_id']}', style: const TextStyle(color: AppColors.cream)),
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
        floatingActionButton: (_userRole != 1)
            ? null
            : Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton(
                  backgroundColor: AppColors.darkblue,
                  onPressed: _addNewParam,
                  child: const Icon(Icons.add, color: AppColors.yellowochre),
                ),
              ),
      ),
    );
  }
}
