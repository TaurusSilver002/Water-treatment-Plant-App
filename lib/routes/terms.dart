import 'package:flutter/material.dart';
import 'package:watershooters/components/customAppBar.dart';
import 'package:watershooters/components/customdrawer.dart';
import 'package:watershooters/config.dart';

class TermsandConditions extends StatelessWidget {
  const TermsandConditions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.cream,
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
          ],
        ),
      ),
    );
  }
}