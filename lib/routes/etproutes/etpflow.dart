import 'package:flutter/material.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EtpFlow extends StatefulWidget {
  const EtpFlow({super.key});

  @override
  State<EtpFlow> createState() => _EtpFlowState();
}

class _EtpFlowState extends State<EtpFlow> {
  final List<Map<String, String>> chemicals = [
    {'compound': 'Arsenic', 'amount': '12 mg/l'},
    {'compound': 'Lead', 'amount': '9 mg/l'},
  ];
  int? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getInt('role');
    });
  }

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
              padding: const EdgeInsets.all(12),
              itemCount: chemicals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chemical = chemicals[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListTile(
                    leading: const Icon(Icons.science, color: AppColors.yellowochre),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    tileColor: AppColors.lightblue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(
                      chemical['compound']!,
                      style: TextStyle(color: AppColors.cream),
                    ),
                    trailing: Text(
                      chemical['amount']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cream,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.darkblue),
                  onPressed: () => Navigator.pop(context),
                ),
                if (_userRole == 1)
                  FloatingActionButton(
                    backgroundColor: AppColors.darkblue,
                    onPressed: _addNewChemical,
                    child: const Icon(Icons.add, color: AppColors.yellowochre),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}