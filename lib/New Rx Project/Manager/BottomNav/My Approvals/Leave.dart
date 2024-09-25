import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../Util/Routes/routes_name.dart';
import '../../../../Util/Utils.dart';
import '../../../../View/homeView/Leave/LeaveRequest.dart';
import '../../../../View/homeView/Leave/leav_manager/manager_approve_leaves_widget.dart';
import '../../../../View/homeView/Leave/widgets.dart';
import '../../../../View/homeView/home_view_rep.dart';
import '../../../../app_colors.dart';
import '../../../../constants/styles.dart';


class myapprovelleave extends StatefulWidget {
  const myapprovelleave({super.key});

  @override
  State<myapprovelleave> createState() => _myapprovelleaveState();
}

class _myapprovelleaveState extends State<myapprovelleave> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final List<Widget> _tabs = [

    const Tab(text: 'Pending'),
    const Tab(text: 'Rejected'),
    const Tab(text: 'Accepted'),

  ];

  final List<Widget> _pages = [
    ManagerApproveLeavesWidget.pending("${Utils.uniqueID}"),
    ManagerApproveLeavesWidget.rejected("${Utils.uniqueID}"),
    ManagerApproveLeavesWidget.approved("${Utils.uniqueID}"),

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
            //   child: ElevatedButton(style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primaryColor),
            //     onPressed: () {
            //    Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveApplyPage(),));
            //
            //   }, child: Text('Leave Request',style: text50012,),),
            // ),
          ],
        ),
      ),
    );
  }

}
