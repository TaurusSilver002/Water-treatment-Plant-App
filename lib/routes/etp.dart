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
                          selectedClientIds.addAll(ids.where((id) => !selectedClientIds.contains(id)));
                        });
                      },
                    ),


              _buildMultiSelectDialog(
                      title: "Operators",
                      bloc: _operatorBloc,
                      selectedIds: selectedOperatorIds,
                      onChanged: (ids) {
                        setState(() {
                          selectedOperatorIds.addAll(ids.where((id) => !selectedOperatorIds.contains(id)));
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
              }
            ),
          ],
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
              if (selectedIds.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: selectedIds.map((id) {
                    final name = (state.users.firstWhere(
                      (u) => u['user_id'] == id,
                      orElse: () => {'name': 'Unknown'},
                    ))['name'];
                    return Chip(label: Text(name));
                  }).toList(),
                )
              
            ],
          );
        }
        return const SizedBox.shrink();
      },
    ),
  );
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
                        return Card(
                          color: AppColors.lightblue,
                          margin: const EdgeInsets.all(12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(plant['plant_name'] ?? 'Unnamed', style: const TextStyle(color: AppColors.cream)),
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setInt('plant_id', plant['plant_id']);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.etpdata,
                                arguments: {
                                  'plantName': plant['plant_name'],
                                  'plantId': plant['plant_id'],
                                },
                              );
                            },
                            trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.yellowochre),
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
