import 'package:flutter/material.dart';

class AppColors{
  static const Color cream= Color(0xFFF5EEDC);
  static const Color lightblue= Color(0xFF27548A);
  static const Color darkblue= Color(0xFF183B4E);
  static const Color yellowochre= Color(0xFFDDA853);
}
class AppRoutes {
  static const dashboard = '/home';
  static const login = '/login';
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
  static const etpparam = '/etpparam';
  static const etpreport = '/etpreport';
  static const graph = '/graph';
}
class AppConfig{
  static const String baseUrl = 'https://api.watershooters.in';
  static const String signlink = '$baseUrl/api/v1/user/register';
  static const String loginlink = '$baseUrl/api/v1/user/login';
  static const String userlink = '$baseUrl/api/v1/user/me';
  static const String typelink = '$baseUrl/api/v1/plant/types';
  static const String plantlink = '$baseUrl/api/v1/plant/getallplants';
  static const String createplantlink = '$baseUrl/api/v1/plant/createplant';
  static const String get = '$baseUrl/api/v1/user/all';
//getlogs
  static const String equiplog= '$baseUrl/api/v1/logs/equipment';
  static const String chemicallog= '$baseUrl/api/v1/logs/chemical';
  static const String flowlog= '$baseUrl/api/v1/logs/flow';
  static const String parameterlog= '$baseUrl/api/v1/logs/flowparameter';
  static const String alllogs= '$baseUrl/api/v1/logs/all';
  static const String pdf= '$baseUrl/api/v1/plant/report/pdf';
//createlogs
  static const String equiplogadd= '$baseUrl/api/v1/logs/create/equipment';
  static const String chemicallogadd= '$baseUrl/api/v1/logs/create/chemical';
  static const String flowlogadd= '$baseUrl/api/v1/logs/create/flow';
  static const String parameterlogadd= '$baseUrl/api/v1/logs/create/flowparameter';
//deletelogs
  static const String plantdelete = '$baseUrl/api/v1/plant/deleteplant';
  static const String equiplogdelete= '$baseUrl/api/v1/logs/delete/equipment';
  static const String chemicallogdelete= '$baseUrl/api/v1/logs/delete/chemical';
  static const String flowlogdelete= '$baseUrl/api/v1/logs/delete/flow';
  static const String parameterlogdelete= '$baseUrl/api/v1/logs/delete/flowparameter';

//editlogs
  static const String equiplogedit= '$baseUrl/api/v1/logs/update/equipment';
  static const String chemicallogedit= '$baseUrl/api/v1/logs/update/chemical';    
  static const String flowlogedit= '$baseUrl/api/v1/logs/update/flow';
  static const String parameterlogedit= '$baseUrl/api/v1/logs/update/flowparameter';

  static const String plantequip = '$baseUrl/plant-equipment/plant';
  static const String plantequipadd = '$baseUrl/plant-equipment/create';
  static const String plantchem = '$baseUrl/plant-chemical/plant';
  static const String plantchemadd = '$baseUrl/plant-chemical/create';
  static const String plantparam = '$baseUrl/plant-flow-parameter/plant';
  static const String plantparamadd = '$baseUrl/plant-flow-parameter/create';
  //delete functions
  static const String plantequipdelete = '$baseUrl/plant-equipment/';
  static const String plantchemdelete = '$baseUrl/plant-chemical/'; 
  static const String plantparamdelete = '$baseUrl/plant-flow-parameter/';
  //editfunctions
  static const String plantedit = '$baseUrl/api/v1/plant/updateplant';
  static const String plantequipedit = '$baseUrl/plant-equipment/update';
  static const String plantchemedit = '$baseUrl/plant-chemical/update';
  static const String plantparamedit = '$baseUrl/plant-flow-parameter/update';
  //graph
  static const String graphDataEquip = '$baseUrl/api/v1/logs/graph-data/equipment';
  static const String graphDataChemUsed = '$baseUrl/api/v1/logs/graph-data/chemical/used';
  static const String graphDataChemRem = '$baseUrl/api/v1/logs/graph-data/chemical/remaining';
  static const String graphDataFlow = '$baseUrl/api/v1/logs/graph-data/flow';
  static const String graphDataParam = '$baseUrl/api/v1/logs/graph-data/parameters';

  // Plant Equipment
  static const String fetchEquip = '$baseUrl/api/v1/plant-equipment/list';
}
class AppImages {
  static const String logo = 'assets/images/shootlogo.png';
  static const String splash = 'assets/lottie/splash.json';
}
