import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waterplant/components/CustomAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  final List<Map<String, String>> teamMembers = const [
    {'name': 'Person 1', 'phone': '123456789'},
    {'name': 'Person 2', 'phone': '123456789'},
    {'name': 'Person 3', 'phone': '123456789'},
  ];

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
              itemCount: teamMembers.length,
              itemBuilder: (context, index) {
                final member = teamMembers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.person, color: AppColors.darkblue),
                    title: Text(member['name']!),
                    subtitle: Text(member['phone']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: AppColors.lightblue),
                      onPressed: () => _makePhoneCall(member['phone']!),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch $phoneNumber');
    }
  }
}