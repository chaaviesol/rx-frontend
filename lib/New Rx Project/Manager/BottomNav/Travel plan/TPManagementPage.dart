import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:rx_route_new/Util/Utils.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TPManagementPage extends StatefulWidget {
  @override
  _TPManagementPageState createState() => _TPManagementPageState();
}

class _TPManagementPageState extends State<TPManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? uniqueID = int.parse(preferences.getString('userID').toString());

    final response = await http.post(
      Uri.parse(AppUrl.getUserAddedTP),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': uniqueID}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      if (responseData['success']) {
        setState(() {
          _data = responseData['data']
              .map((item) => item['tp'])
              .toList(); // Extract only 'tp' part from each item
        });
      } else {
        // Handle error from API
        Utils.flushBarErrorMessage2(responseData['message'], context);
      }
    } else {
      // Handle error
      Utils.flushBarErrorMessage2('Failed to fetch data', context);
    }
  }

  Future<void> _acceptTP(int id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userID = int.parse(preferences.getString('userID').toString());
    final response = await http.post(
      Uri.parse(AppUrl.approveUserAddedTP),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'travelPlanId': id, 'userId': userID}),
    );
    print('approval data :${response.body}');
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Travel plan successfully approved');
      _fetchData(); // Refresh data
    } else {
      Utils.flushBarErrorMessage2('Travel plan approval failed!', context);
    }
  }

  Future<void> _rejectTP(int id) async {
    final response = await http.post(
      Uri.parse(AppUrl.rejectUserAddedTP),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'travelPlanId': id}),
    );

    if (response.statusCode == 200) {
      _fetchData(); // Refresh data
      Fluttertoast.showToast(msg: 'Travel plan successfully rejected.');
    } else {
      Utils.flushBarErrorMessage2('Rejecting travel plan failed!', context);
    }
  }

  String formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  // Function to convert the month number to its name
  String getMonthName(int month) {
    DateTime date = DateTime(0, month); // Creating a dummy date to get the month name
    return DateFormat.MMMM().format(date); // Full month name (e.g., September)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Rejected'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent('Submitted', showButtons: true),
                _buildTabContent('Cancel', showButtons: false),
                _buildTabContent('Approved', showButtons: false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String status, {required bool showButtons}) {
    final filteredData =
    _data.where((item) => item['status'] == status).toList();

    return ListView.builder(
      itemCount: filteredData.length,
      itemBuilder: (context, index) {
        final item = filteredData[index];
        final user = item['user']; // User data from the 'user' key

        return Card(
          color: AppColors.textfiedlColor,
          margin: const EdgeInsets.all(10),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TP ID: ${item['id']}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'User: ${user['name']}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Month: ${getMonthName(item['month'])}',  // Use month name instead of number
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 8),
                Text(
                  'Created Date: ${formatDateTime(item['created_date'])}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 12),
                if (showButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _acceptTP(item['id']);
                        },
                        child: Text('Accept', style: TextStyle(color: AppColors.whiteColor)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _rejectTP(item['id']);
                        },
                        child: Text('Reject', style: TextStyle(color: AppColors.whiteColor)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
