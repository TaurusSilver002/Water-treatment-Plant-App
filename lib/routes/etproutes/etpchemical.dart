import 'package:flutter/material.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watershooters/bloc/plantchem/plantchem_bloc.dart';
import 'package:watershooters/models/plantchem_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EtpChemical extends StatefulWidget {
  const EtpChemical({super.key});

  @override
  State<EtpChemical> createState() => _EtpChemicalState();
}

class _EtpChemicalState extends State<EtpChemical> {
  List<Map<String, dynamic>> chemicals = [];
  late final PlantchemBloc _plantchemBloc;
  int? _userRole;

  @override
  void initState() {
    super.initState();
    _plantchemBloc = PlantchemBloc(repository: PlantChemRepository());
    _plantchemBloc.add(FetchPlantchem());
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getInt('role_id');
      print('User role: $_userRole'); // Debug print
    });
  }

  @override
  void dispose() {
    _plantchemBloc.close();
    super.dispose();
  }

  void _updateChemicals(List<Map<String, dynamic>> chemList) {
    setState(() {
      chemicals = chemList.map((item) => {
        'compound': item['chemical_name'] ?? 'Unknown',
        'amount': item['quantity'] != null && item['chemical_unit'] != null
            ? '${item['quantity']} ${item['chemical_unit']}'
            : (item['quantity']?.toString() ?? 'N/A'),
        'plant_chemical_id': item['plant_chemical_id']?.toString() ?? 'N/A',
        'plant_id': item['plant_id']?.toString() ?? 'N/A',
        'created_at': item['created_at']?.toString() ?? 'N/A',
        'del_flag': item['del_flag']?.toString() ?? 'N/A',
      }).toList();
      print('Chemicals updated: ${chemicals.length} items'); // Debug print
    });
  }

  void _addNewChemical() {
    final TextEditingController compoundController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController unitController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Chemical'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: compoundController,
                decoration: const InputDecoration(labelText: 'Compound'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit (e.g. mg/l, Kg)'),
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
                if (compoundController.text.isNotEmpty &&
                    amountController.text.isNotEmpty &&
                    unitController.text.isNotEmpty) {
                  try {
                    await PlantChemRepository().addPlantChem(
                      chemicalName: compoundController.text,
                      quantity: double.tryParse(amountController.text) ?? 0.0,
                      chemicalUnit: unitController.text,
                    );
                    _plantchemBloc.add(FetchPlantchem());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chemical added successfully')),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add chemical: $e')),
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
    );
  }

  void _editChemical(String plantChemicalId, String chemicalName, String amount, String unit) async {
    final chemId = int.tryParse(plantChemicalId);
    if (chemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid chemical ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Editing chemical ID: $chemId'); // Debug print

    final TextEditingController compoundController = TextEditingController(text: chemicalName);
    final TextEditingController amountController = TextEditingController(text: amount);
    final TextEditingController unitController = TextEditingController(text: unit);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Chemical'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: compoundController,
                decoration: const InputDecoration(labelText: 'Compound'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit (e.g. mg/l, Kg)'),
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
                if (compoundController.text.isNotEmpty &&
                    amountController.text.isNotEmpty &&
                    unitController.text.isNotEmpty) {
                  try {
                    print('Sending edit payload: plant_chemical_id: $chemId, chemical_name: ${compoundController.text}, quantity: ${amountController.text}, chemical_unit: ${unitController.text}'); // Debug print
                    await PlantChemRepository().editchemical(
                      plant_chemical_id: chemId,
                      chemical_name: compoundController.text,
                      quantity: int.tryParse(amountController.text),
                      chemical_unit: unitController.text,
                    );
                    _plantchemBloc.add(FetchPlantchem());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Chemical updated successfully')),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to edit chemical: $e')),
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
    );
  }

  void _deleteChemical(String plantChemicalId, String chemicalName) async {
    final chemId = int.tryParse(plantChemicalId);
    if (chemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid chemical ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print('Deleting chemical ID: $chemId'); // Debug print

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chemical'),
        content: Text('Are you sure you want to delete "$chemicalName"? This action cannot be undone.'),
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
      final repository = PlantChemRepository();
      final success = await repository.deletechemical(chemId);

      // Hide loading indicator
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chemical deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _plantchemBloc.add(FetchPlantchem());
      } else {
        throw Exception('Failed to delete chemical');
      }
    } catch (e) {
      // Hide loading indicator if still showing
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting chemical: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _plantchemBloc,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: const CustomAppBar(),
        drawer: const CustomDrawer(),
        body: BlocListener<PlantchemBloc, PlantchemState>(
          listener: (context, state) {
            if (state is PlantchemLoaded) {
              _updateChemicals(state.chemList);
            }
          },
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<PlantchemBloc, PlantchemState>(
                  builder: (context, state) {
                    if (state is PlantchemLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PlantchemError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    if (chemicals.isEmpty) {
                      return const Center(child: Text('No chemicals available'));
                    }
                    return ListView.separated(
                      itemCount: chemicals.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final chemical = chemicals[index];
                        final amountParts = chemical['amount']!.split(' ');
                        final amount = amountParts.isNotEmpty ? amountParts[0] : chemical['amount'];
                        final unit = amountParts.length > 1 ? amountParts[1] : '';
                        print('Rendering chemical: ${chemical['compound']}, ID: ${chemical['plant_chemical_id']}'); // Debug print
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            clipBehavior: Clip.antiAlias,
                            child: ExpansionTile(
                              collapsedIconColor: AppColors.yellowochre,
                              iconColor: AppColors.yellowochre,
                              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              collapsedBackgroundColor: AppColors.lightblue,
                              backgroundColor: AppColors.lightblue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              leading: const Icon(Icons.science, color: AppColors.yellowochre),
                              title: Text(
                                chemical['compound']!,
                                style: const TextStyle(color: AppColors.cream),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Amount: ${chemical['amount']}', style: const TextStyle(color: AppColors.cream)),
                                      Text('Plant Chemical ID: ${chemical['plant_chemical_id']}', style: const TextStyle(color: AppColors.cream)),
                                      Text('Plant ID: ${chemical['plant_id']}', style: const TextStyle(color: AppColors.cream)),
                                      Text('Created At: ${chemical['created_at']}', style: const TextStyle(color: AppColors.cream)),
                                      Text('Deleted Flag: ${chemical['del_flag']}', style: const TextStyle(color: AppColors.cream)),
                                      const SizedBox(height: 12),
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
                                              onPressed: () => _editChemical(
                                                chemical['plant_chemical_id']!,
                                                chemical['compound']!,
                                                amount,
                                                unit,
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
                                              onPressed: () => _deleteChemical(chemical['plant_chemical_id']!, chemical['compound']!),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.darkblue),
                      onPressed: () => Navigator.pop(context),
                    ),
                    if (_userRole == 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: FloatingActionButton(
                          backgroundColor: AppColors.darkblue,
                          onPressed: _addNewChemical,
                          child: const Icon(Icons.add, color: AppColors.yellowochre),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}