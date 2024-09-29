import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../Util/Utils.dart';
import '../../../../app_colors.dart';
import '../../../../res/app_url.dart';

//accepting or rejecting expense...

class ExpenseApprovalManagerWidgets {
  static Widget approved(String uniqueID) {
    return ExpenseList(uniqueID: uniqueID, status: 'Accepted');
  }

  static Widget rejected(String uniqueID) {
    return ExpenseList(uniqueID: uniqueID, status: 'Rejected');
  }

  static Widget pending(String uniqueID) {
    return ExpenseList(uniqueID: uniqueID, status: 'Pending');
  }

  static Future<List<dynamic>> getExpenseRequestsManager(String uniqueID, String status) async {
    print('called getExpenseRequestManager');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    print('uid is:${userID}');
    String url = AppUrl.get_expense_requests_manager;
    Map<String, dynamic> data = {
      "reporting_officerId": int.parse(userID.toString())
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print('status code for list:${response.statusCode}');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List<dynamic> allExpenses = responseData['data'];
        print('allexp:${allExpenses}');
        // Filter expenses based on the status
        List<dynamic> filteredExpenses = allExpenses.where((expense) {
          return expense['status'] == status;
        }).toList();
        print('expenses:$filteredExpenses');
        return filteredExpenses;
      } else {
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  static Future<void> acceptRejectExpMngr(BuildContext context, int reportID, String? status) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    String? userID = preferences.getString('userID');
    String url = AppUrl.accept_reject_exp_mngr; // Replace with your actual URL
    Map<String, dynamic> data = {
      "report_id": reportID,
      "status": status,
      "approved_by": int.parse(userID.toString())
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print('object');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage2('${responseData['message']}', context);
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

}

class ExpenseList extends StatefulWidget {
  final String uniqueID;
  final String status;

  ExpenseList({required this.uniqueID, required this.status});

  @override
  _ExpenseListState createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  late Future<List<dynamic>> _expenseFuture;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    _expenseFuture = ExpenseApprovalManagerWidgets.getExpenseRequestsManager(widget.uniqueID, widget.status);
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _expenseFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(),);
        } else if (snapshot.hasError) {
          return Center(child: Text('Some error occurred!'),);
        } else if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              var snapdata = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.textfiedlColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(radius: 5, backgroundColor: AppColors.primaryColor,),
                                SizedBox(width: 10,),
                                Text('#TRNX${snapdata[index]['id']}'),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 20.0),
                              child: Text('${snapdata[index]['userDetails'][0]['name'].toString().toUpperCase()}', style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.borderColor,
                                  fontSize: 12)),
                            ),
                            // Padding(
                            //   padding: EdgeInsets.only(left: 20.0),
                            //   child: Text('${snapdata[index]['userDetails'][0]['designation'].toString().toUpperCase()}', style: TextStyle(
                            //       fontWeight: FontWeight.w400,
                            //       color: AppColors.borderColor,
                            //       fontSize: 12)),
                            // ),
                            SizedBox(height: 30,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.currency_rupee, size: 22,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 12.0),
                                          child: Text('${snapdata[index]['amount']}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),),
                                        ),
                                        Text('cash', style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.borderColor,
                                            fontSize: 12),)
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Text('${snapdata[index]['remark']}', style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: AppColors.borderColor,
                                fontSize: 12),),
                            SizedBox(height: 10,),
                            snapdata[index]['status'] == 'Pending'? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                InkWell(
                                  onTap: () {
                                    ExpenseApprovalManagerWidgets.acceptRejectExpMngr(context, int.parse(snapdata[index]['id'].toString()), 'Accepted').then((_) {
                                      setState(() {
                                        _loadExpenses(); // Reload expenses to refresh the list
                                      });
                                    });
                                  },
                                  child: Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: Text('Accept')),
                                      )),
                                ),
                                InkWell(
                                  onTap: () {
                                    ExpenseApprovalManagerWidgets.acceptRejectExpMngr(context, snapdata[index]['id'], "Rejected").then((_) {
                                      setState(() {
                                        _loadExpenses(); // Reload expenses to refresh the list
                                      });
                                    });
                                  },
                                  child: Container(
                                      width:100,
                                      decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(child: Text('Reject')),
                                      )),
                                ),
                              ],):Text(''),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${Utils.getTime(snapdata[index]['created_date'].toString())}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),),
                          Text('${Utils.formatDate(snapdata[index]['created_date'].toString())}', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 20,
                      top: 65,
                      child: Text('${snapdata[index]['status']}', style: TextStyle(
                          color: snapdata[index]['status'] == "Pending" ? Colors.grey : snapdata[index]['status'] == 'Rejected' ? Colors.red :Colors.green,
                          fontWeight: FontWeight.w400,
                          fontSize: 14
                      ),),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return Center(child: Text('Please restart your application'),);
      },
    );
  }
}