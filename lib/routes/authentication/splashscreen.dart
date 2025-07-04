import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:watershooters/config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _textAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _textAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.5),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation immediately
    _animationController.forward();
        _checkAuthStatus();

    // Navigate after animation completes with a short delay for visibility
    Timer(const Duration(milliseconds: 1600), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              AppImages.splash, 
              width: 200,
              height: 200,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 20),
            // Animated Text
            SlideTransition(
              position: _textAnimation,
              child: const Text(
                'Welcome to WaterShooters',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightblue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _checkAuthStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  // Wait for animation to complete
  await Future.delayed(const Duration(milliseconds: 1600));

  if (!mounted) return;

  if (token != null) {
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  } else {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}
}