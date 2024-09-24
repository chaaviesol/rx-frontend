import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
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
      Uri.parse(AppUrl.approveUsersTP),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': uniqueID}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _data = jsonDecode(response.body)['data'];
      });
    } else {
      // Handle error
    }
  }

  Future<void> _acceptTP(int id) async {
    final response = await http.post(
      Uri.parse(AppUrl.approveUserAddedTP),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'travelPlanId': id, 'userId': 2}),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Travel plan successfully approved');

      _fetchData(); // Refresh data
    } else {
      // Handle error
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
      // Handle error
    }
  }

  String formatDateTime(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd hh:mm a').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TP Approvals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Rejected'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent('Draft', showButtons: true),
          _buildTabContent('Cancel', showButtons: false),
          _buildTabContent('Approved', showButtons: false),
        ],
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
                  'TP IDs: ${item['id']}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'User: ${item['userdetails'][0]['name']}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Month: ${item['month']}',
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
                          print('called ');
                        },
                        child: Text('Accept',style: TextStyle(color: AppColors.whiteColor)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor, // Button color
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
                        child: Text('Reject',style: TextStyle(color: AppColors.whiteColor),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:AppColors.primaryColor, // Button color
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
