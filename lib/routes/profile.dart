import 'package:flutter/material.dart';
import 'package:waterplant/components/customAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Sample profile data
  final Map<String, String?> profileData = {
    'Name': 'John Doe',
    'Phone Number': '+91 1234567890',
    'Aadhar Number': '1234 5678 9012',
    'Email': null, // Can be null
    'Qualifications': 'B.Tech in Chemical Engineering',
    'Address': '123 Water Plant St, Mumbai, India',
    'Date of Birth': '15-06-1985',
  };

  String getInitials(String name) {
    return name.split(' ').map((e) => e[0]).take(2).join();
  }

  @override
  Widget build(BuildContext context) {
    final name = profileData['Name']!;
    final initials = getInitials(name);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Avatar with Initials
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.darkblue,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.cream,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Name as Title
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkblue,
              ),
            ),
            const SizedBox(height: 30),
            // Profile Details List
            Card(
              color: AppColors.lightblue,
              child: Column(
                children: profileData.entries.map((entry) {
                  if (entry.value == null) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.cream,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.value!,
                            style: const TextStyle(
                              color: AppColors.cream,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          
          
          ],
        ),
      ),
    );
  }
}