import 'package:flutter/material.dart';
import 'package:watershooters/routes/authentication/login.dart';
import 'package:watershooters/routes/authentication/signup.dart';
import 'package:watershooters/routes/authentication/splashscreen.dart';
import 'package:watershooters/routes/contacts.dart';
import 'package:watershooters/routes/dashboard.dart';
import 'package:watershooters/routes/etp.dart';
import 'package:watershooters/routes/etproutes/etpchemical.dart';
import 'package:watershooters/routes/etproutes/etpdataentry.dart';
import 'package:watershooters/routes/etproutes/etpequip.dart';
import 'package:watershooters/routes/etproutes/etpflow.dart';
import 'package:watershooters/routes/etproutes/etplog.dart';
import 'package:watershooters/routes/etproutes/etpparam.dart';
import 'package:watershooters/routes/profile.dart';
import 'package:watershooters/routes/stp.dart';
import 'package:watershooters/routes/terms.dart';
import 'package:watershooters/routes/wtp.dart';
import 'package:watershooters/services/locater.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     initialRoute: '/splash',
     routes: {
      '/home':(context) =>const Dashboard(),
      '/profile':(context) =>const Profile(),
      '/contacts':(context)=>const TeamPage(),
'/etp': (context) {
  final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  return Etp(
    plantTypeId: args['plantTypeId'] as int,
    plantTypeName: args['plantTypeName'] as String,
  );
},

      '/stp':(context)=>const Stp(),
      '/wtp':(context)=>const Wtp(),
      '/etpdata':(context)=>const Etpdataentry(),
      '/etpchem':(context)=>const EtpChemical(),
      '/etpflow':(context)=>const EtpFlow(),
      '/etpequip':(context)=>const EtpEquip(),
      '/etpparam':(context)=>const EtpParam(),
      '/etplog':(context)=>const EtpLog(),
      '/terms':(context)=>const TermsandConditions(),
      '/splash':(context) => const SplashScreen(),
      '/login':(context) => const LoginPage(),
      '/signup':(context) => const SignUpPage(),
     },
    );
  }
}

