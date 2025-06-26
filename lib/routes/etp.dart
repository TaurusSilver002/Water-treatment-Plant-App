import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:watershooters/bloc/alluser/get_all_user_bloc.dart';
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
    Key? key,
    required this.plantTypeId,
    required this.plantTypeName,
  }) : super(key: key);

  @override
  State<Etp> createState() => _EtpState();
}

class _EtpState extends State<Etp> {
  late final PlantBloc _plantBloc;
  late final PlantCreateBloc _plantCreateBloc;
  late final GetAllUserBloc _clientBloc;
  late final GetAllUserBloc _operatorBloc;

  int? userRole;
  List<int> selectedClientIds = [];
  List<int> selectedOperatorIds = [];

  @override
  void initState() {
    super.initState();
    final dio = Dio();

    _plantBloc = PlantBloc(plantRepo: PlantRepo(dio));
    _plantCreateBloc = PlantCreateBloc(PlantRepository(dio));
    _clientBloc = GetAllUserBloc(dio)..add(const FetchUsersByRole(2));
    _operatorBloc = GetAllUserBloc(dio)..add(const FetchUsersByRole(3));

    _plantBloc.add(FetchPlantsByType(widget.plantTypeId));
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getInt('role');
      print('User role: $userRole'); // Debug print
    });
  }

  @override
  void dispose() {
    _plantBloc.close();
    _plantCreateBloc.close();
    _clientBloc.close();
    _operatorBloc.close();
    super.dispose();
  }

  void _showAddPlantDialog(BuildContext parentContext) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final capCtrl = TextEditingController();
    final hotelCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (dialogContext) => MultiBlocListener(
        listeners: [
          BlocListener<PlantCreateBloc, PlantCreateState>(
            bloc: _plantCreateBloc,
            listener: (ctx, state) {
              if (state is PlantCreateSuccess) {
                _plantBloc.add(FetchPlantsByType(widget.plantTypeId));
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(content: Text("Plant created successfully")),
                );
              } else if (state is PlantCreateFailure) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(content: Text("Error: ${state.error}")),
                );
              }
            },
          ),
        ],
        child: AlertDialog(
          title: const Text("Add New Plant"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField("Plant Name", nameCtrl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMultiSelectDialog(
                      title: "Clients",
                      bloc: _clientBloc,
                      selectedIds: selectedClientIds,
                      onChanged: (ids) {
                        setState(() {
                          selectedClientIds = ids;
                          print('Add Plant - Updated client IDs: $selectedClientIds'); // Debug print
                        });
                      },
                    ),
                    _buildMultiSelectDialog(
                      title: "Operators",
                      bloc: _operatorBloc,
                      selectedIds: selectedOperatorIds,
                      onChanged: (ids) {
                        setState(() {
                          selectedOperatorIds = ids;
                          print('Add Plant - Updated operator IDs: $selectedOperatorIds'); // Debug print
                        });
                      },
                    ),
                  ],
                ),
                _buildTextField("Address", addressCtrl),
                _buildTextField("Plant Capacity", capCtrl, inputType: TextInputType.number),
                _buildTextField("Hotel Name", hotelCtrl),
                _buildTextField("Description", descCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
            BlocBuilder<PlantCreateBloc, PlantCreateState>(
              bloc: _plantCreateBloc,
              builder: (context, state) {
                final isLoading = state is PlantCreateLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (nameCtrl.text.isNotEmpty &&
                              addressCtrl.text.isNotEmpty &&
                              capCtrl.text.isNotEmpty) {
                            _plantCreateBloc.add(SubmitPlant(
                              PlantModel(
                                plantName: nameCtrl.text,
                                clientId: selectedClientIds,
                                operatorId: selectedOperatorIds,
                                plantTypeId: widget.plantTypeId,
                                address: addressCtrl.text,
                                plantCapacity: int.tryParse(capCtrl.text) ?? 0,
                                hotelName: hotelCtrl.text,
                                plantDescription: descCtrl.text,
                                operationalStatus: true,
                              ),
                            ));
                          } else {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(content: Text("Please fill all required fields")),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text("Submit"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPlantDialog(BuildContext parentContext, Map<String, dynamic> plant) {
    final nameCtrl = TextEditingController(text: plant['plant_name'] ?? '');
    final addressCtrl = TextEditingController(text: plant['address'] ?? '');
    final capCtrl = TextEditingController(text: plant['plant_capacity']?.toString() ?? '');
    final hotelCtrl = TextEditingController(text: plant['hotel_name'] ?? '');
    final descCtrl = TextEditingController(text: plant['plant_description'] ?? '');
    final operationalStatus = ValueNotifier<bool>(plant['operational_status'] ?? true);
    List<int> tempClientIds = List<int>.from(plant['client_id'] ?? []);
    List<int> tempOperatorIds = List<int>.from(plant['operator_id'] ?? []);

    print('Edit Plant - Initial client IDs: $tempClientIds'); // Debug print
    print('Edit Plant - Initial operator IDs: $tempOperatorIds'); // Debug print

    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => MultiBlocListener(
          listeners: [
            BlocListener<PlantCreateBloc, PlantCreateState>(
              bloc: _plantCreateBloc,
              listener: (ctx, state) {
                if (state is PlantCreateSuccess) {
                  _plantBloc.add(FetchPlantsByType(widget.plantTypeId));
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text("Plant updated successfully")),
                  );
                } else if (state is PlantCreateFailure) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text("Error: ${state.error}")),
                  );
                }
              },
            ),
          ],
          child: AlertDialog(
            title: const Text("Edit Plant"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField("Plant Name", nameCtrl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMultiSelectDialog(
                        title: "Clients",
                        bloc: _clientBloc,
                        selectedIds: tempClientIds,
                        onChanged: (ids) {
                          setDialogState(() {
                            tempClientIds = List<int>.from(ids);
                            print('Edit Plant - Updated client IDs: $tempClientIds'); // Debug print
                          });
                        },
                      ),
                      _buildMultiSelectDialog(
                        title: "Operators",
                        bloc: _operatorBloc,
                        selectedIds: tempOperatorIds,
                        onChanged: (ids) {
                          setDialogState(() {
                            tempOperatorIds = List<int>.from(ids);
                            print('Edit Plant - Updated operator IDs: $tempOperatorIds'); // Debug print
                          });
                        },
                      ),
                    ],
                  ),
                  _buildTextField("Address", addressCtrl),
                  _buildTextField("Plant Capacity", capCtrl, inputType: TextInputType.number),
                  _buildTextField("Hotel Name", hotelCtrl),
                  _buildTextField("Description", descCtrl),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Text("Operational Status"),
                        const Spacer(),
                        ValueListenableBuilder<bool>(
                          valueListenable: operationalStatus,
                          builder: (context, value, child) => Switch(
                            value: value,
                            onChanged: (newValue) => operationalStatus.value = newValue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
              BlocBuilder<PlantCreateBloc, PlantCreateState>(
                bloc: _plantCreateBloc,
                builder: (context, state) {
                  final isLoading = state is PlantCreateLoading;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameCtrl.text.isNotEmpty && addressCtrl.text.isNotEmpty && capCtrl.text.isNotEmpty) {
                              try {
                                await PlantRepository(Dio()).editplant(
                                  plantId: plant['plant_id'],
                                  plantName: nameCtrl.text,
                                  address: addressCtrl.text,
                                  plantCapacity: int.tryParse(capCtrl.text),
                                  hotelName: hotelCtrl.text.isNotEmpty ? hotelCtrl.text : null,
                                  plantDescription: descCtrl.text.isNotEmpty ? descCtrl.text : null,
                                  operationalStatus: operationalStatus.value,
                                  clientIds: tempClientIds.isNotEmpty ? tempClientIds : null,
                                  operatorIds: tempOperatorIds.isNotEmpty ? tempOperatorIds : null,
                                );
                                _plantBloc.add(FetchPlantsByType(widget.plantTypeId));
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(parentContext).showSnackBar(
                                  const SnackBar(content: Text("Plant updated successfully")),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(parentContext).showSnackBar(
                                  SnackBar(content: Text("Error: ${e.toString()}")),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(content: Text("Please fill all required fields")),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text("Save"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _buildMultiSelectDialog({
    required String title,
    required GetAllUserBloc bloc,
    required List<int> selectedIds,
    required ValueChanged<List<int>> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: BlocBuilder<GetAllUserBloc, GetAllUserState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is GetAllUserLoading) {
            return const CircularProgressIndicator();
          }
          if (state is GetAllUserError) {
            return Text("Error: ${state.message}", style: const TextStyle(color: Colors.red));
          }
          if (state is GetAllUserLoaded) {
            final users = state.users;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: () async {
                    final result = await showDialog<List<int>>(
                      context: context,
                      builder: (dialogContext) {
                        List<int> tempSelected = List<int>.from(selectedIds);
                        return StatefulBuilder(
                          builder: (context, setDialogState) {
                            return AlertDialog(
                              title: Text("Select $title"),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: users.length,
                                  itemBuilder: (ctx, idx) {
                                    final user = users[idx];
                                    final id = user['user_id'] as int;
                                    final name = user['name'] as String;
                                    return CheckboxListTile(
                                      title: Text(name),
                                      value: tempSelected.contains(id),
                                      onChanged: (checked) {
                                        setDialogState(() {
                                          if (checked == true) {
                                            if (!tempSelected.contains(id)) {
                                              tempSelected.add(id);
                                            }
                                          } else {
                                            tempSelected.remove(id);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(dialogContext, tempSelected),
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                    if (result != null) {
                      onChanged(List<int>.from(result));
                    }
                  },
                  child: const Text("Select"),
                ),
                const SizedBox(height: 6),
               
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _deletePlant(int plantId, String plantName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete "$plantName"? This action cannot be undone.'),
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
      final repository = PlantRepository(Dio());
      final success = await repository.deleteplant(plantId);

      // Hide loading indicator
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plant deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _plantBloc.add(FetchPlantsByType(widget.plantTypeId));
      } else {
        throw Exception('Failed to delete plant');
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting plant: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _plantBloc),
        BlocProvider.value(value: _plantCreateBloc),
        BlocProvider.value(value: _clientBloc),
        BlocProvider.value(value: _operatorBloc),
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
                'SELECT YOUR WORKPLACE – ${widget.plantTypeName.toUpperCase()}',
                style: const TextStyle(
                  color: AppColors.darkblue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<PlantBloc, PlantState>(
                bloc: _plantBloc,
                builder: (context, state) {
                  if (state is PlantLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is PlantError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  }
                  if (state is PlantLoaded) {
                    final plants = state.plantData;
                    return ListView.builder(
                      itemCount: plants.length,
                      itemBuilder: (_, i) {
                        final plant = plants[i];
                        final plantId = plant['plant_id'] as int;
                        final plantName = plant['plant_name'] ?? 'Unnamed';
                        return Card(
                          color: AppColors.lightblue,
                          margin: const EdgeInsets.all(12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(plantName, style: const TextStyle(color: AppColors.cream)),
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setInt('plant_id', plantId);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.etpdata,
                                arguments: {
                                  'plantName': plantName,
                                  'plantId': plantId,
                                },
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (userRole == 1) ...[
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18, color: AppColors.darkblue),
                                    onPressed: () => _showEditPlantDialog(context, plant),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                    onPressed: () => _deletePlant(plantId, plantName),
                                  ),
                                ],
                                const Icon(Icons.arrow_forward_ios, color: AppColors.yellowochre),
                              ],
                            ),
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
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                onPressed: () => _showAddPlantDialog(context),
                child: const Icon(Icons.add, color: AppColors.yellowochre),
              )
            : null,
      ),
    );
  }
}