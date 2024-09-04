import 'package:flutter/material.dart';

import '../../app_colors.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color:AppColors.primaryColor, // Replace with your desired color
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(onTap: (){
              Navigator.pop(context);
            },
                child: const Icon(Icons.arrow_back, color: Colors.white)), // Adjust icon color
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 10,
          shrinkWrap: true,
          itemBuilder: (context,index) {
            return Column(
              children: [
                Stack(
                  children: [
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 35,right: 10,top: 10,bottom: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration:const BoxDecoration(
                                    color: AppColors.primaryColor4,
                                  ),
                                    child: const Icon(Icons.alarm,color: AppColors.primaryColor3,)),
                                const Text('Reminder!',style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: AppColors.blackColor
                                ),)
                              ],
                            ),
                            const SizedBox(height: 10,),
                            const Text('Today is Doctor Helena hills birthday your alarm has set at 09:20 AM Wish her all the best'),
                            const SizedBox(height: 20,),
                            const Row(
                              children: [
                                Text('Mark As done',style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor4
                                ),),
                                SizedBox(width: 30,),
                                Text('Update',style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColor4
                                ),),
                              ],
                            ),
                            const Divider()
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 15,
                        left: 16,
                        child: CircleAvatar(radius: 8,backgroundColor: Colors.red,)),
                  ],
                )
              ],
            );
          }
        ),
      ),
    );
  }
}
