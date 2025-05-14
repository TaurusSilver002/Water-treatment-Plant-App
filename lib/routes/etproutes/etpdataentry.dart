import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waterplant/bloc/chemicallog/chemicallog_bloc.dart';
import 'package:waterplant/bloc/equipmentlog/equipmentlog_bloc.dart';
import 'package:waterplant/components/CustomAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';
import 'package:waterplant/models/chemicallog.dart';
import 'package:waterplant/models/equiplog.dart';
import 'package:waterplant/routes/etproutes/etplog.dart';

class Etpdataentry extends StatefulWidget {
  const Etpdataentry({super.key});

  @override
  State<Etpdataentry> createState() => _EtpdataentryState();
}

class _EtpdataentryState extends State<Etpdataentry> {
  late String plantName;
  late int plantId;
  late final EquipmentBloc _equipmentBloc;
  late final ChemicallogBloc _chemicallogBloc;

  @override
  void initState() {
    super.initState();
    _equipmentBloc = EquipmentBloc(
      repository: EquipmentRepository(),
    );
    _equipmentBloc.add(FetchEquipment());
    _chemicallogBloc = ChemicallogBloc(
      repository: ChemicalLogRepository(),
    );
    _chemicallogBloc.add(FetchChemicallog());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    plantName = args?['plantName'] as String? ?? 'WORKPLACE NOT SELECTED';
    plantId = args?['plantId'] as int? ?? 0;
  }

  final List<Map<String, String>> boxes = [
    {
      'title': 'CHEMICALS',
      'subtitle': 'Chemicals that will be added for treatment.'
    },
    {
      'title': 'GRAPH',
      'subtitle': 'Analysis of Chemicals that are present in the incoming mix'
    },
    {'title': 'EQUIPMENTS', 'subtitle': 'Equipment used for treatment'},
    {'title': 'LOGS', 'subtitle': 'Data entry field'},
  ];

  void _navigateToNextPage(String boxName) {
    switch (boxName) {
      case 'CHEMICALS':
        Navigator.pushNamed(context, AppRoutes.etpchem);
        break;
      case 'FLOW':
        Navigator.pushNamed(context, AppRoutes.etpflow);
        break;
      case 'EQUIPMENTS':
        Navigator.pushNamed(context, AppRoutes.etpequip);
        break;
      case 'LOGS':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EtpLog(equipmentBloc: _equipmentBloc,chemicallogBloc: _chemicallogBloc,),
            settings: const RouteSettings(name: AppRoutes.etplog),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: _equipmentBloc,
        ),
        BlocProvider.value(
          value: _chemicallogBloc,
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: const CustomAppBar(),
        drawer: const CustomDrawer(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  plantName,
                  style: const TextStyle(
                    color: AppColors.darkblue,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var box in boxes)
                      SizedBox(
                        height: 150,
                        child: GestureDetector(
                          onTap: () => _navigateToNextPage(box['title']!),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightblue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10),
                                Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: Text(
                                    box['title']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.cream,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      box['subtitle']!,
                                      textAlign: TextAlign.justify,
                                      style: const TextStyle(
                                        color: AppColors.cream,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _equipmentBloc.close();
    _chemicallogBloc.close();
    super.dispose();
  }
}
