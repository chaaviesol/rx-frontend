import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../constants/styles.dart';
import '../../../res/app_url.dart';
class LeaveApprovalsWidgets{
  static final TextEditingController _searchController = TextEditingController();

  static List<dynamic> LeaveData = [];

  static Future<dynamic> getleaves(String userID) async {

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueid = preferences.getString('uniqueID');
    Utils.uniqueID = uniqueid;
    String url = AppUrl.get_leaves;
    Map<String, dynamic> data = {
      "uniqueRequesterId":uniqueid
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print('body:${(data)}');
      print('st code :${response.statusCode}');
      print('st code :${response.body}');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('resp data = ${responseData}');
        LeaveData.clear();
        LeaveData.addAll(responseData['data']);
        print('lv data ;:${LeaveData}');
        return responseData;
      } else {
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  static Widget approved(String userID) {
    return FutureBuilder(
      future: getleaves(userID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          var response = snapshot.data;
          var leaveData = response['data'] ?? [];
          var userData = response['userData']?.isNotEmpty == true ? response['userData'][0] : {};

          if (leaveData.isEmpty) {
            return Center(child: Text('No data available!'));
          }

          var acceptedLeaves = leaveData.where((item) => item['status'] == 'Accepted').toList();

          if (acceptedLeaves.isEmpty) {
            return Center(child: Text('No accepted leaves found!'));
          }

          String userName = userData['name'] ?? 'Unknown';
          String userDesignation = userData['designation'] ?? 'Unknown';

          return Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            // Implement search functionality if needed
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: Image.asset('assets/icons/settings.png'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: acceptedLeaves.length,
                    itemBuilder: (context, index) {
                      var leave = acceptedLeaves[index];
                      int dayDifference = Utils.calculateDaysDifference(
                          leave['from_date'], leave['to_date']);

                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.textfiedlColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 50),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 30.0, left: 10.0, right: 10.0, bottom: 20.0),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('${leave['from_date']}', style: text50012black)
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50),
                                                border: Border.all(width: 1, color: AppColors.blackColor),
                                              ),
                                            ),
                                            const Expanded(child: Divider(indent: 10, color: AppColors.primaryColor)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                              child: Column(
                                                children: [
                                                  Text('$dayDifference ${dayDifference == 1 ? 'day' : 'days'}', style: text50012black),
                                                ],
                                              ),
                                            ),
                                            const Expanded(child: Divider(endIndent: 10, color: AppColors.primaryColor)),
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                color: AppColors.blackColor,
                                                borderRadius: BorderRadius.circular(50),
                                                border: Border.all(width: 5, color: Colors.grey),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Column(
                                              children: [
                                                Text('${leave['to_date']}', style: text50012black),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text('${leave['type']}', style: text50010black),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text('${leave['remark']}'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50)
                                ],
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${userName.toUpperCase()}', style: text50014black),
                                  Text('${userDesignation.toUpperCase()}', style: text50010tcolor2),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Utils.formatDate('${leave['created_date']}'), style: text50014black),
                                  const SizedBox(height: 10),
                                  Text('${leave['status']?.toUpperCase() ?? 'Unknown'}', style: text40016),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        } else {
          return Center(child: Text('Some error happened! Please restart your application.'));
        }
      },
    );
  }

  static Widget rejected(String ID) {
    return FutureBuilder(
      future: getleaves(ID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Some error happened!'));
        } else if (snapshot.hasData) {
          var data = snapshot.data;
          if (data == null || !data.containsKey('data') || !data.containsKey('userData')) {
            return Center(child: Text('No data available!'));
          }

          var leavesData = data['data'];
          var userData = data['userData']?.isNotEmpty == true ? data['userData'][0] : {};

          var rejectedLeaves = leavesData.where((item) => (item['status']?.trim() ?? '') == 'Rejected').toList();

          if (rejectedLeaves.isEmpty) {
            return Center(child: Text('No rejected leaves found!'));
          }

          String userName = userData['name'] ?? 'Unknown';
          String userDesignation = userData['designation'] ?? 'Unknown';

          return Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: Image.asset('assets/icons/settings.png'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: rejectedLeaves.length,
                    itemBuilder: (context, index) {
                      var leave = rejectedLeaves[index];
                      int dayDifference = Utils.calculateDaysDifference(
                          leave['from_date'],
                          leave['to_date']
                      );

                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.textfiedlColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 50),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 30.0,
                                            left: 10.0,
                                            right: 10.0,
                                            bottom: 20.0
                                        ),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('${leave['from_date']}', style: text50012black),
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50),
                                                border: Border.all(width: 1, color: AppColors.blackColor),
                                              ),
                                            ),
                                            const Expanded(child: Divider(indent: 10, color: AppColors.primaryColor)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                              child: Column(
                                                children: [
                                                  Text('$dayDifference ${dayDifference == 1 ? 'day' : 'days'}', style: text50012black),
                                                ],
                                              ),
                                            ),
                                            const Expanded(child: Divider(endIndent: 10, color: AppColors.primaryColor)),
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                color: AppColors.blackColor,
                                                borderRadius: BorderRadius.circular(50),
                                                border: Border.all(width: 5, color: Colors.grey),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Column(
                                              children: [
                                                Text('${leave['to_date']}', style: text50012black),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text('${leave['type']}', style: text50010black),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text('${leave['remark']}'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${userName.toUpperCase()}', style: text50014black),
                                  Text('${userDesignation.toUpperCase()}', style: text50010tcolor2),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Utils.formatDate('${leave['created_date'] ?? 'N/A'}'), style: text50014black),
                                  const SizedBox(height: 10),
                                  Text('${leave['status']?.toString().toUpperCase() ?? 'N/A'}', style: text40016red),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text('Some error happened! Please restart your application.'));
        }
      },
    );
  }
  static Widget pending(String ID) {
    return FutureBuilder(
      future: getleaves(ID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Some error happened!'));
        } else if (snapshot.hasData) {
          var data = snapshot.data;
          if (data == null || !data.containsKey('data')) {
            return Center(child: Text('No data available!'));
          }

          var leavesData = data['data'];
          var userData = data['userData']; // Extract userData
          var pendingLeaves = leavesData.where((item) => (item['status']?.trim() ?? '') == 'Pending').toList();

          return Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: Image.asset('assets/icons/settings.png'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: pendingLeaves.length,
                    itemBuilder: (context, index) {
                      var leave = pendingLeaves[index];
                      int dayDifference = Utils.calculateDaysDifference(
                          leave['from_date'],
                          leave['to_date']
                      );

                      // Extract user info
                      var requester = userData.firstWhere((user) => user['uniqueId'] == leave['uniqueRequester_Id'], orElse: () => {'name': 'Unknown', 'designation': 'Unknown'});

                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.textfiedlColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 50),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 30.0,
                                          left: 10.0,
                                          right: 10.0,
                                          bottom: 20.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text('${leave['from_date']}', style: text50012black),
                                              ],
                                            ),
                                            const SizedBox(width: 20),
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50),
                                                border: Border.all(width: 1, color: AppColors.blackColor),
                                              ),
                                            ),
                                            const Expanded(child: Divider(indent: 10, color: AppColors.primaryColor)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                              child: Column(
                                                children: [
                                                  Text('$dayDifference ${dayDifference == 1 ? 'day' : 'days'}', style: text50012black),
                                                ],
                                              ),
                                            ),
                                            const Expanded(child: Divider(endIndent: 10, color: AppColors.primaryColor)),
                                            Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                color: AppColors.blackColor,
                                                borderRadius: BorderRadius.circular(50),
                                                border: Border.all(width: 5, color: Colors.grey),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Column(
                                              children: [
                                                Text('${leave['to_date']}', style: text50012black),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text('${leave['type']}', style: text50010black),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10.0, right: 10, top: 10, bottom: 10),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text('${leave['remark']}'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${requester['name']}', style: text50014black), // Display name from userData
                                  Text('${requester['designation']}', style: text50010tcolor2), // Display designation from userData
                                ],
                              ),
                            ),
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(Utils.formatDate('${leave['created_date']}'), style: text50014black),
                                  const SizedBox(height: 10),
                                  Text('${leave['status'].toString().toUpperCase()}', style: TextStyle(color: Colors.black45)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text('Some error happened! Please restart your application.'));
        }
      },
    );
  }

}

