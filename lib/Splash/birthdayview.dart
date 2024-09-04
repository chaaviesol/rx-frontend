import 'package:flutter/material.dart';


import '../app_colors.dart';

class BirthdayView extends StatefulWidget {
  const BirthdayView({super.key});

  @override
  State<BirthdayView> createState() => _BirthdayViewState();
}

class _BirthdayViewState extends State<BirthdayView> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height/2,
                width: MediaQuery.of(context).size.width/1.2,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  gradient:const LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      Colors.black
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter
                  ),
                  boxShadow:const [
                    BoxShadow(
                      color: AppColors.blackColor,
                      blurRadius: 10,
                      offset: Offset(-1,-1),
                      spreadRadius: 1,
                    )
                  ]

                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Sunday 27/07/2024',style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize:12,
                        color: AppColors.whiteColor,
                      ),),
                    ),
                    SizedBox(
                      height: 200,
                        width: 200,
                        child: Image.asset('assets/icons/cake.png')),
                    const SizedBox(height: 10,),
                  ],
                )),
          ),
          const SizedBox(height: 30,),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 20,),
              Expanded(
                child: Divider(
                  color: AppColors.blackColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0,right: 10.0),
                child: Text('7 Hours until Helenas\'s Birthday',style: TextStyle(
                  color:AppColors.primaryColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 10
                ),),
              ),
              Expanded(
                child: Divider(
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(width: 20,),
            ],
          )
        ],
      ),
    );
  }
}
