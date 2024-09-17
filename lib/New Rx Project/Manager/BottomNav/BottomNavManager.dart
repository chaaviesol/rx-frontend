import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My_Reports.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20Approvals/My_approvels.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20lists/My_list.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/TpDoctorListPage.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/Doctors_mngr/Add%20Doctor.dart';
import 'package:rx_route_new/New%20Rx%20Project/Rep/Bottom%20navigation%20rep/Leave%20and%20expense/Leave%20and%20expense.dart';
import 'package:rx_route_new/app_colors.dart';

import '../../../constants/styles.dart';
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
    Myreports(),
    Mngr_T_P(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
      _showButtons = index == 0;  // Show the plus button only on the home page
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: pages,
              ),
              if (_showButtons)
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 56 + 16, // Adjust for bottom padding and nav bar height
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
                      SizedBox(height: 80,)
                    ],
                  ),
                ),
              buildBottomNavigationBar(),
              if (currentIndex == 0) // Only show the plus button on the home page
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 56 + 30, // Adjust for bottom padding and nav bar height
                  right: 20,
                  child: FloatingActionButton(
                    backgroundColor: AppColors.primaryColor,
                    onPressed: _toggleButtons,
                    shape: CircleBorder(), // Ensures the button is circular
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ),
              if(currentIndex == 0)
                Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 56 + 30,
                    left: 20,
                    child: FloatingActionButton(
                        backgroundColor: AppColors.primaryColor,
                        shape: CircleBorder(),
                        onPressed: () {
                          int currentMonth = DateTime.now().month;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TpDoctorListPage(month: currentMonth),));
                        }, child: Icon(Icons.add_chart_rounded,color: AppColors.whiteColor,)))
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
      onPressed: () {
        if (page is Widget) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        }
      },
      child: Text(label, style: text60012),
    );
  }

  Widget buildBottomNavigationBar() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 16, // Adjust for bottom padding
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
              Expanded(child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/myhome.png', height: 24, width: 24),
                  index: 0, title: "Home")),
              Expanded(child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/mylist.png', height: 24, width: 24),
                  index: 1, title: "My List")),
              Expanded(child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/myapprovals.png', height: 24, width: 24),
                  index: 2, title: "Approvals")),
              Expanded(child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/myreports.png', height: 24, width: 24),
                  index: 3, title: "Reports")),
              Expanded(child: buildNavItem(
                  iconWidget: Image.asset('assets/icons/mytp.png', height: 24, width: 24),
                  index: 4, title: "TP")),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem({IconData? iconData, Widget? iconWidget, required int index, required String title}) {
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
            iconWidget ?? Icon(iconData, size: 24, color: isSelected ? Colors.white : Colors.white70),
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
