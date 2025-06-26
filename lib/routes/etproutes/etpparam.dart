import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';
import 'package:watershooters/bloc/plantparam/plantparam_bloc.dart';
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
      print('User role: $_userRole'); // Debug print
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
      print('Parameters updated: ${paramData.length} items'); // Debug print
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
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
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

  void _editParameter(String plantFlowParameterId, String parameterName, String parameterUnit, String targetValue, String tolerance) async {
    final paramId = int.tryParse(plantFlowParameterId);
    if (paramId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid parameter ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Editing parameter ID: $paramId'); // Debug print

    final TextEditingController nameController = TextEditingController(text: parameterName);
    // final TextEditingController unitController = TextEditingController(text: parameterUnit == 'N/A' ? '' : parameterUnit);
    // final TextEditingController targetValueController = TextEditingController(text: targetValue == 'N/A' ? '' : targetValue);
    // final TextEditingController toleranceController = TextEditingController(text: tolerance == 'N/A' ? '' : tolerance);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Parameter'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Parameter Name'),
                ),
                const SizedBox(height: 16),
                // TextField(
                //   controller: unitController,
                //   decoration: const InputDecoration(labelText: 'Parameter Unit'),
                // ),
                // const SizedBox(height: 16),
                // TextField(
                //   controller: targetValueController,
                //   decoration: const InputDecoration(labelText: 'Target Value'),
                //   keyboardType: TextInputType.number,
                // ),
                // const SizedBox(height: 16),
                // TextField(
                //   controller: toleranceController,
                //   decoration: const InputDecoration(labelText: 'Tolerance'),
                //   keyboardType: TextInputType.number,
                // ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty 
                  // &&
                  //     unitController.text.isNotEmpty &&
                  //     targetValueController.text.isNotEmpty &&
                  //     toleranceController.text.isNotEmpty
                      ) {
                    try {
                      await PlantParamRepository().editparameter(
                        plant_flow_parameter_id: paramId,
                        parameter_name: nameController.text,
                      
                      );
                      _plantparamBloc.add(FetchPlantparam());
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Parameter updated successfully')),
                      );
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to edit parameter: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteParameter(String plantFlowParameterId, String parameterName) async {
    final paramId = int.tryParse(plantFlowParameterId);
    if (paramId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid parameter ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Deleting parameter ID: $paramId'); // Debug print

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Parameter'),
        content: Text('Are you sure you want to delete "$parameterName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final repository = PlantParamRepository();
      final success = await repository.deleteparam(paramId);

      // Hide loading indicator
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parameter deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _plantparamBloc.add(FetchPlantparam());
      } else {
        throw Exception('Failed to delete parameter');
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting parameter: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                    if (paramData.isEmpty) {
                      return const Center(child: Text('No parameters available'));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: paramData.length,
                      itemBuilder: (context, index) {
                        final item = paramData[index];
                        print('Rendering parameter: ${item['name']}, ID: ${item['plant_flow_parameter_id']}'); // Debug print
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
                                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
                                    if (_userRole == 1) ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.edit, size: 18),
                                            label: const Text('Edit'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.darkblue,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(100, 36),
                                            ),
                                            onPressed: () => _editParameter(
                                              item['plant_flow_parameter_id']!,
                                              item['name']!,
                                              item['unit']!,
                                              item['target_value']!,
                                              item['tolerance']!,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton.icon(
                                            icon: const Icon(Icons.delete, size: 18),
                                            label: const Text('Delete'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(100, 36),
                                            ),
                                            onPressed: () => _deleteParameter(item['plant_flow_parameter_id']!, item['name']!),
                                          ),
                                        ],
                                      ),
                                    ],
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