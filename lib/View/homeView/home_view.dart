
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rx_route_new/View/homeView/widgets/CustomDrawer.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../Util/Utils.dart';
import '../../app_colors.dart';
import '../../constants/styles.dart';
import '../../res/app_url.dart';
import '../Add TP/add_tp.dart';
import '../Add TP/tp_list.dart';
import '../events/upcoming_events.dart';
import '../events/widgets/eventCardWidget.dart';
import '../notification/notification.dart';
import 'Doctor/add_doctor.dart';
import 'Doctor/doctors_list_manager.dart';
import 'Employee/add_rep.dart';
import 'Employee/emp_list.dart';
import 'Expense/exp_manager/exp_approve_manager.dart';
import 'Expense/exp_manager/expense_approvals_manager.dart';
import 'Expense/expense_approvals.dart';
import 'Expense/expense_request.dart';
import 'package:http/http.dart' as http;

import 'Leave/leav_manager/manger_approve_leaves.dart';
import 'Leave/leaveApprovals.dart';
import 'chemist/chemistList.dart';
import 'home_view_rep.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PermissionStatus _exactAlarmPermissionStatus = PermissionStatus.granted;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    _checkExactAlarmPermission();
  }

  void _checkExactAlarmPermission() async {
    final currentStatus = await Permission.scheduleExactAlarm.status;
    setState(() {
      _exactAlarmPermissionStatus = currentStatus;
    });
  }
  Future<dynamic> totaldoctorscount() async {
    String url = AppUrl.totaldoctorscount;

    try {
      final response = await http.get(
        Uri.parse(url),
      );
      // print(jsonEncode(data));
      print('${response.statusCode}');
      print('${response.body}');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<dynamic> totalrepcount() async {
    String url = AppUrl.totalrepcount;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Parsed Response Data: $responseData'); // Added print statement
        return responseData;
      } else {
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Exception: $e'); // Added print statement for exceptions
      throw Exception('Failed to load data: $e');
    }
  }

  List<dynamic> myeventstoday = [];
  List<dynamic> myeventsupcoming = [];
  Map<String,dynamic> allevents = {};

  Future<dynamic> getEvents() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    print('get events called...');
    final url = Uri.parse(AppUrl.getEvents);
    var data = {
      "requesterUniqueId":uniqueID
    };
    try {
      final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        var responseData = jsonDecode(response.body);
        myeventstoday.clear();
        myeventsupcoming.clear();
        myeventstoday.addAll(responseData['todayEvents']);
        myeventsupcoming.addAll(responseData['UpcomingEvents'][0]['AnniversaryNotification']);
        allevents.clear();
        allevents.addAll({'upcoming':myeventsupcoming,"todays":myeventstoday});
        print('all events:$allevents');
        print('myeventstoday:$myeventstoday');
        print('myeventsupcoming:$myeventsupcoming');
        // return json.decode(response.body);
        return allevents;
      } else {
        // If the server returns an error, throw an exception
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        // Show a confirmation dialog
        bool exit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm Exit'),
            content: Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        );

        // Return true to allow back navigation, false to prevent it
        return exit ?? false; // default to false if exit is null
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        key: _scaffoldKey,
        drawer:  CustomDrawer(),
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          leading:InkWell(
            onTap: (){
              _scaffoldKey.currentState?.openDrawer();
            },
              child: const Icon(Icons.menu)),
          actions: [
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Notifications(),));
              },
                child: const Icon(Icons.notifications_active,color: AppColors.primaryColor,size: 35,)),
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
            ),
          ],
          title: const Text('RXRoute',style: TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddDoctor(),));
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add,color: AppColors.whiteColor,),
                          Text('Add doctor',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: AppColors.whiteColor),)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10,),
              Expanded(
                child: InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRep(),));
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6)
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add,color: AppColors.whiteColor,),
                          Text('Add Employee',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,color: AppColors.whiteColor),)
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child:Padding(
                padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 0.5,color: AppColors.borderColor),
                              borderRadius: BorderRadius.circular(6)
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
                      const SizedBox(width: 10,),
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(6)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: SizedBox(
                              height: 25,width: 25,
                              child: Image.asset('assets/icons/settings.png')),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 155,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Container(
                                    height: 120,
                                    width: 224,
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: FutureBuilder(
                                        future: totaldoctorscount(),
                                        builder: (context,snapshot) {
                                          if(snapshot.connectionState == ConnectionState.waiting){
                                            return Center(child: CircularProgressIndicator(),);
                                          }else if(snapshot.hasError){
                                            return Center(child: Text('Some error occured !'),);
                                          }else if(snapshot.hasData){
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Total Doctor',style: TextStyle(color: AppColors.whiteColor,fontSize:14,fontWeight: FontWeight.w600),),
                                                Text('${snapshot.data['get_count']}',style: TextStyle(color: AppColors.whiteColor,fontSize: 28,fontWeight: FontWeight.w600),),
                                                Text('Updated : ${snapshot.data['lastDrAddedDate']}',style: TextStyle(color: AppColors.whiteColor,fontSize: 12,fontWeight: FontWeight.w400),),
                                              ],
                                            );
                                          }
                                          return Text('Some error occured , Please restart your application !');
                                        }
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: Container(
                                    height: 120,
                                    width: 224,
                                    decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: FutureBuilder(
                                        future: totalrepcount(),
                                        builder: (context,snapshot) {
                                          if(snapshot.connectionState == ConnectionState.waiting){
                                            return Center(child: CircularProgressIndicator(),);
                                          }else if(snapshot.hasError){
                                            return Center(child: Text('Some error occured !'),);
                                          }else if(snapshot.hasData){
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Total Employee',style: TextStyle(color: AppColors.whiteColor,fontSize:14,fontWeight: FontWeight.w600),),
                                                Text('${snapshot.data['get_count']}',style: TextStyle(color: AppColors.whiteColor,fontSize: 28,fontWeight: FontWeight.w600),),
                                                Text('Updated : ${snapshot.data['lastRepAddedDate']}',style: TextStyle(color: AppColors.whiteColor,fontSize: 12,fontWeight: FontWeight.w400),),
                                              ],
                                            );
                                          }
                                          return Text('Some error occred , Please restart your application !');
                                        }
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        )
                      ),
                    ),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    crossAxisCount: 4,
                    children: <Widget>[
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorsListManager(),));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/icons/doctor_list.png',height: 35, width: 35,),
                            const Column(
                              children: [
                                Text('Doctors',style: text60014black,),
                                Text('List',style: text60014black,),
                              ],
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EmpList(),));
                        },
                        child: Column(
                          children: [
                            Image.asset('assets/icons/emp_list.png',height: 35, width:35,),
                            const Column(
                              children: [
                                Text('Employee',style: text60014black),
                                Text('List',style:text60014black),
                              ],
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveApprovals(),));
                        },
                        child: SizedBox(
                          child: Column(
                            children: [
                              Image.asset('assets/icons/lvapprove.png',height: 35, width: 35,),
                              const Column(
                                children: [
                                  Text('My',style: text60014black),
                                  Text('Leaves',style:text60014black,),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      // InkWell(
                      //   onTap: (){
                      //     Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveApplyPage(),));
                      //   },
                      //   child: SizedBox(
                      //     child: Column(
                      //       children: [
                      //         Expanded(child: Image.asset('assets/icons/lvrequest.png')),
                      //         const Column(
                      //           children: [
                      //             Text('Leave',style: TextStyle(
                      //                 fontWeight: FontWeight.w600
                      //             ),),
                      //             Text('Request',style: TextStyle(
                      //                 fontWeight: FontWeight.w600
                      //             ),),
                      //           ],
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // InkWell(
                      //   onTap: (){
                      //     Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseRequestPage(),));
                      //   },
                      //   child: SizedBox(
                      //     child: Column(
                      //       children: [
                      //         Expanded(child: Image.asset('assets/icons/tp.png')),
                      //         const Column(
                      //           children: [
                      //             Text('Expense',style: TextStyle(
                      //                 fontWeight: FontWeight.w600
                      //             ),),
                      //             Text('Request',style: TextStyle(
                      //                 fontWeight: FontWeight.w600
                      //             ),),
                      //
                      //           ],
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseApprovalsManger(),));
                        },
                        child: SizedBox(
                          child: Column(
                            children: [
                              Image.asset('assets/icons/expense.png',height:35, width:35,),
                              const Column(
                                children: [
                                  Text('My',style: text60014black),
                                  Text('Expenses',style: text60014black),
      
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
      
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ManagerApproveLeaves(),));
                        },
                        child: SizedBox(
                          child: Column(
                            children: [
                              Image.asset('assets/icons/expapprove.png',height: 35, width:35,),
                              const Column(
                                children: [
                                  Text('Approve',style: text60014black),
                                  Text('Leaves',style: text60014black),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
      
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseApprovalsManager(),));
                        },
                        child: SizedBox(
                          child: Column(
                            children: [
                              Image.asset('assets/icons/expapprove.png',height: 35, width: 35,),
                              const Column(
                                children: [
                                  Text('Approve',style: text60014black),
                                  Text('Expenses',style: text60014black,),
      
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
      
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const Chemistlist(),));
                        },
                        child: SizedBox(
                          child: Column(
                            children: [
                              Image.asset('assets/icons/chemist_list.png', height: 35, width: 35,),
                              const Column(
                                children: [
                                  Text('Chemist',style: text60014black),
                                  Text('List',style: text60014black,),
      
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
      
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ListTP(),));
                        },
                        child: Column(
                          children: [
                            Expanded(child: Image.asset('assets/icons/tplist.png',height: 35,width: 35,)),
                            const Column(
                              children: [
                                Text('My',style:text60014black),
                                Text('TP',style: text60014black,),
                              ],
                            )
                          ],
                        ),
                      ),
      
                      // InkWell(
                      //   onTap: (){
                      //     Navigator.push(context, MaterialPageRoute(builder: (context) => AddTravelPlan(),));
                      //   },
                      //   child: SizedBox(
                      //     child: Column(
                      //       children: [
                      //         Expanded(child: Image.asset('assets/icons/tp.png')),
                      //         const Column(
                      //           children: [
                      //             Text('Travel',style: TextStyle(
                      //                 fontWeight: FontWeight.w600
                      //             ),),
                      //             Text('Plan',style: TextStyle(
                      //                 fontWeight: FontWeight.w600
                      //             ),),
                      //           ],
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
      
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Todays Events',style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),),
                      InkWell(
                        onTap: (){
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => Events(eventType: 'Todays Events'),));
                        },
                        child: const Text('See all',style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            decoration: TextDecoration.underline),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  FutureBuilder(
                      future: getEvents(),
                      builder: (context,snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator(),);
                        }else if(snapshot.hasError){
                          return Center(child: Text('Some error occured !'),);
                        }else if(snapshot.hasData){
                          if(snapshot.data['todays'][0]['todayBirthday'].length == 0){
                            return Text('No Birthdays Today');
                          }else{
                            var eventdata = snapshot.data['todays'][0]['todayBirthday'][0];
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(6)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 25.0,top: 10,bottom: 10,right: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Hey !',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12),),
                                        Text('Its ${eventdata['doc_name']} Birthday !',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12),),
                                        const Text('Wish an all the Best',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                                        const SizedBox(height: 30,),
                                        Row(
                                          children: [
                                            CircleAvatar(radius: 25,child: Text('${eventdata['doc_name'][0].toString().toUpperCase()}'),),
                                            SizedBox(width: 10,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${eventdata['doc_name']}',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                                                Text('${eventdata['doc_qualification']}',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 9)),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 10,),
                                        SizedBox(
                                          width: 130,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: AppColors.primaryColor2,
                                                borderRadius: BorderRadius.circular(6)
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('Notify me',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                                                  SizedBox(width: 10,),
                                                  Icon(Icons.notifications_active,color: AppColors.whiteColor,),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    height: 70,
                                    width: 100,
                                    decoration: const BoxDecoration(
                                        color:AppColors.primaryColor2,
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(21),topRight: Radius.circular(6))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Image.asset('assets/icons/cake.png'),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }
                          // return Text('${snapshot.data['todays'][0]}');
                          // if(snapshot.data['todays'][0]['todayBirthday'].length ==0 || snapshot.data['upcoming'][0]['UpcomingEvents'].length == 0){
                          //   return Text('No Events Today');
                          // }else{
                          //   var eventdata = snapshot.data['todays'][0];
                          //   // return Stack(
                          //   //   children: [
                          //   //     // Text('${eventdata}'),
                          //   //     // Container(
                          //   //     //   decoration: BoxDecoration(
                          //   //     //       color: AppColors.primaryColor,
                          //   //     //       borderRadius: BorderRadius.circular(6)
                          //   //     //   ),
                          //   //     //   child: Padding(
                          //   //     //     padding: const EdgeInsets.only(left: 25.0,top: 10,bottom: 10,right: 10),
                          //   //     //     child: Column(
                          //   //     //       crossAxisAlignment: CrossAxisAlignment.start,
                          //   //     //       children: [
                          //   //     //         const Text('Hey !',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12),),
                          //   //     //         Text('Its ${eventdata['doc_name']} Birthday !',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12),),
                          //   //     //         const Text('Wish an all the Best',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                          //   //     //         const SizedBox(height: 30,),
                          //   //     //         Row(
                          //   //     //           children: [
                          //   //     //             CircleAvatar(radius: 25,child: Text('${eventdata['doc_name'][0].toString().toUpperCase()}'),),
                          //   //     //             SizedBox(width: 10,),
                          //   //     //             Column(
                          //   //     //               crossAxisAlignment: CrossAxisAlignment.start,
                          //   //     //               children: [
                          //   //     //                 Text('${eventdata['doc_name']}',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                          //   //     //                 Text('${eventdata['doc_qualification']}',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 9)),
                          //   //     //               ],
                          //   //     //             )
                          //   //     //           ],
                          //   //     //         ),
                          //   //     //         const SizedBox(height: 10,),
                          //   //     //         SizedBox(
                          //   //     //           width: 130,
                          //   //     //           child: Container(
                          //   //     //             decoration: BoxDecoration(
                          //   //     //                 color: AppColors.primaryColor2,
                          //   //     //                 borderRadius: BorderRadius.circular(6)
                          //   //     //             ),
                          //   //     //             child: const Padding(
                          //   //     //               padding: EdgeInsets.all(8.0),
                          //   //     //               child: Row(
                          //   //     //                 mainAxisAlignment: MainAxisAlignment.center,
                          //   //     //                 children: [
                          //   //     //                   Text('Notify me',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                          //   //     //                   SizedBox(width: 10,),
                          //   //     //                   Icon(Icons.notifications_active,color: AppColors.whiteColor,),
                          //   //     //                 ],
                          //   //     //               ),
                          //   //     //             ),
                          //   //     //           ),
                          //   //     //         )
                          //   //     //       ],
                          //   //     //     ),
                          //   //     //   ),
                          //   //     // ),
                          //   //     // Positioned(
                          //   //     //   right: 0,
                          //   //     //   top: 0,
                          //   //     //   child: Container(
                          //   //     //     height: 70,
                          //   //     //     width: 100,
                          //   //     //     decoration: const BoxDecoration(
                          //   //     //         color:AppColors.primaryColor2,
                          //   //     //         borderRadius: BorderRadius.only(bottomLeft: Radius.circular(21),topRight: Radius.circular(6))
                          //   //     //     ),
                          //   //     //     child: Padding(
                          //   //     //       padding: const EdgeInsets.all(15.0),
                          //   //     //       child: Image.asset('assets/icons/cake.png'),
                          //   //     //     ),
                          //   //     //   ),
                          //   //     // )
                          //   //   ],
                          //   // );
                          //   return Text('data');
                          // }
                        }
                        return Center(child: Text('Some error occured , Please restart your application !'),);
                      }
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Upcoming Events',style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => UpcomingEvents(eventType: 'Upcoming Events'),));
                        },
                        child: const Text('See all',style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            decoration: TextDecoration.underline),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  FutureBuilder(
                      future: getEvents(),
                      builder: (context,snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Center(child: CircularProgressIndicator(),);
                        }else if(snapshot.hasError){
                          return Center(child: Text('Some error occured!'),);
                        }else if(snapshot.hasData){
                          var eventdata = snapshot.data['upcoming'][0];
                          if(eventdata.isNotEmpty){
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(6)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 25.0,top: 10,bottom: 10,right: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Hey !',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12),),
                                        Text('Its ${eventdata['doc_name']} Birthday !',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12),),
                                        const Text('Wish an all the Best',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                                        const SizedBox(height: 30,),
                                        Row(
                                          children: [
                                            CircleAvatar(radius: 25,child: Text('${eventdata['doc_name'][0].toString().toUpperCase()}'),),
                                            SizedBox(width: 10,),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${eventdata['doc_name']}',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                                                Text('${eventdata['doc_qualification']}',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 9)),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 10,),
                                        SizedBox(
                                          width: 130,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: AppColors.primaryColor2,
                                                borderRadius: BorderRadius.circular(6)
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text('Notify me',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                                                  SizedBox(width: 10,),
                                                  Icon(Icons.notifications_active,color: AppColors.whiteColor,),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    height: 70,
                                    width: 100,
                                    decoration: const BoxDecoration(
                                        color:AppColors.primaryColor2,
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(21),topRight: Radius.circular(6))
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Image.asset('assets/icons/cake.png'),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }
                          return Text('No upcoming events');
                        }
                        return Text('Some error occured ,Please restart your application');
                      }
                  ),
                  const SizedBox(height: 70,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

