
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:rx_route_new/constants/styles.dart'; // Add this import for date formatting

class Hometilewidget extends StatefulWidget {
  const Hometilewidget({super.key});

  @override
  State<Hometilewidget> createState() => _HometilewidgetState();
}

class _HometilewidgetState extends State<Hometilewidget> {
  int totalCalls = 0;
  int visitedCalls = 0;
  int missedCalls = 0;
  bool isLoading = true;
  String visitPercentage ='0.0';

  String currentDate = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()); // Get current date

  @override
  void initState() {
    super.initState();
    _fetchCallData();
  }

  Future<void> _fetchCallData() async {
    final response = await http.post(
      Uri.parse('http://52.66.145.37:3004/user/visitedCount'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': 'GIK771'}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        totalCalls = data['data'];
        visitedCalls = data['visited'];
        missedCalls = data['missedVisit'];
        visitPercentage = data['visitedPercentage'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 20),
          // Total Calls Widget
          CallTileWidget(
            icon: Icons.phone_callback_sharp,
            title: 'Total Calls',
            totalCalls: totalCalls,
            missedcalls: missedCalls,
            visitedCalls: visitedCalls,
            updateDate: currentDate, // Use the current date here
            percentage: visitPercentage,
          ),
          SizedBox(width: 20),
          // Missed Calls Widget
          CallTileWidget(
            icon: Icons.call_missed_outgoing,
            title: 'Missed Calls',
            totalCalls: missedCalls,
            missedcalls: missedCalls,
            visitedCalls: visitedCalls,
            updateDate: currentDate, // Use the current date here
            percentage: visitPercentage,
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}

// Reusable Widget for Total and Missed Calls
class CallTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final int totalCalls;
  final int missedcalls;
  final int visitedCalls;
  final String percentage;
  final String updateDate;

  const CallTileWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.totalCalls,
    required this.missedcalls,
    required this.visitedCalls,
    required this.percentage,
    required this.updateDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 150,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 10,backgroundColor: AppColors.whiteColor,
                  child:Icon(size: 15,Icons.phone_callback_sharp,color: AppColors.primaryColor,)),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${totalCalls}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: Colors.white24,
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Row(
              //     children: [
              //       Icon(Icons.arrow_upward, color: Colors.white, size: 14),
              //       SizedBox(width: 4),
              //       Text(
              //         '${percentage}%',
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontSize: 14,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 10),
          Divider(),
          Text(
            'Updated: ${updateDate}', // Display the current date
            style: text40012bordercolor,
          ),
        ],
      ),
    );
  }
}