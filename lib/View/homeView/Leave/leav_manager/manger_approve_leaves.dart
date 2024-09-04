import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // Importing TickerProviderStateMixin

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../Util/Utils.dart';
import '../../../../app_colors.dart';
import '../../../../res/app_url.dart';
import '../../home_view_rep.dart';
import 'manager_approve_leaves_widget.dart';

class ManagerApproveLeaves extends StatefulWidget {
  const ManagerApproveLeaves({super.key});

  @override
  State<ManagerApproveLeaves> createState() => _ManagerApproveLeavesState();
}

class _ManagerApproveLeavesState extends State<ManagerApproveLeaves> with TickerProviderStateMixin { // Mixing in TickerProviderStateMixin

  late TabController _tabController;

  final List<Widget> _tabs = [
    const Tab(text: 'Accepted'),
    const Tab(text: 'Rejected'),
    const Tab(text: 'Pending'),
  ];

  final List<Widget> _pages = [
    ManagerApproveLeavesWidget.approved("${Utils.uniqueID}"),
    ManagerApproveLeavesWidget.rejected("${Utils.uniqueID}"),
    ManagerApproveLeavesWidget.pending("${Utils.uniqueID}"),
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
          ),
        ],
        title: const Text('Approve Leaves', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: Colors.black,
          indicatorColor: Colors.green,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
 
}
