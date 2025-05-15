import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watershooters/bloc/user/user_bloc.dart';
import 'package:watershooters/bloc/user/user_event.dart';
import 'package:watershooters/bloc/user/user_state.dart';
import 'package:watershooters/config.dart';
import 'package:watershooters/services/locater.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

 String getInitials(String name) {
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final userBloc = locator<UserBloc>();
        userBloc.add(const FetchUser());
        return userBloc;
      },
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
  String initials = '';
  String userName = 'User';
          if (state is UserLoaded) {
    final user = state.user;
    userName = '${user.firstName} ${user.lastName}';
    initials = getInitials(userName);
  }

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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: AppColors.cream),
                  title: const Text('Home',
                      style: TextStyle(color: AppColors.cream)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: AppColors.cream),
                  title: const Text('Profile',
                      style: TextStyle(color: AppColors.cream)),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.profile,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contacts, color: AppColors.cream),
                  title: const Text('Contacts',
                      style: TextStyle(color: AppColors.cream)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.contacts);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.note, color: AppColors.cream),
                  title: const Text('Terms and Conditions',
                      style: TextStyle(color: AppColors.cream)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, AppRoutes.terms);
                  },
                ),
              ],
            ),
          );
        },
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
