import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20lists/Chemist%20list.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20lists/Doctor%20list.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20lists/Employee_list.dart';
import 'package:rx_route_new/View/homeView/Employee/emp_list.dart';

import '../../../../app_colors.dart';
import '../../../../constants/styles.dart';

class My_list_rep extends StatefulWidget {
  const My_list_rep({Key? key}) : super(key: key);

  @override
  State<My_list_rep> createState() => _My_list_repState();
}

class _My_list_repState extends State<My_list_rep> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _tabs = [
    const Tab(text: 'Doctor'),

    const Tab(text: 'Chemist'),
  ];

  List<Widget> _pages = [
    DoctorList(),


    ChemistList(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,
        backgroundColor: AppColors.whiteColor,
        // leading: IconButton(
        //   icon: CircleAvatar(
        //     backgroundColor: Colors.white,
        //     child: Icon(
        //       Icons.arrow_back_ios_rounded,
        //       color: AppColors.primaryColor,
        //     ),
        //   ),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
        title: Text(
          'My List',
          style: text40016black,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar( tabAlignment: TabAlignment.start,
                isScrollable: true,
                controller: _tabController,
                tabs: _tabs,
                labelColor: Colors.white,
                indicatorColor: AppColors.whiteColor,
                unselectedLabelColor: Colors.white,

              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: TabBarView(

          controller: _tabController,
          children: _pages,
        ),
      ),
    );
  }
}
