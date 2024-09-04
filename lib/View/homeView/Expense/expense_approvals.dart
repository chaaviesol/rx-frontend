import 'package:flutter/material.dart';
import 'package:rx_route_new/View/homeView/Expense/widgets.dart';


import '../../../Util/Routes/routes_name.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../home_view_rep.dart';

class ExpenseApprovals extends StatefulWidget {
  const ExpenseApprovals({super.key});

  @override
  State<ExpenseApprovals> createState() => _ExpenseApprovalsState();
}

class _ExpenseApprovalsState extends State<ExpenseApprovals> with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final List<Widget> _tabs = [
    const Tab(text: 'Approved'),
    const Tab(text: 'Rejected'),
    const Tab(text: 'Pending'),
  ];

  final List<Widget> _pages = [
    ExpenseApprovalsWidgets.approved("${Utils.uniqueID}"),
    ExpenseApprovalsWidgets.rejected("${Utils.uniqueID}"),
    ExpenseApprovalsWidgets.pending("${Utils.uniqueID}"),
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
        title: const Text('My Expenses', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: Colors.black,
          indicatorColor: Colors.green,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: (){
          Navigator.pushNamed(context, RoutesName.requestExpense);
        },
        child: Icon(Icons.add,color: AppColors.whiteColor,),
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
