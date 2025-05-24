import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watershooters/bloc/user/user_bloc.dart';
import 'package:watershooters/bloc/user/user_event.dart';
import 'package:watershooters/bloc/user/user_state.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';
import 'package:watershooters/services/locater.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

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
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: const CustomAppBar(),
        drawer: const CustomDrawer(),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading || state is UserInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserBloc>().add(const FetchUser());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is UserLoaded) {
              final user = state.user;
              final name = '${user.firstName} ${user.lastName}';
              final initials = getInitials(name);

              final Map<String, String?> profileData = {
                'User ID': user.userId.toString(),
                'Name': name,
                'Phone Number': user.phoneNo,
                'Aadhar Number': user.aadharNo,
                'Email': user.email,
                'Qualifications': user.qualification,
                'Address': user.address,
                'Date of Birth': '${user.dob.day}-${user.dob.month}-${user.dob.year}',
              };

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
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
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkblue,
                      ),
                    ),
                    const SizedBox(height: 30),
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
              );
            } else {
              return const Center(child: Text('Unknown state'));
            }
          },
        ),
      ),
    );
  }
}
