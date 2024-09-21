
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/New%20Rx%20Project/Manager/Settings.dart';
import 'package:rx_route_new/Util/Utils.dart';
import 'package:rx_route_new/View/homeView/search/home_search_rep.dart';
import 'package:rx_route_new/View/homeView/search/homesearch.dart';
import 'package:rx_route_new/View/profile/settings/settings.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/styles.dart';
import '../../View/events/events.dart';
import '../../View/events/upcoming_events.dart';
import '../../widgets/HomeTileWidget.dart';
import '../resetPassword.dart';
import 'Bottom navigation rep/Bottomnavigationrep.dart';

class RepHomepage extends StatefulWidget {
  const RepHomepage({Key? key}) : super(key: key);

  @override
  State<RepHomepage> createState() => _RepHomepageState();
}

class _RepHomepageState extends State<RepHomepage> {
  bool isLoading = true;

  List<dynamic> todayAnniversaries = [];
  List<dynamic> upcomingBirthdays = [];

  List<dynamic> myeventstoday = [];
  List<dynamic> myeventsupcoming = [];
  Map<String,dynamic> allevents = {};

  String _locationName = "Fetching location...";
  var locationdata;
  bool _locationEnabled = false;

  TextEditingController _searchText = TextEditingController();

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
              MaterialPageRoute(builder: (context) => BottomNavigationRep()),
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

  // Method to get current location and reverse geocode it
  Future<void> _getCurrentLocation() async {
    print('current loc called...');
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print('position:$position');

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
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationName = "Error occurred: $e";
        });
      }
    }
  }

  @override
  void initState() {
      // _checkPasswordStatus();
    super.initState();
    getEvents();
    _getCurrentLocation();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,

        actions: [
          IconButton(
            icon: CircleAvatar(child: Icon(Icons.settings,color: AppColors.primaryColor,)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),));
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: (){
                        _getCurrentLocation();
                      },
                      child: Icon(
                        CupertinoIcons.location_solid,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      '${_locationName}',
                      style: text50012black,
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
                        Hometilewidget(),
                        SizedBox(width: 10,),
                        Hometilewidget(),
                        SizedBox(width: 10,),
                        Hometilewidget()
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
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Events',style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),),
                    InkWell(
                      onTap: (){

                        // Navigator.push(context, MaterialPageRoute(builder: (context) => Events(eventType: 'Todays Events'),));
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SeeAllPage(),));
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
                // Container(
                //   decoration: BoxDecoration(
                //     color: AppColors.pastelColors[0],
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
        
                const SizedBox(height: 20,),
        
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     const Text('Upcoming Events',style: TextStyle(
                //       fontWeight: FontWeight.w700,
                //       fontSize: 14,
                //     ),),
                //     InkWell(
                //       onTap: (){
                //         Navigator.push(context, MaterialPageRoute(builder: (context) => UpcomingEvents(eventType: 'Upcoming Events'),));
                //       },
                //       child: const Text('See all',style: TextStyle(
                //           color: AppColors.primaryColor,
                //           fontWeight: FontWeight.w700,
                //           fontSize: 14,
                //           decoration: TextDecoration.underline),),
                //     ),
                //   ],
                // ),
                // const SizedBox(height: 10,),
                // FutureBuilder(
                //     future: getEvents(),
                //     builder: (context,snapshot) {
                //       if(snapshot.connectionState == ConnectionState.waiting){
                //         return Center(child: CircularProgressIndicator(),);
                //       }else if(snapshot.hasError){
                //         return Center(child: Text('Some error occured!'),);
                //       }else if(snapshot.hasData){
                //         var eventdata = snapshot.data['upcoming'][0];
                //         if(eventdata.isNotEmpty){
                //           return Stack(
                //             children: [
                //               Container(
                //                 decoration: BoxDecoration(
                //                     color: AppColors.primaryColor,
                //                     borderRadius: BorderRadius.circular(6)
                //                 ),
                //                 child: Padding(
                //                   padding: const EdgeInsets.only(left: 25.0,top: 10,bottom: 10,right: 10),
                //                   child: Column(
                //                     crossAxisAlignment: CrossAxisAlignment.start,
                //                     children: [
                //                       const Text('Hey !',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12),),
                //                       Text('Its ${eventdata['doc_name']} Birthday !',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12),),
                //                       const Text('Wish an all the Best',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                //                       const SizedBox(height: 30,),
                //                       Row(
                //                         children: [
                //                           CircleAvatar(radius: 25,child: Text('${eventdata['doc_name'][0].toString().toUpperCase()}'),),
                //                           SizedBox(width: 10,),
                //                           Column(
                //                             crossAxisAlignment: CrossAxisAlignment.start,
                //                             children: [
                //                               Text('${eventdata['doc_name']}',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                //                               Text('${eventdata['doc_qualification']}',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 9)),
                //                             ],
                //                           )
                //                         ],
                //                       ),
                //                       const SizedBox(height: 10,),
                //                       SizedBox(
                //                         width: 130,
                //                         child: Container(
                //                           decoration: BoxDecoration(
                //                               color: AppColors.primaryColor2,
                //                               borderRadius: BorderRadius.circular(6)
                //                           ),
                //                           child: const Padding(
                //                             padding: EdgeInsets.all(8.0),
                //                             child: Row(
                //                               mainAxisAlignment: MainAxisAlignment.center,
                //                               children: [
                //                                 Text('Notify me',style: TextStyle(fontWeight: FontWeight.w500,color: AppColors.whiteColor,fontSize: 12)),
                //                                 SizedBox(width: 10,),
                //                                 Icon(Icons.notifications_active,color: AppColors.whiteColor,),
                //                               ],
                //                             ),
                //                           ),
                //                         ),
                //                       )
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //               Positioned(
                //                 right: 0,
                //                 top: 0,
                //                 child: Container(
                //                   height: 70,
                //                   width: 100,
                //                   decoration: const BoxDecoration(
                //                       color:AppColors.primaryColor2,
                //                       borderRadius: BorderRadius.only(bottomLeft: Radius.circular(21),topRight: Radius.circular(6))
                //                   ),
                //                   child: Padding(
                //                     padding: const EdgeInsets.all(15.0),
                //                     child: Image.asset('assets/icons/cake.png'),
                //                   ),
                //                 ),
                //               )
                //             ],
                //           );
                //         }
                //         return Text('No upcoming events');
                //       }
                //       return Text('Some error occured ,Please restart your application');
                //     }
                // ),
                // const SizedBox(height: 70,)
        
        
              ],
            ),
          ),
        ),
      ),
    );
  }
}

