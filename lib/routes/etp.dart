import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:waterplant/bloc/plant/plant_bloc.dart';
import 'package:waterplant/components/customAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';
import 'package:waterplant/models/plant_type.dart';

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

  @override
  void initState() {
    super.initState();
    _plantBloc = PlantBloc(plantRepo: PlantRepo(Dio()));
    _plantBloc.add(FetchPlantsByType(widget.plantTypeId));
  }

  @override
  void dispose() {
    _plantBloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _plantBloc,
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
                            style: const TextStyle(color: Colors.red)));
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
                                style:
                                    const TextStyle(color: AppColors.cream)),
                           onTap: () {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.darkblue),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
