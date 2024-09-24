import 'package:flutter/material.dart';
import 'package:rx_route_new/app_colors.dart';

import '../Manager/BottomNav/My_Reports.dart';

class Reportsmainpage extends StatefulWidget {
  const Reportsmainpage({super.key});

  @override
  State<Reportsmainpage> createState() => _ReportsmainpageState();
}

class _ReportsmainpageState extends State<Reportsmainpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text('Reports'),
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 items per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2, // Customize this to change container size ratio
          ),
          itemCount: 3, // Total number of containers
          itemBuilder: (context, index) {
            if (index == 2) {
              // Larger container for "My Report"
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Myreports(),
                  ));
                },
                child: Container(
                  height: 200,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      'My Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Other containers for DCR and Monthly DCR
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    index == 0 ? 'DCR' : 'Monthly DCR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

