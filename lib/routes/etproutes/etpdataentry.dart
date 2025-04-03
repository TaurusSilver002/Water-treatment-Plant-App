import 'package:flutter/material.dart';
import 'package:waterplant/components/CustomAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';

class Etpdataentry extends StatefulWidget {
  const Etpdataentry({super.key});

  @override
  State<Etpdataentry> createState() => _EtpdataentryState();
}

class _EtpdataentryState extends State<Etpdataentry> {
late String plantName; 

  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    plantName = args as String? ?? 'WORKPLACE NOT SELECTED'; 
  }

  final List<Map<String, String>> boxes = [
    {'title': 'CHEMICALS', 'subtitle': 'Chemicals that will be added for treatment.'},
    {'title': 'FLOW', 'subtitle': 'Chemicals that are present in the incoming mix'},
    {'title': 'EQUIPMENTS', 'subtitle': 'Equipment used for treatment'},
    {'title': 'LOGS', 'subtitle': 'Data entry field'},
  ];

  void _navigateToNextPage(String boxName) {
    switch (boxName) {
      case 'CHEMICALS':
        Navigator.pushNamed(
          context,
          AppRoutes.etpchem
        );
        break;
      case 'FLOW':
       Navigator.pushNamed(
          context,
          AppRoutes.etpflow
        );
        break;
      case 'EQUIPMENTS':
        Navigator.pushNamed(
          context,
          AppRoutes.etpequip
        );
        break;
      case 'LOGS':
        Navigator.pushNamed(
          context,
          AppRoutes.etplog
        );
        break;
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
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
                const SizedBox(height: 10,),
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
  ],),
  
  ]
        ),
      ),
    ),
  );
  }
}

