import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:watershooters/bloc/createplant/createplant_bloc.dart';
import 'package:watershooters/bloc/createplant/createplant_state.dart';
import 'package:watershooters/bloc/plant/plant_bloc.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:watershooters/models/plant_type.dart';

class Etp extends StatefulWidget {
  final int plantTypeId;
  final String plantTypeName;

  const Etp({
    super.key,
    required this.plantTypeId,
    required this.plantTypeName,
  });

  @override
  State<Etp> createState() => _EtpState();
}

class _EtpState extends State<Etp> {
  late final PlantBloc _plantBloc;
  late final PlantCreateBloc _plantCreateBloc;
  int? userRole;

  @override
  void initState() {
    super.initState();
    _plantBloc = PlantBloc(plantRepo: PlantRepo(Dio()));
    _plantBloc.add(FetchPlantsByType(widget.plantTypeId));
    _plantCreateBloc = PlantCreateBloc(PlantRepository(Dio()));
    _loadUserRole();
  }

  void _showAddPlantDialog(BuildContext parentContext) {
    final nameController = TextEditingController();
    final clientIdController = TextEditingController();
    final operatorIdController = TextEditingController();
    final plantTypeIdController =
        TextEditingController(text: widget.plantTypeId.toString());
    final addressController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        // Use the _plantCreateBloc instance directly
        return BlocListener<PlantCreateBloc, PlantCreateState>(
          bloc: _plantCreateBloc,
          listener: (context, state) {
            if (state is PlantCreateLoading) {
              // Optionally show loading indicator
            } else if (state is PlantCreateSuccess) {
              Navigator.of(dialogContext).pop(); // Close dialog
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(content: Text("Plant created successfully")),
              );
              parentContext.read<PlantBloc>().add(FetchPlantsByType(widget.plantTypeId));
            } else if (state is PlantCreateFailure) {
              ScaffoldMessenger.of(parentContext).showSnackBar(
                SnackBar(content: Text("Error: "+state.error)),
              );
            }
          },
          child: AlertDialog(
            title: const Text("Add New Plant"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField("Plant Name", nameController),
                  _buildTextField("Client ID", clientIdController),
                  _buildTextField("Operator ID", operatorIdController),
                  _buildTextField("Plant Type ID", plantTypeIdController),
                  _buildTextField("Address", addressController),
                  _buildTextField("Plant Capacity", capacityController),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final plant = PlantModel(
                    plantName: nameController.text,
                    clientId: int.tryParse(clientIdController.text) ?? 0,
                    operatorId: int.tryParse(operatorIdController.text) ?? 0,
                    plantTypeId: int.tryParse(plantTypeIdController.text) ?? 0,
                    address: addressController.text,
                    plantCapacity: int.tryParse(capacityController.text) ?? 0,
                    operationalStatus: true,
                  );
                  _plantCreateBloc.add(SubmitPlant(plant));
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getInt('role');
    });
  }

  @override
  void dispose() {
    _plantBloc.close();
    _plantCreateBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _plantBloc,
        ),
        BlocProvider.value(
          value: _plantCreateBloc,
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: const CustomAppBar(),
        drawer: const CustomDrawer(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'SELECT YOUR WORKPLACE - ${widget.plantTypeName.toUpperCase()}',
                style: const TextStyle(
                  color: AppColors.darkblue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<PlantBloc, PlantState>(
                builder: (context, state) {
                  if (state is PlantLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is PlantError) {
                    return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: Colors.red)),
                    );
                  } else if (state is PlantLoaded) {
                    final plants = state.plantData;
                    return ListView.builder(
                      itemCount: plants.length,
                      itemBuilder: (context, index) {
                        final name =
                            plants[index]['plant_name'] ?? 'Unnamed Plant';
                        return Card(
                          color: AppColors.lightblue,
                          margin: const EdgeInsets.all(12.0),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(name,
                                style: const TextStyle(color: AppColors.cream)),
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setInt('plant_id', plants[index]['plant_id']);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.etpdata,
                                arguments: {
                                  'plantName': plants[index]['plant_name'],
                                  'plantId': plants[index]['plant_id'],
                                },
                              );
                            },
                            trailing: const Icon(Icons.arrow_forward_ios,
                                color: AppColors.yellowochre),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: Text('No data available'));
                },
              ),
            ),
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.darkblue),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
        floatingActionButton: userRole == 1
            ? FloatingActionButton(
                backgroundColor: AppColors.darkblue,
                onPressed: () {
                  _showAddPlantDialog(context);
                },
                child: const Icon(Icons.add, color: AppColors.yellowochre),
              )
            : null,
      ),
    );
  }
}
