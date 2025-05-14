import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waterplant/bloc/createplant/createplant_bloc.dart';
import 'package:waterplant/bloc/plant/plant_bloc.dart';
import 'package:waterplant/components/customAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';
import 'package:waterplant/bloc/type/type_bloc.dart';
import 'package:waterplant/models/plant_type.dart';
import 'package:waterplant/routes/etp.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late TypeBloc _typeBloc;

  @override
  void initState() {
    super.initState();
    _typeBloc = TypeBloc();
    _typeBloc.add(FetchPlantTypes());
  }

  @override
  void dispose() {
    _typeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.darkblue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome.',
                      style: TextStyle(
                          color: AppColors.cream,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit...',
                      style: TextStyle(color: AppColors.cream, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('SELECT THE PLANT TYPE',
              style: TextStyle(
                  color: AppColors.darkblue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<TypeBloc, TypeState>(
                bloc: _typeBloc,
                builder: (context, state) {
                  if (state is TypeLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: AppColors.darkblue,
                    ));
                  } else if (state is TypeError) {
                    return Center(
                        child: Text(state.message,
                            style: const TextStyle(color: Colors.red)));
                  } else if (state is TypeLoaded) {
                    return ListView.separated(
                      itemCount: state.types.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final type = state.types[index];
                        return _buildDashboardCard(
                          title: type.name,
                          plantId: type.id,
                          color: AppColors.lightblue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Etp(
                                  plantTypeId: type.id,
                                  plantTypeName: type.name,
                                  // Default to user role
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: Text('No plant types available'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required int plantId,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cream),
            ),
            const SizedBox(width: 16),
            Transform.scale(
              scaleX: 0.7,
              child: const Icon(Icons.arrow_forward_ios,
                  color: AppColors.yellowochre),
            ),
          ],
        ),
      ),
    );
  }
}
