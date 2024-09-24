import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/BottomNavManager.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/Settings.dart';
import 'package:rx_route_new/New%20Rx%20Project/Rep/Bottom%20navigation%20rep/Leave%20and%20expense/Leave%20and%20expense.dart';
import 'package:rx_route_new/New%20Rx%20Project/Widgets/widgets.dart';
import 'package:rx_route_new/View/homeView/search/home_search_rep.dart';
import 'package:rx_route_new/View/profile/settings/settings.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:rx_route_new/widgets/HomeTileWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Util/Utils.dart';
import '../../../View/events/events.dart';
import '../../../constants/styles.dart';
import '../../resetPassword.dart';

class HomepageManager extends StatefulWidget {
  const HomepageManager({Key? key}) : super(key: key);

  @override
  State<HomepageManager> createState() => _HomepageManagerState();
}

class _HomepageManagerState extends State<HomepageManager> {
  List<dynamic> todayAnniversaries = [];
  List<dynamic> upcomingBirthdays = [];
  bool isLoading = false;
  String _locationName = "Fetching location...";
  bool _locationEnabled = false;

  int totalCalls = 0;
  int visitedCalls = 0;
  int missedCalls = 0;
  String visitPercentage = '0.0';

  String currentDate = DateFormat('d-MM-yyyy hh:mm:aa').format(DateTime.now()); // Get current date

  TextEditingController _searchText = TextEditingController();


  // Method to check permission and fetch current location
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationName = "Location services are disabled.";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationName = "Location permissions are denied";
          print('sss:$_locationName');
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationName = "Location permissions are permanently denied";
      });
      return;
    }

    _getCurrentLocation();
  }

  // Method to get current location and reverse geocode it
  Future<void> _getCurrentLocation() async {
    print('current loc called...');
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('position: $position');

      // Reverse geocoding using OpenStreetMap Nominatim API
      String url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18&addressdetails=1';

      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String locationName = data['address']['city'] ??
            data['address']['town'] ??
            data['address']['village'] ??
            "Unknown location";

        print('current location: $locationName');
        if (mounted) {
          setState(() {
            _locationName = locationName;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _locationName = "Failed to fetch location";
          });
        }
      }
    } on SocketException catch (_) {
      // Handle network issues such as no internet
      if (mounted) {
        setState(() {
          _locationName = "Unknown location (network issue)";
        });
      }
    } catch (e) {
      // Handle other exceptions
      if (mounted) {
        setState(() {
          _locationName = "Error occurred: $e";
        });
      }
    }
  }

  Future<void> _checkPasswordStatus() async {
    print('check called...');
    final String apiUrl = 'http://52.66.145.37:3004/user/checkPassword';
    print('checking :${Utils.userId}');
    final Map<String, dynamic> body = {
      "userId": int.parse('${Utils.userId.toString()}'), // Replace this with the actual userId if needed
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      print('bdy:${jsonEncode(body)}');
      print('sss:${response.statusCode}');
      if (response.statusCode == 200) {

        final data = json.decode(response.body);
        if (data['success']) {
          if (data['message'] == 'Password already modified') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigationMngr()),
            );
          } else if (data['message'] == 'Modifie the password') {
            setState(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ResetPasswordPage(userId:int.parse(Utils.userId.toString()) ), // Pass userId here
                ),
              );
            });
          }
        } else {
          _showErrorDialog('Failed to check password status');
        }
      } else {
        _showErrorDialog('Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Exception: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text('${message}'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCallData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    final response = await http.post(
      Uri.parse(AppUrl.getallVisitData),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': uniqueID}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        totalCalls = data['data'];
        visitedCalls = data['visited'];
        missedCalls = data['missedVisit'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  void initState() {
    // _checkPasswordStatus();
    super.initState();
    _checkLocationPermission();
    getEvents();
    _fetchCallData();
  }

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
        // myeventstoday.clear();
        // myeventsupcoming.clear();
        // myeventstoday.addAll(responseData['todayEvents']);
        // myeventsupcoming.addAll(responseData['UpcomingEvents'][0]['AnniversaryNotification']);
        // allevents.clear();
        // allevents.addAll({'upcoming':myeventsupcoming,"todays":myeventstoday});
        // print('all events:$allevents');
        // print('myeventstoday:$myeventstoday');
        // print('myeventsupcoming:$myeventsupcoming');
        // return json.decode(response.body);
        return responseData;
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: isLoading
                        ? Center(child: CircularProgressIndicator()) // Show loading indicator
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap:(){
                                    print('pressed');
                                    print('locatoin name:$_locationName');
                                    _checkLocationPermission();
                                    _getCurrentLocation();
                                  },
                                  child: Icon(
                                    CupertinoIcons.location_solid,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Wrap(

                                  children: [
                                    Text(
                                      overflow: TextOverflow.ellipsis,
                                      '${_locationName}',
                                      style: text50012black,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: CircleAvatar(child: Icon(Icons.settings,color: AppColors.primaryColor,size: 25,)),
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),));
                                      },
                                    ),
                                    CircleAvatar(
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.notifications,
                                          color: AppColors.primaryColor,
                                          size: 25,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.5, color: AppColors.borderColor),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextFormField(
                                  controller: _searchText,
                                  decoration: const InputDecoration(
                                    hintText: 'Search',
                                    prefixIcon: Icon(Icons.search),
                                    border: InputBorder.none,
                                  ),
                                  onFieldSubmitted: (value){
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomesearchRep(searachString: _searchText.text,),));
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
                        SizedBox(height: 10),
                        Text('Calls', style: text40016black),
                        SizedBox(height: 10),
                        SizedBox(
                          // height: 100,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                CallTileWidget(icon: Icons.call, title: 'Assigned Calls', totalCalls: totalCalls, missedcalls: missedCalls, visitedCalls: visitedCalls, updateDate: currentDate,percentage: visitPercentage,),
                                SizedBox(width: 10,),
                                CallTileWidget(icon: Icons.phone_callback_sharp, title: 'Missed Calls', totalCalls: missedCalls, missedcalls: missedCalls, visitedCalls: visitedCalls, updateDate: currentDate,percentage: visitPercentage,),

                                // Hometilewidget(),
                                // SizedBox(width: 10,),
                                // Hometilewidget(),
                                // SizedBox(width: 10,),
                                // Hometilewidget()
                                // Container(
                                //   width:MediaQuery.of(context).size.width/1.9,
                                //   decoration: BoxDecoration(
                                //     color: AppColors.primaryColor,
                                //     borderRadius: BorderRadius.circular(20),
                                //   ),
                                //   padding: EdgeInsets.all(8.0),
                                //   height: MediaQuery.of(context).size.height / 6,
                                //   child: Row(
                                //     children: [
                                //       CircleAvatar(
                                //         radius: 20,
                                //         child: IconButton(
                                //           onPressed: () {},
                                //           icon: Icon(Icons.call, color: AppColors.primaryColor),
                                //         ),
                                //       ),
                                //       const SizedBox(width: 20),
                                //       Column(
                                //         mainAxisAlignment: MainAxisAlignment.center,
                                //         crossAxisAlignment: CrossAxisAlignment.start,
                                //         children: [
                                //           Text(
                                //             'Calls',
                                //             style: text60012,
                                //           ),
                                //           Text('Missed: 5', style: text40012),
                                //           Text('14-08-2024', style: text40012),
                                //         ],
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // SizedBox(width: 10,),
                                // Container(
                                //   width:MediaQuery.of(context).size.width/1.9,
                                //   decoration: BoxDecoration(
                                //     color: AppColors.primaryColor,
                                //     borderRadius: BorderRadius.circular(20),
                                //   ),
                                //   padding: EdgeInsets.all(8.0),
                                //   height: MediaQuery.of(context).size.height / 6,
                                //   child: Row(
                                //     children: [
                                //       CircleAvatar(
                                //         radius: 20,
                                //         child: IconButton(
                                //           onPressed: () {},
                                //           icon: Icon(Icons.call, color: AppColors.primaryColor),
                                //         ),
                                //       ),
                                //       const SizedBox(width: 20),
                                //       Column(
                                //         mainAxisAlignment: MainAxisAlignment.center,
                                //         crossAxisAlignment: CrossAxisAlignment.start,
                                //         children: [
                                //           Text(
                                //             'Total Calls',
                                //             style: text60012,
                                //           ),
                                //           Text('1800', style: text40012),
                                //           Text('14-08-2024', style: text40012),
                                //         ],
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Events',style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),),
                            InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => SeeAllPage()));
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
                        SizedBox(height: 10),
            
                        // Events Section
                        // Container(
                        //   decoration: BoxDecoration(
                        //     color: AppColors.primaryColor,
                        //     borderRadius: BorderRadius.circular(6),
                        //   ),
                        //   padding: const EdgeInsets.all(10.0),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       if (todayAnniversaries.isEmpty && upcomingBirthdays.isEmpty)
                        //         Center(
                        //           child: Text(
                        //             'There are no events',
                        //             style: TextStyle(
                        //               fontWeight: FontWeight.w500,
                        //               color: AppColors.whiteColor,
                        //               fontSize: 14,
                        //             ),
                        //           ),
                        //         )
                        //       else ...[
                        //         // Display Upcoming Birthdays
                        //         if (upcomingBirthdays.isNotEmpty) ...[
                        //           Text(
                        //             'Upcoming Birthdays',
                        //             style: TextStyle(
                        //               fontWeight: FontWeight.w500,
                        //               color: AppColors.whiteColor,
                        //               fontSize: 12,
                        //             ),
                        //           ),
                        //           SizedBox(height: 10),
                        //           for (var birthday in upcomingBirthdays) ...[
                        //             Row(
                        //               children: [
                        //                 CircleAvatar(
                        //                   radius: 25,
                        //                   backgroundColor: Colors.white,
                        //                   child: Icon(
                        //                     Icons.cake,
                        //                     color: AppColors.primaryColor,
                        //                   ),
                        //                 ),
                        //                 SizedBox(width: 10),
                        //                 Expanded(
                        //                   child: Column(
                        //                     crossAxisAlignment: CrossAxisAlignment.start,
                        //                     children: [
                        //                       Text(
                        //                         '${birthday['firstName']} ${birthday['lastName']}',
                        //                         style: TextStyle(
                        //                           fontWeight: FontWeight.w500,
                        //                           color: AppColors.whiteColor,
                        //                           fontSize: 12,
                        //                         ),
                        //                       ),
                        //                       Text(
                        //                         'DOB: ${birthday['date_of_birth']}',
                        //                         style: TextStyle(
                        //                           color: AppColors.whiteColor,
                        //                           fontSize: 12,
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //             SizedBox(height: 10),
                        //           ],
                        //         ],
                        //         SizedBox(height: 20),
                        //         Container(
                        //           decoration: BoxDecoration(
                        //             color: AppColors.primaryColor2,
                        //             borderRadius: BorderRadius.circular(6),
                        //           ),
                        //           child: Padding(
                        //             padding: const EdgeInsets.all(8.0),
                        //             child: Row(
                        //               mainAxisAlignment: MainAxisAlignment.center,
                        //               children: [
                        //                 Text(
                        //                   'Notify me',
                        //                   style: TextStyle(
                        //                     fontWeight: FontWeight.w500,
                        //                     color: AppColors.whiteColor,
                        //                     fontSize: 12,
                        //                   ),
                        //                 ),
                        //                 SizedBox(width: 10),
                        //                 Icon(Icons.notifications_active, color: AppColors.whiteColor),
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     ],
                        //   ),
                        // ),

                        FutureBuilder(
                          future: getEvents(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Some error occurred!'));
                            } else if (snapshot.hasData) {
                              print('event data:${snapshot.data}');
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height:100,
                                        width:250,
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryColor2,
                                            borderRadius: BorderRadius.circular(9)
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Text('${snapshot.data['todays']}'),
                                            Text('Todays Birthdays : ${snapshot.data['todayEvents'][0]['todayBirthday'].length}',style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.bold),),
                                            Text('Todays Anniversarys : ${snapshot.data['todayEvents'][0]['todayAnniversary'].length}',style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        height:100,
                                        width:250,
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryColor2,
                                            borderRadius: BorderRadius.circular(9)
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Text('${snapshot.data['todays']}'),
                                            Text('Upcoming Birthdays : ${snapshot.data['UpcomingEvents'][0]['BirthdayNotification'].length}',style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.bold),),
                                            Text('Upcoming Anniversarys : ${snapshot.data['UpcomingEvents'][0]['AnniversaryNotification'].length}',style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.bold),),
                                          ],
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              );

                            }
                            return Center(child: Text('Some error occurred, Please restart your application!'));
                          },
                        ),
            
            
                        // Positioned(
                        //   left: MediaQuery.of(context).size.width/3,
                        //   bottom: MediaQuery.of(context).size.height/7.9,
                        //   child:
                        SizedBox(height: 10,),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // ElevatedButton(style: ElevatedButton.styleFrom(
                            //     backgroundColor: AppColors.primaryColor),
                            //   onPressed: () {
                            //     Navigator.push(context, MaterialPageRoute(builder: (context) => MyLeaveandexpense(),));
                            //   }, child: Text('Leave & Expense',style: text50012,),),
            
                          ],
                        ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}