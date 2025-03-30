import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  final List<Map<String, String>> teamMembers = const [
    {'name': 'Anushka Mukherjee', 'phone': '+919831406436'},
    {'name': 'Person 1', 'phone': '123456789'},
    {'name': 'Person 2', 'phone': '123456789'},
    {'name': 'Person 3', 'phone': '123456789'},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: ListView.builder(
        itemCount: teamMembers.length,
        itemBuilder: (context, index) {
          final member = teamMembers[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(member['name']!),
            subtitle: Text(member['phone']!),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makePhoneCall(member['phone']!),
            ),
          );
        },
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
