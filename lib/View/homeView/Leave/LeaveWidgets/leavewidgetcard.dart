import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../../../../constants/styles.dart';
class LeaveApprovalsCardWidget extends StatelessWidget {
  dynamic data;
  LeaveApprovalsCardWidget({
    required this.data,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
              color: AppColors.textfiedlColor
          ),
          child: Column(
            children: [
              const SizedBox(height: 50,),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0,left: 10.0,right: 10.0,bottom: 20.0),
                    child: Row(
                      children: [
                        const Column(
                          children: [
                            Text('05th'),
                            Text('Feb 2024'),
                            Text('(monday)'),
                          ],
                        ),
                        const SizedBox(width: 20,),
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(width: 1,color: AppColors.blackColor)
                          ),),
                        const Expanded(child: Divider(indent:10,color: AppColors.primaryColor,)),
                        const Padding(
                          padding: EdgeInsets.only(left: 10.0,right: 10.0),
                          child: Column(
                            children: [
                              Text('1 day',style:text50014black,),
                              Text('10 Days available',style:text50010,),
                            ],
                          ),
                        ),
                        const Expanded(child: Divider(endIndent:10,color: AppColors.primaryColor,)),
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              color: AppColors.blackColor,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(width: 5,color: Colors.grey)
                          ),),
                        const SizedBox(width: 20,),
                        const Column(
                          children: [
                            Text('06th'),
                            Text('Feb 2024'),
                            Text('(monday)'),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10,),
              const Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: Text('Sick Leave',style: text50010black,),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0,right: 20,top: 10,bottom: 10),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(6)
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('Dear manager, i am unwell and, as advised by my doctor,needed to take sick leave for the next two days to recoveri will ensure to keep you updated on my progress andcomplete any pending work, upon my return '),
                  ),
                ),
              ),
              const SizedBox(height: 50,)
            ],
          ),
        ),
         Positioned(
          top: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${data['data']}',style: text50014black,),
              Text('Medical rep',style: text50010tcolor2,),
            ],
          ),
        ),
        const Positioned(
          top: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('13-04-2024',style: text50014black,),
              SizedBox(height: 10,),
              Text('APPROVED',style: text40016,),
            ],
          ),
        ),
      ],
    );
  }
}