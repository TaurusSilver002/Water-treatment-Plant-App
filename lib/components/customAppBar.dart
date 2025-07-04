import 'package:flutter/material.dart';
import 'package:watershooters/config.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cream,
      elevation: 0, 
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.darkblue),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
     actions: [
  IconButton(
    icon: const Icon(
      Icons.person,
      color: AppColors.darkblue,
    ),
    onPressed: () {
      // Get the current route name
      final currentRoute = ModalRoute.of(context)?.settings.name;
      
      // Check if already on profile page or if profile page is in the stack
      if (currentRoute != AppRoutes.profile && 
          !Navigator.of(context).widget.pages.any((page) => page.name == AppRoutes.profile)) {
        Navigator.pushNamed(context, AppRoutes.profile);
      }
    },
  ),
],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}