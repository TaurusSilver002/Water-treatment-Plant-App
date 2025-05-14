import 'package:flutter/material.dart';

class AppColors{
  static const Color cream= Color(0xFFF5EEDC);
  static const Color lightblue= Color(0xFF27548A);
  static const Color darkblue= Color(0xFF183B4E);
  static const Color yellowochre= Color(0xFFDDA853);
}
class AppRoutes {
  static const dashboard = '/home';
  static const profile = '/profile';  
  static const contacts = '/contacts';
  static const terms='/terms';
  static const etp = '/etp';
  static const stp = '/stp';
  static const wtp = '/wtp';
  //etp
  static const etpdata = '/etpdata';
  static const etpchem = '/etpchem';
  static const etpflow = '/etpflow';
  static const etpequip = '/etpequip';
  static const etplog = '/etplog';
  static const splash = '/splash';
}
class AppConfig{
  static const String baseUrl = 'https://api.watershooters.in';
  static const String signlink = '$baseUrl/api/v1/user/register';
  static const String loginlink = '$baseUrl/api/v1/user/login';
  static const String userlink = '$baseUrl/api/v1/user/me';
  static const String typelink = '$baseUrl/api/v1/plant/types';
  static const String plantlink = '$baseUrl/api/v1/plant/getallplants';
  static const String createplantlink = '$baseUrl/api/v1/plant/createplant';
  static const String equiplog= '$baseUrl/api/v1/logs/equipment';
  static const String chemicallog= '$baseUrl/api/v1/logs/chemical';
  static const String flowlog= '$baseUrl/api/v1/logs/flow';
}
class AppImages {
  static const String logo = 'assets/images/shootlogo.png';
  static const String splash = 'assets/lottie/splash.json';
}
