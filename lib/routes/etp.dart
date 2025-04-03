import 'package:flutter/material.dart';
import 'package:waterplant/components/CustomAppBar.dart';
import 'package:waterplant/components/customdrawer.dart';
import 'package:waterplant/config.dart';

class Etp extends StatefulWidget {
  const Etp({super.key});

  @override
  State<Etp> createState() => _EtpState();
}

class _EtpState extends State<Etp> {
  final List<String> _plantNames = ['PLANT 1', 'PLANT 2', 'PLANT 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar:const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         const SizedBox(height: 16,),
                    Padding(
                   padding: const EdgeInsets.all(8.0),
                   child: Container(
                    padding:const  EdgeInsets.all(10),
                    child:const  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SELECT YOUR WORKPLACE',style: TextStyle(color: AppColors.darkblue,fontSize: 20,fontWeight: FontWeight.bold),),
                        SizedBox(height: 12,),
                      ],
                    ),
                   ),
                 ),

          Expanded(
            child: ListView.builder(
              itemCount: _plantNames.length,
              itemBuilder: (context, index) {
                return Card(
                  color: AppColors.lightblue,
                  margin: const EdgeInsets.all(12.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(_plantNames[index],style: const TextStyle(color: AppColors.cream),),
                    onTap: () {Navigator.pushNamed(
                      context, AppRoutes.etpdata,
                      arguments: _plantNames[index]
                      );},
                    trailing: const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.yellowochre,
            ),
                  ),
                );
              },
            ),
          ),
           Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.darkblue),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

