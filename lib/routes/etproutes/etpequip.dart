import 'package:flutter/material.dart';
import 'package:waterplant/components/customAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';

class EtpEquip extends StatefulWidget {
  const EtpEquip({super.key});

  @override
  State<EtpEquip> createState() => _EtpEquipState();
}

class _EtpEquipState extends State<EtpEquip> {
  List<Map<String, String>> etpData = [
    {'name': 'ABC Plant', 'status': 'OK', 'maintenance': '30-03-25'},
    {'name': 'XYZ Facility', 'status': 'Warning', 'maintenance': '15-04-25'},
    {'name': 'Main ETP Unit', 'status': 'Critical', 'maintenance': '05-03-25'},
    {'name': 'Secondary Treatment', 'status': 'OK', 'maintenance': '22-05-25'},
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ok':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _addNewEquipment() {
    final TextEditingController nameController = TextEditingController();
    String selectedStatus = 'OK';
    const demoDate = '30-03-25'; 

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add New Equipment'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Equipment Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: ['OK', 'Warning', 'Critical']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Status'),
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
                  if (nameController.text.isNotEmpty) {
                    setState(() {
                      etpData.add({
                        'name': nameController.text,
                        'status': selectedStatus,
                        'maintenance': demoDate, 
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: etpData.length,
              itemBuilder: (context, index) {
                final item = etpData[index];
                return Card(
                  color: AppColors.lightblue,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    iconColor: AppColors.yellowochre,  
                    collapsedIconColor: AppColors.yellowochre, 
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getStatusColor(item['status']!),
                        shape: BoxShape.circle,
                        
                      ),
                    ),
                    title: Text(
                      item['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cream,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${item['status']}',
                              style: const TextStyle(
                                color: AppColors.cream,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Last Maintenance: ${item['maintenance']}',
                              style: const TextStyle(
                                color: AppColors.cream,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          backgroundColor: AppColors.darkblue,
          onPressed: _addNewEquipment,
          child: const Icon(Icons.add, color: AppColors.yellowochre),
        ),
      ),
    );
  }
}