import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import '../../../../Util/Utils.dart';
import '../../../../app_colors.dart';
import '../../../../constants/styles.dart';
import '../../../../res/app_url.dart';

class ManagerApproveLeavesWidget {
  static Widget approved(String uniqueID) {
    return LeaveList(
      uniqueID: uniqueID,
      status: 'Accepted',
    );
  }

  static Widget rejected(String uniqueID) {
    return LeaveList(uniqueID: uniqueID, status: 'Rejected');
  }

  static Widget pending(String uniqueID) {
    return LeaveList(uniqueID: uniqueID, status: 'Pending');
  }

  static Future<List<dynamic>> getLeavesRequestsManager(String uniqueID, String status) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueid = preferences.getString('uniqueID');
    String? userID = preferences.getString('userID');
    String url = AppUrl.getLeaveRequest;
    Map<String, dynamic> data = {
      "reportingOfficer_id": int.parse(userID.toString())
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print('body:${(data)}');
      print('st code :${response.statusCode}');
      print('st code :${response.body}');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        List<dynamic> allLeaves = responseData['data'];
        print('allleaves:${allLeaves}');
        // Filter expenses based on the status
        List<dynamic> filteredLeaves = allLeaves.where((leaves) {
          return leaves['status'] == status;
        }).toList();
        print('leaves:$filteredLeaves');
        return filteredLeaves;
      } else {
        throw Exception(
            'Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
    // Replace with your actual implementation to fetch expense requests based on status
    // This is a placeholder implementation
    return Future.delayed(Duration(seconds: 2), () => []);
  }

  static Future<void> acceptRejectLeavMngr(BuildContext context, int reportID, String? status,int leaveID) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    String url = AppUrl.accept_leave; // Replace with your actual URL
    Map<String, dynamic> data = {
      "leave_tableId":leaveID,
      "rep_id":reportID,
      "modified_by":int.parse(userID.toString()),
      "status":status,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('bdy:${jsonEncode(data)}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }
}

class LeaveList extends StatefulWidget {
  final String uniqueID;
  final String status;
  LeaveList({required this.uniqueID, required this.status});

  @override
  State<LeaveList> createState() => _LeaveListState();
}

class _LeaveListState extends State<LeaveList> {
  late Future<List<dynamic>> _leaveFuture;

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  void _loadLeaves() {
    _leaveFuture = ManagerApproveLeavesWidget.getLeavesRequestsManager(
        widget.uniqueID, widget.status);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _leaveFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Some error happened !'),
            );
          } else if (snapshot.hasData) {
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
                    flex: 3,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var snapdata = snapshot.data!;
                        int dayDiffrence = Utils.calculateDaysDifference(
                          snapdata[index]['from_date'],
                          snapdata[index]['to_date'],
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
                                            bottom: 20.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    '${snapdata[index]['from_date'].toString()}',
                                                    style: text50012black,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(width: 20),
                                              Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(50),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: AppColors.blackColor,
                                                  ),
                                                ),
                                              ),
                                              const Expanded(
                                                child: Divider(
                                                  indent: 10,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      '${dayDiffrence} day',
                                                      style: text50012black,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Expanded(
                                                child: Divider(
                                                  endIndent: 10,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  color: AppColors.blackColor,
                                                  borderRadius: BorderRadius.circular(50),
                                                  border: Border.all(
                                                    width: 5,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Column(
                                                children: [
                                                  Text(
                                                    '${snapdata[index]['to_date'].toString()}',
                                                    style: text50012black,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: EdgeInsets.only(left: 20.0),
                                      child: Text(
                                        '${snapdata[index]['type']}',
                                        style: text50010black,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10,
                                        top: 10,
                                        bottom: 10,
                                      ),
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteColor,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(10.0),
                                          child: Text('${snapdata[index]['remark']}'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    snapdata[index]['status'] == 'Pending'
                                        ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            ManagerApproveLeavesWidget.acceptRejectLeavMngr(
                                              context,
                                              int.parse(snapdata[index]['repDetails'][0]['id'].toString()),
                                              'Accepted',
                                              int.parse(snapdata[index]['id'].toString()),
                                            ).then((_) {
                                              setState(() {
                                                _loadLeaves(); // Reload expenses to refresh the list
                                              });
                                            });
                                          },
                                          child: Container(
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: AppColors.whiteColor,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Center(child: Text('Accept', style: text50014black)),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            ManagerApproveLeavesWidget.acceptRejectLeavMngr(
                                              context,
                                              int.parse(snapdata[index]['repDetails'][0]['id'].toString()),
                                              'Rejected',
                                              int.parse(snapdata[index]['id'].toString()),
                                            ).then((_) {
                                              setState(() {
                                                _loadLeaves(); // Reload expenses to refresh the list
                                              });
                                            });
                                          },
                                          child: Container(
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: AppColors.whiteColor,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Center(child: Text('Reject', style: text50014black)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                        : Text(''),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 20,
                                left: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${snapdata[index]['repDetails'][0]['name'].toString().toUpperCase()}',
                                      style: text50014black,
                                    ),
                                    Text(
                                      '${snapdata[index]['repDetails'][0]['designation'].toString().toUpperCase()}',
                                      style: text50010tcolor2,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Utils.formatDate('${snapdata[index]['created_date'].toString()}'),
                                      style: text50014black,
                                    ),
                                    SizedBox(height: 10),
                                   Text(
                                      '${snapdata[index]['status'].toString().toUpperCase()}',
                                      style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14,color:snapdata[index]['status'] == 'Rejected' ? Colors.red:Colors.black),
                                    ),
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

          } else
            return Center(
              child: Text(
                  'Some error happened ! , please restart your application'),
            );
        });
  }
}

// ListView.builder(
//   shrinkWrap: true,
//     itemCount: snapshot.data!
//         .where((item) => item['status'] == 'Accepted')
//         .toList()
//         .length,
//     itemBuilder: (context, index) {
//       var snapdata = snapshot.data!
//           .where((item) => item['status'] == 'Accepted')
//           .toList();
//       int dayDiffrence = Utils.calculateDaysDifference(
//           snapdata[index]['from_date'],
//           snapdata[index]['to_date']);
//       return Padding(
//         padding:
//             const EdgeInsets.only(top: 10.0, bottom: 10.0),
//         child: Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                   color: AppColors.textfiedlColor,
//                   borderRadius: BorderRadius.circular(6)),
//               child: Column(
//                 children: [
//                   const SizedBox(
//                     height: 50,
//                   ),
//                   Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(
//                             top: 30.0,
//                             left: 10.0,
//                             right: 10.0,
//                             bottom: 20.0),
//                         child: Row(
//                           children: [
//                             Column(
//                               children: [
//                                 Text(
//                                     '${snapdata[index]['from_date'].toString().substring(0, 2)}' +
//                                         'th'),
//                                 Text(
//                                     '${Utils.formatMonth(snapdata[index]['from_date'].toString())}'),
//                                 Text(
//                                     '(${Utils.formatDay(snapdata[index]['from_date']).toString().substring(0, 3)})'),
//                               ],
//                             ),
//                             const SizedBox(
//                               width: 20,
//                             ),
//                             Container(
//                               height: 20,
//                               width: 20,
//                               decoration: BoxDecoration(
//                                   borderRadius:
//                                       BorderRadius.circular(
//                                           50),
//                                   border: Border.all(
//                                       width: 1,
//                                       color: AppColors
//                                           .blackColor)),
//                             ),
//                             const Expanded(
//                                 child: Divider(
//                               indent: 10,
//                               color: AppColors.primaryColor,
//                             )),
//                             Padding(
//                               padding: EdgeInsets.only(
//                                   left: 10.0, right: 10.0),
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     '${dayDiffrence} day',
//                                     style: text50014black,
//                                   ),
//                                   // Text('10 Days available',style:text50010,),
//                                 ],
//                               ),
//                             ),
//                             const Expanded(
//                                 child: Divider(
//                               endIndent: 10,
//                               color: AppColors.primaryColor,
//                             )),
//                             Container(
//                               height: 20,
//                               width: 20,
//                               decoration: BoxDecoration(
//                                   color:
//                                       AppColors.blackColor,
//                                   borderRadius:
//                                       BorderRadius.circular(
//                                           50),
//                                   border: Border.all(
//                                       width: 5,
//                                       color: Colors.grey)),
//                             ),
//                             const SizedBox(
//                               width: 20,
//                             ),
//                             Column(
//                               children: [
//                                 Text(
//                                     '${snapdata[index]['to_date'].toString().substring(0, 2)}' + 'th'),
//                                 Text(
//                                     '${Utils.formatMonth(snapdata[index]['to_date'].toString())}'),
//                                 Text(
//                                     '(${Utils.formatDay(snapdata[index]['to_date']).toString().substring(0, 3)})'),
//                               ],
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.only(left: 20.0),
//                     child: Text(
//                       '${snapdata[index]['type']}',
//                       style: text50010black,
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         left: 10.0,
//                         right: 10,
//                         top: 10,
//                         bottom: 10),
//                     child: Container(
//                       width:
//                           MediaQuery.of(context).size.width,
//                       height: 100,
//                       decoration: BoxDecoration(
//                           color: AppColors.whiteColor,
//                           borderRadius:
//                               BorderRadius.circular(6)),
//                       child: Padding(
//                         padding: EdgeInsets.all(10.0),
//                         child: Text(
//                             '${snapdata[index]['remark']}'),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 50,
//                   )
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 20,
//               left: 20,
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     '${snapdata[index]['repDetails'][0]['name'].toString().toUpperCase()}',
//                     style: text50014black,
//                   ),
//                   Text(
//                     '${snapdata[index]['repDetails'][0]['designation'].toString().toUpperCase()}',
//                     style: text50010tcolor2,
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 20,
//               right: 20,
//               child: Column(
//                 crossAxisAlignment:
//                     CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     Utils.formatDate(
//                         '${snapdata[index]['created_date'].toString()}'),
//                     style: text50014black,
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Text(
//                     '${snapdata[index]['status'].toString().toUpperCase()}',
//                     style: text40016,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     })

// static Widget approved(String ID) {
//   return FutureBuilder(
//       future:
//       builder: (context,snapshot) {
//         if(snapshot.connectionState == ConnectionState.waiting){
//           return Center(child: CircularProgressIndicator(),);
//         }else if(snapshot.hasError){
//           return Center(child: Text('Some error happened !'),);
//         } else if(snapshot.hasData){
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(25.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                               border: Border.all(width: 0.5,color: AppColors.borderColor),
//                               borderRadius: BorderRadius.circular(6)
//                           ),
//                           child: TextFormField(
//                             decoration: const InputDecoration(
//                               hintText: 'Search',
//                               prefixIcon: Icon(Icons.search),
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10,),
//                       Container(
//                         decoration: BoxDecoration(
//                             color: AppColors.primaryColor,
//                             borderRadius: BorderRadius.circular(6)
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: SizedBox(
//                               height: 25,width: 25,
//                               child: Image.asset('assets/icons/settings.png')),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10,),
//                   ListView.builder(
//                       itemCount: snapshot.data!['data'].where((item)=>item['status'] == 'Approved').toList().length,
//                       shrinkWrap: true,
//                       itemBuilder: (context,index) {
//                         var snapdata = snapshot.data!['data'].where((item)=>item['status'] == 'Approved').toList();
//                         int dayDiffrence = Utils.calculateDaysDifference(
//                             snapdata[index]['from_date'],
//                             snapdata[index]['to_date']
//                         );
//                         return  Padding(
//                           padding: const EdgeInsets.only(top: 10.0,bottom: 10.0),
//                           child: Stack(
//                             children: [
//                               Container(
//                                 decoration:  BoxDecoration(
//                                     color: AppColors.textfiedlColor,
//                                     borderRadius: BorderRadius.circular(6)
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     const SizedBox(height: 50,),
//                                     Column(
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.only(top: 30.0,left: 10.0,right: 10.0,bottom: 20.0),
//                                           child: Row(
//                                             children: [
//                                               Column(
//                                                 children: [
//                                                   Text('${snapdata[index]['from_date'].toString().substring(0,2)}'+'th'),
//                                                   Text('${Utils.formatMonth(snapdata[index]['from_date'].toString())}'),
//                                                   Text('(${Utils.formatDay(snapdata[index]['from_date']).toString().substring(0,3)})'),
//                                                 ],
//                                               ),
//                                               const SizedBox(width: 20,),
//                                               Container(
//                                                 height: 20,
//                                                 width: 20,
//                                                 decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(50),
//                                                     border: Border.all(width: 1,color: AppColors.blackColor)
//                                                 ),),
//                                               const Expanded(child: Divider(indent:10,color: AppColors.primaryColor,)),
//                                               Padding(
//                                                 padding: EdgeInsets.only(left: 10.0,right: 10.0),
//                                                 child: Column(
//                                                   children: [
//                                                     Text('${dayDiffrence} day',style:text50014black,),
//                                                     // Text('10 Days available',style:text50010,),
//                                                   ],
//                                                 ),
//                                               ),
//                                               const Expanded(child: Divider(endIndent:10,color: AppColors.primaryColor,)),
//                                               Container(
//                                                 height: 20,
//                                                 width: 20,
//                                                 decoration: BoxDecoration(
//                                                     color: AppColors.blackColor,
//                                                     borderRadius: BorderRadius.circular(50),
//                                                     border: Border.all(width: 5,color: Colors.grey)
//                                                 ),),
//                                               const SizedBox(width: 20,),
//                                               Column(
//                                                 children: [
//                                                   Text('${snapdata[index]['to_date'].toString().substring(0,2)}'+'th'),
//                                                   Text('${Utils.formatMonth(snapdata[index]['to_date'].toString())}'),
//                                                   Text('(${Utils.formatDay(snapdata[index]['to_date']).toString().substring(0,3)})'),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                     const SizedBox(height: 10,),
//                                     Padding(
//                                       padding: EdgeInsets.only(left: 20.0),
//                                       child: Text('${snapdata[index]['type']}',style: text50010black,),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10,bottom: 10),
//                                       child: Container(
//                                         width: MediaQuery.of(context).size.width,
//                                         height: 100,
//                                         decoration: BoxDecoration(
//                                             color: AppColors.whiteColor,
//                                             borderRadius: BorderRadius.circular(6)
//                                         ),
//                                         child: Padding(
//                                           padding: EdgeInsets.all(10.0),
//                                           child: Text('${snapdata[index]['remark']}'),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 50,)
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 20,
//                                 left: 20,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('${snapdata[index]['repDetails'][0]['name'].toString().toUpperCase()}',style: text50014black,),
//                                     Text('${snapdata[index]['repDetails'][0]['designation'].toString().toUpperCase()}',style: text50010tcolor2,),
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 20,
//                                 right: 20,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(Utils.formatDate('${snapdata[index]['created_date'].toString()}'),style: text50014black,),
//                                     SizedBox(height: 10,),
//                                     Text('${snapdata[index]['status'].toString().toUpperCase()}',style: text40016,),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                   )
//                 ],
//               ),
//             ),
//           );
//         }else
//           return Center(child: Text('Some error happened ! , please restart your application'),);
//       }
//   );
// }
//
// static Widget rejected(String ID) {
//   return FutureBuilder(
//       future: getleaves(ID),
//       builder: (context,snapshot) {
//         if(snapshot.connectionState == ConnectionState.waiting){
//           return Center(child: CircularProgressIndicator(),);
//         }else if(snapshot.hasError){
//           return Center(child: Text('Some error happened !'),);
//         }else if(snapshot.hasData){
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(25.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                               border: Border.all(width: 0.5,color: AppColors.borderColor),
//                               borderRadius: BorderRadius.circular(6)
//                           ),
//                           child: TextFormField(
//                             decoration: const InputDecoration(
//                               hintText: 'Search',
//                               prefixIcon: Icon(Icons.search),
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10,),
//                       Container(
//                         decoration: BoxDecoration(
//                             color: AppColors.primaryColor,
//                             borderRadius: BorderRadius.circular(6)
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: SizedBox(
//                               height: 25,width: 25,
//                               child: Image.asset('assets/icons/settings.png')),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10,),
//                   ListView.builder(
//                       itemCount: snapshot.data!['data'].where((item)=>item['status'] == 'Rejected').toList().length,
//                       shrinkWrap: true,
//                       itemBuilder: (context,index) {
//                         var snapdata = snapshot.data!['data'].where((item)=>item['status'] == 'Rejected').toList();
//                         int dayDiffrence = Utils.calculateDaysDifference(
//                             snapdata[index]['from_date'],
//                             snapdata[index]['to_date']
//                         );
//                         return  Padding(
//                           padding: const EdgeInsets.only(top: 10.0,bottom: 10.0),
//                           child: Stack(
//                             children: [
//                               Container(
//                                 decoration:  BoxDecoration(
//                                     color: AppColors.textfiedlColor,
//                                     borderRadius: BorderRadius.circular(6)
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     const SizedBox(height: 50,),
//                                     Column(
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.only(top: 30.0,left: 10.0,right: 10.0,bottom: 20.0),
//                                           child: Row(
//                                             children: [
//                                               Column(
//                                                 children: [
//                                                   Text('${snapdata[index]['from_date'].toString().substring(0,2)}'+'th'),
//                                                   Text('${Utils.formatMonth(snapdata[index]['from_date'].toString())}'),
//                                                   Text('(${Utils.formatDay(snapdata[index]['from_date']).toString().substring(0,3)})'),
//                                                 ],
//                                               ),
//                                               const SizedBox(width: 20,),
//                                               Container(
//                                                 height: 20,
//                                                 width: 20,
//                                                 decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(50),
//                                                     border: Border.all(width: 1,color: AppColors.blackColor)
//                                                 ),),
//                                               const Expanded(child: Divider(indent:10,color: AppColors.primaryColor,)),
//                                               Padding(
//                                                 padding: EdgeInsets.only(left: 10.0,right: 10.0),
//                                                 child: Column(
//                                                   children: [
//                                                     Text('${dayDiffrence} day',style:text50014black,),
//                                                     // Text('10 Days available',style:text50010,),
//                                                   ],
//                                                 ),
//                                               ),
//                                               const Expanded(child: Divider(endIndent:10,color: AppColors.primaryColor,)),
//                                               Container(
//                                                 height: 20,
//                                                 width: 20,
//                                                 decoration: BoxDecoration(
//                                                     color: AppColors.blackColor,
//                                                     borderRadius: BorderRadius.circular(50),
//                                                     border: Border.all(width: 5,color: Colors.grey)
//                                                 ),),
//                                               const SizedBox(width: 20,),
//                                               Column(
//                                                 children: [
//                                                   Text('${snapdata[index]['to_date'].toString().substring(0,2)}'+'th'),
//                                                   Text('${Utils.formatMonth(snapdata[index]['to_date'].toString())}'),
//                                                   Text('(${Utils.formatDay(snapdata[index]['to_date']).toString().substring(0,3)})'),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                     const SizedBox(height: 10,),
//                                     Padding(
//                                       padding: EdgeInsets.only(left: 20.0),
//                                       child: Text('${snapdata[index]['type']}',style: text50010black,),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10,bottom: 10),
//                                       child: Container(
//                                         width: MediaQuery.of(context).size.width,
//                                         height: 100,
//                                         decoration: BoxDecoration(
//                                             color: AppColors.whiteColor,
//                                             borderRadius: BorderRadius.circular(6)
//                                         ),
//                                         child: Padding(
//                                           padding: EdgeInsets.all(10.0),
//                                           child: Text('${snapdata[index]['remark']}'),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 50,)
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 20,
//                                 left: 20,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('${snapdata[index]['repDetails'][0]['name'].toString().toUpperCase()}',style: text50014black,),
//                                     Text('${snapdata[index]['repDetails'][0]['designation'].toString().toUpperCase()}',style: text50010tcolor2,),
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 20,
//                                 right: 20,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(Utils.formatDate('${snapdata[index]['created_date'].toString()}'),style: text50014black,),
//                                     SizedBox(height: 10,),
//                                     Text('${snapdata[index]['status'].toString().toUpperCase()}',style: text40016,),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                   )
//                 ],
//               ),
//             ),
//           );
//         }else
//           return Center(child: Text('Some error happened ! , please restart your application'),);
//       }
//   );
// }
//
// static Widget pending(String ID) {
//   return FutureBuilder(
//       future: getleaves(ID),
//       builder: (context,snapshot) {
//         if(snapshot.connectionState == ConnectionState.waiting){
//           return Center(child: CircularProgressIndicator(),);
//         }else if(snapshot.hasError){
//           return Center(child: Text('Some error happened !'),);
//         }else if(snapshot.hasData){
//           print('pending...${snapshot.data}');
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(25.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                               border: Border.all(width: 0.5,color: AppColors.borderColor),
//                               borderRadius: BorderRadius.circular(6)
//                           ),
//                           child: TextFormField(
//                             decoration: const InputDecoration(
//                               hintText: 'Search',
//                               prefixIcon: Icon(Icons.search),
//                               border: InputBorder.none,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 10,),
//                       Container(
//                         decoration: BoxDecoration(
//                             color: AppColors.primaryColor,
//                             borderRadius: BorderRadius.circular(6)
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.all(10.0),
//                           child: SizedBox(
//                               height: 25,width: 25,
//                               child: Image.asset('assets/icons/settings.png')),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10,),
//                   ListView.builder(
//                       itemCount: snapshot.data!['data'].where((item)=>item['status'] == 'Pending').toList().length,
//                       shrinkWrap: true,
//                       itemBuilder: (context,index) {
//                         var snapdata = snapshot.data!['data'].where((item)=>item['status'] == 'Pending').toList();
//                         int dayDiffrence = Utils.calculateDaysDifference(
//                             snapdata[index]['from_date'],
//                             snapdata[index]['to_date']
//                         );
//                         return  Padding(
//                           padding: const EdgeInsets.only(top: 10.0,bottom: 10.0),
//                           child: Stack(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                     color: AppColors.textfiedlColor,
//                                     borderRadius: BorderRadius.circular(6)
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     const SizedBox(height: 50,),
//                                     Column(
//                                       children: [
//                                         Padding(
//                                           padding: const EdgeInsets.only(top: 30.0,left: 10.0,right: 10.0,bottom: 20.0),
//                                           child: Row(
//                                             children: [
//                                               Column(
//                                                 children: [
//                                                   Text('${snapdata[index]['from_date'].toString().substring(0,2)}'+'th'),
//                                                   Text('${Utils.formatMonth(snapdata[index]['from_date'].toString())}'),
//                                                   Text('(${Utils.formatDay(snapdata[index]['from_date']).toString().substring(0,3)})'),
//                                                 ],
//                                               ),
//                                               const SizedBox(width: 20,),
//                                               Container(
//                                                 height: 20,
//                                                 width: 20,
//                                                 decoration: BoxDecoration(
//                                                     borderRadius: BorderRadius.circular(50),
//                                                     border: Border.all(width: 1,color: AppColors.blackColor)
//                                                 ),),
//                                               const Expanded(child: Divider(indent:10,color: AppColors.primaryColor,)),
//                                               Padding(
//                                                 padding: EdgeInsets.only(left: 10.0,right: 10.0),
//                                                 child: Column(
//                                                   children: [
//                                                     Text('${dayDiffrence} day',style:text50014black,),
//                                                     // Text('10 Days available',style:text50010,),
//                                                   ],
//                                                 ),
//                                               ),
//                                               const Expanded(child: Divider(endIndent:10,color: AppColors.primaryColor,)),
//                                               Container(
//                                                 height: 20,
//                                                 width: 20,
//                                                 decoration: BoxDecoration(
//                                                     color: AppColors.blackColor,
//                                                     borderRadius: BorderRadius.circular(50),
//                                                     border: Border.all(width: 5,color: Colors.grey)
//                                                 ),),
//                                               const SizedBox(width: 20,),
//                                               Column(
//                                                 children: [
//                                                   Text('${snapdata[index]['to_date'].toString().substring(0,2)}'+'th'),
//                                                   Text('${Utils.formatMonth(snapdata[index]['to_date'].toString())}'),
//                                                   Text('(${Utils.formatDay(snapdata[index]['to_date']).toString().substring(0,3)})'),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                     const SizedBox(height: 10,),
//                                     Padding(
//                                       padding: EdgeInsets.only(left: 20.0),
//                                       child: Text('${snapdata[index]['type']}',style: text50010black,),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10,bottom: 10),
//                                       child: Container(
//                                         width: MediaQuery.of(context).size.width,
//                                         height: 100,
//                                         decoration: BoxDecoration(
//                                             color: AppColors.whiteColor,
//                                             borderRadius: BorderRadius.circular(6)
//                                         ),
//                                         child: Padding(
//                                           padding: EdgeInsets.all(10.0),
//                                           child: Text('${snapdata[index]['remark']}'),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 50,)
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 20,
//                                 left: 20,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text('${snapdata[index]['repDetails'][0]['name'].toString().toUpperCase()}',style: text50014black,),
//                                     Text('${snapdata[index]['repDetails'][0]['designation'].toString().toUpperCase()}',style: text50010tcolor2,),
//                                   ],
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 20,
//                                 right: 20,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(Utils.formatDate('${snapdata[index]['created_date'].toString()}'),style: text50014black,),
//                                     SizedBox(height: 10,),
//                                     Text('${snapdata[index]['status'].toString().toUpperCase()}',style: text40016,),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                   )
//                 ],
//               ),
//             ),
//           );
//         }else
//           return Center(child: Text('Some error happened ! , please restart your application'),);
//       }
//   );
// }
