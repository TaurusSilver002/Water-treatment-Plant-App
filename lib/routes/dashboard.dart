import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:waterplant/components/customAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';
import 'package:waterplant/routes/contacts.dart';
import 'package:waterplant/routes/etp.dart';
import 'package:waterplant/routes/stp.dart';
import 'package:waterplant/routes/wtp.dart';
import 'package:waterplant/components/customAppBar.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: AppColors.cream,
      appBar: const  CustomAppBar(),
        drawer:const CustomDrawer(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 const SizedBox(height: 16,),
                 Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Container(
                    padding:const  EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.darkblue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child:const  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome.',style: TextStyle(color: AppColors.cream,fontSize: 20,fontWeight: FontWeight.bold),),
                        SizedBox(height: 12,),
                        Text('LoremLorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat..',style: TextStyle(color: AppColors.cream,fontSize: 12),),
                       
                      ],
                    ),
                   ),
                 ),
               const  SizedBox(height: 32,),
               const Text('SELECT THE PLANT TYPE',style: TextStyle(color: AppColors.darkblue,fontWeight: FontWeight.bold,fontSize: 16),),
               const SizedBox(height: 10,),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                      _buildDashboardCard(
                        title: 'STP',
                        color: AppColors.lightblue,
                        onTap: () => _navigateTo(context, AppRoutes.etp),
                      ),
                      const SizedBox(height: 8,),
                      _buildDashboardCard(
                        title: 'ETP',
                        color: AppColors.lightblue,
                        onTap: () => _navigateTo(context,  AppRoutes.etp),
                      ),
                      const SizedBox(height: 8,),
                      _buildDashboardCard(
                        title: 'WTP',
                        color: AppColors.lightblue,
                        onTap: () => _navigateTo(context, AppRoutes.etp),
                      ),
                      
                                ],
                              ),
                  ),
                ),
                  ],
                ),

        );
      }




  Widget _buildDashboardCard({
    required String title,
    required Color color,
    //required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.cream,
              ),
            ),
            const SizedBox(width: 16,),
            Transform.scale(
            scaleX: 0.7, 
            child:const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.yellowochre,
            ),
          ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeName) {
     Navigator.pushNamed(context, routeName);

  }
}
