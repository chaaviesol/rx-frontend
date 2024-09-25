import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../Util/Routes/routes_name.dart';
import '../../../../Util/Utils.dart';
import '../../../../View/homeView/Expense/exp_manager/exp_approval_mngr_widgets.dart';
import '../../../../View/homeView/Expense/expense_request.dart';
import '../../../../View/homeView/Expense/widgets.dart';
import '../../../../View/homeView/home_view_rep.dart';
import '../../../../app_colors.dart';
import '../../../../constants/styles.dart';

class myapprovelexpense extends StatefulWidget {
  const myapprovelexpense({super.key});

  @override
  State<myapprovelexpense> createState() => _myapprovelexpenseState();
}

class _myapprovelexpenseState extends State<myapprovelexpense> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _tabs = [
    const Tab(text: 'Pending'),
    const Tab(text: 'Rejected'),
    const Tab(text: 'Accepted'),

  ];

  final List<Widget> _pages = [
    ExpenseApprovalManagerWidgets.pending("${Utils.uniqueID}"),
    ExpenseApprovalManagerWidgets.rejected("${Utils.uniqueID}"),
    ExpenseApprovalManagerWidgets.approved("${Utils.uniqueID}"),


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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: _tabs,
                  labelColor: Colors.black,
                  indicatorColor: Colors.green,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _pages,
                  ),
                ),
              ],
            ),
            // Positioned(
            //   left: MediaQuery.of(context).size.width/3,
            //   bottom: MediaQuery.of(context).size.height/7.9,
            //   child: ElevatedButton(style: ElevatedButton.styleFrom
            //     (backgroundColor: AppColors.primaryColor)
            //     ,onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseRequestPage(),));
            //
            //   }, child: Text('Expense Request',style: text50012,),),
            // ),
          ],
        ),
      ),
    );
  }
}
