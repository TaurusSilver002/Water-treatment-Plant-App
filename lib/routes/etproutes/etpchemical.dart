import 'package:flutter/material.dart';
import 'package:waterplant/components/customAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';

class EtpChemical extends StatefulWidget {
  const EtpChemical({super.key});

  @override
  State<EtpChemical> createState() => _EtpChemicalState();
}

class _EtpChemicalState extends State<EtpChemical> {
  final List<Map<String, String>> chemicals = [
    {'compound': 'Chlorine', 'amount': '12 mg/l'},
    {'compound': 'Alum', 'amount': '9 mg/l'},
  ];

  void _addNewChemical() {
    showDialog(
      context: context,
      builder: (context) {
        String newCompound = '';
        String newAmount = '';
        
        return AlertDialog(
          title: const Text('Add New Chemical'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Compound'),
                onChanged: (value) => newCompound = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Amount (mg/l)'),
                onChanged: (value) => newAmount = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newCompound.isNotEmpty && newAmount.isNotEmpty) {
                  setState(() {
                    chemicals.add({
                      'compound': newCompound,
                      'amount': '$newAmount mg/l'
                    });
                  });
                  Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: chemicals.length,
               separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chemical = chemicals[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    tileColor: AppColors.lightblue,
                     shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
                    leading: const Icon(Icons.science,color: AppColors.yellowochre,),
                      contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Text(chemical['compound']!,style: TextStyle(color: AppColors.cream),),
                    trailing: Text(
                      chemical['amount']!,
                      style: const TextStyle(fontWeight: FontWeight.bold,color: AppColors.cream),
                    ),
                  ),
                );
              },
            ),
          ),
                  Container(
            height: 80,
           padding: const EdgeInsets.symmetric(horizontal: 16, ),
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
       
    );
  }
}