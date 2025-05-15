import 'package:flutter/material.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watershooters/bloc/plantchem_bloc.dart';
import 'package:watershooters/models/plantchem_repository.dart';

class EtpChemical extends StatefulWidget {
  const EtpChemical({super.key});

  @override
  State<EtpChemical> createState() => _EtpChemicalState();
}

class _EtpChemicalState extends State<EtpChemical> {
  List<Map<String, dynamic>> chemicals = [];
  late final PlantchemBloc _plantchemBloc;

  @override
  void initState() {
    super.initState();
    _plantchemBloc = PlantchemBloc(repository: PlantChemRepository());
    _plantchemBloc.add(FetchPlantchem());
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
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
                    return ListView.separated(
                      itemCount: chemicals.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final chemical = chemicals[index];
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