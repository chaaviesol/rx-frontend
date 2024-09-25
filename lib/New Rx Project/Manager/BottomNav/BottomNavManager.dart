
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui'; // Import for blur effect

import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My_Reports.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20Approvals/My_approvels.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20lists/My_list.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/Doctors_mngr/Add%20Doctor.dart';
import 'package:rx_route_new/New%20Rx%20Project/Reports/reportsMainPage.dart';
import 'package:rx_route_new/app_colors.dart';

import '../../../constants/styles.dart';
import '../../Rep/Bottom navigation rep/Leave and expense/Leave and expense.dart';
import '../Doctors_mngr/Add_chemist.dart';
import '../Doctors_mngr/Add_employee.dart';
import 'HomepageManagerNew.dart';
import 'Travel plan/My_TP.dart';

class BottomNavigationMngr extends StatefulWidget {
  const BottomNavigationMngr({Key? key}) : super(key: key);

  @override
  State<BottomNavigationMngr> createState() => _BottomNavigationMngrState();
}

class _BottomNavigationMngrState extends State<BottomNavigationMngr>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late PageController _pageController;
  bool _showButtons = false;

  final pages = [
    HomepageManager(),
    My_list(),
    MyApproval(),
    // Myreports(),
    Reportsmainpage(),
    Mngr_T_P(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _showButtons = false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
      _showButtons = false;  // Hide buttons when navigating to other pages
    });
  }

  void _onNavItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void _toggleButtons() {
    setState(() {
      _showButtons = !_showButtons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: pages,
          ),
          if (_showButtons)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Blur effect
                child: Container(
                  color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
                ),
              ),
            ),
          if (_showButtons)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 56 + 16,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildActionButton('Add Doctor', Add_doctor_mngr()),
                  SizedBox(height: 10),
                  _buildActionButton('Add Chemist', Adding_chemistmngr()),
                  SizedBox(height: 10),
                  _buildActionButton('Add Employee', Adding_employee_mngr()),
                  SizedBox(height: 10),
                  _buildActionButton('Leave & Expense', MyLeaveandexpense()),
                  SizedBox(height: 80,),
                ],
              ),
            ),
          buildBottomNavigationBar(),
          if (currentIndex == 0)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 56 + 30,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: AppColors.primaryColor,
                onPressed: _toggleButtons,
                shape: CircleBorder(),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
      onPressed: () {
        setState(() {
          _showButtons = false; // Hide buttons after navigating
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Text(label, style: text60012),
    );
  }

  Widget buildBottomNavigationBar() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/myhome.png',
                      height: 24, width: 24),
                  index: 0,
                  title: "Home",
                ),
              ),
              Expanded(
                child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/mylist.png',
                      height: 24, width: 24),
                  index: 1,
                  title: "My List",
                ),
              ),
              Expanded(
                child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/myapprovals.png',
                      height: 24, width: 24),
                  index: 2,
                  title: "Approvals",
                ),
              ),
              Expanded(
                child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/myreports.png',
                      height: 24, width: 24),
                  index: 3,
                  title: "Reports",
                ),
              ),
              Expanded(
                child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/mytp.png',
                      height: 24, width: 24),
                  index: 4,
                  title: "TP",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem({
    IconData? iconData,
    Widget? iconWidget,
    required int index,
    required String title,
  }) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: AnimatedContainer(
        color: AppColors.primaryColor,
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget ??
                Icon(iconData,
                    size: 24,
                    color: isSelected ? Colors.white : Colors.white70),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
