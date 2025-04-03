import 'package:flutter/material.dart';
import 'package:waterplant/config.dart';
import 'package:waterplant/routes/contacts.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = "John Doe";
    final String initials = userName
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0] : '')
        .join()
        .toUpperCase();

    return Drawer(
      backgroundColor: AppColors.lightblue,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.cream,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.cream,
                child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.darkblue,
                    width: 2.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.darkblue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ),
                ),
                const SizedBox(width: 16),
                // User name
                Expanded(
                  child: Text(
                    userName,
                    style: const TextStyle(
                      color: AppColors.darkblue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.cream),
            title: const Text('Home', style: TextStyle(color: AppColors.cream)),
            onTap: () { Navigator.pop(context); 
             Navigator.pushReplacementNamed(context, '/home');}
          ),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.cream),
            title: const Text('Profile', style: TextStyle(color: AppColors.cream)),
            onTap: () {
               Navigator.pushNamed(
          context,
          AppRoutes.profile
        );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contacts, color: AppColors.cream),
            title: const Text('Contacts', style: TextStyle(color: AppColors.cream)),
            onTap: () { Navigator.pop(context);
            Navigator.pushReplacementNamed(context, AppRoutes.contacts);},
          ),
         
          ListTile(
            leading: const Icon(Icons.note, color: AppColors.cream),
            title: const Text('Terms and Conditions', 
                style: TextStyle(color: AppColors.cream)),
            onTap: ()  {Navigator.pop(context);
            Navigator.pushReplacementNamed(context, AppRoutes.terms);}
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}