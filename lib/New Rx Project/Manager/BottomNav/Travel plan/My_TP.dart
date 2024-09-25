import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app_colors.dart';
import '../../../../constants/styles.dart';

import 'Tabs_widgets/Tpevents_page.dart';
import 'Tabs_widgets/Travel_plan_pages.dart';

class Mngr_T_P extends StatefulWidget {
  const Mngr_T_P({Key? key}) : super(key: key);

  @override
  State<Mngr_T_P> createState() => _Mngr_T_PState();
}

class _Mngr_T_PState extends State<Mngr_T_P> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _tabs = [
    const Tab(text: 'Travel plan',),
    const Tab(text: 'Events'),

  ];



  List<Widget> _pages = [
    TravelPlanmainpage(),
    Events_page()


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
      appBar: AppBar(
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
        automaticallyImplyLeading: false,
        title: Text(
          'Travel Plans',
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
              child: TabBar(
                unselectedLabelColor: Colors.white,
                labelStyle: text40014,
                controller: _tabController,
                tabs: _tabs,
                labelColor: Colors.white,
                indicatorColor: AppColors.whiteColor,
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
