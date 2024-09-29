import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20Approvals/Doctor.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20Approvals/Expense.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20Approvals/Leave.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Tabs_widgets/Travel_plan_pages.dart';

import '../../../../View/homeView/Leave/leaveApprovals.dart';
import '../../../../app_colors.dart';
import '../../../../constants/styles.dart';
import '../../MyApprovals/apply_exp request.dart';

class MyLeaveandexpense extends StatefulWidget {
  const MyLeaveandexpense({Key? key}) : super(key: key);

  @override
  State<MyLeaveandexpense> createState() => _MyLeaveandexpenseState();
}

class _MyLeaveandexpenseState extends State<MyLeaveandexpense> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _tabs = [
    const Tab(text: 'Leave',),
    const Tab(text: 'Expense'),

  ];

  final List<Widget> _pages = [
    LeaveApprovals(),

    rep_expense(),

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
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.primaryColor,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Leave and Expense',
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
                tabAlignment: TabAlignment.startOffset,
                isScrollable: true,
                controller: _tabController,
                tabs: _tabs,
                labelColor: Colors.white,
                indicatorColor: AppColors.whiteColor,
                // labelStyle: TextStyle(color: Colors.white),
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
