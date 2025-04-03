import 'package:flutter/material.dart';
import 'package:waterplant/routes/contacts.dart';
import 'package:waterplant/routes/dashboard.dart';
import 'package:waterplant/routes/etp.dart';
import 'package:waterplant/routes/etproutes/etpchemical.dart';
import 'package:waterplant/routes/etproutes/etpdataentry.dart';
import 'package:waterplant/routes/etproutes/etpequip.dart';
import 'package:waterplant/routes/etproutes/etpflow.dart';
import 'package:waterplant/routes/etproutes/etplog.dart';
import 'package:waterplant/routes/profile.dart';
import 'package:waterplant/routes/stp.dart';
import 'package:waterplant/routes/terms.dart';
import 'package:waterplant/routes/wtp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     initialRoute: '/home',
     routes: {
      '/home':(context) =>const Dashboard(),
      '/profile':(context) =>const Profile(),
      '/contacts':(context)=>const TeamPage(),
      '/etp':(context)=>const Etp(),
      '/stp':(context)=>const Stp(),
      '/wtp':(context)=>const Wtp(),
      '/etpdata':(context)=>const Etpdataentry(),
      '/etpchem':(context)=>const EtpChemical(),
      '/etpflow':(context)=>const EtpFlow(),
      '/etpequip':(context)=>const EtpEquip(),
      '/etplog':(context)=>const EtpLog(),
      '/terms':(context)=>const TermsandConditions(),
     },
    );
  }
}

