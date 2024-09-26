// import 'dart:convert';
// import 'dart:isolate';
//
// // import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
//
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../Util/Utils.dart';
// import '../../app_colors.dart';
// import 'package:http/http.dart' as http;
//
// import '../../constants/styles.dart';
// import '../../res/app_url.dart';
// import '../homeView/home_view_rep.dart';
//
// class Events extends StatefulWidget {
//   String eventType;
//   Events({required this.eventType,super.key});
//
//   @override
//   State<Events> createState() => _EventsState();
// }
//
//
// class _EventsState extends State<Events> {
//
//   List<dynamic> myevents = [];
//
//   static const int alarmId = 0;
//
//   void setAlarm() async {
//     // Set the alarm for 5 seconds from now
//     final DateTime now = DateTime.now();
//     final int isolateId = Isolate.current.hashCode;
//     print("[$now] Setting alarm for 5 seconds from now...");
//     // await AndroidAlarmManager.oneShot(
//     //   const Duration(seconds: 5),
//     //   alarmId,
//     //   alarmCallback,
//     //   exact: true,
//     //   wakeup: true,
//     // );
//   }
//
//   static void alarmCallback(BuildContext context) {
//     Utils.flushBarErrorMessage('Alarm fired!', context);
//     // FlutterRingtonePlayer.play(
//     //   android: AndroidSounds.alarm,
//     //   ios:IosSounds.alarm,
//     //   looping: true,
//     //   volume: 1.0,
//     //   asAlarm: true,
//     // );
//     print("Alarm fired!");
//     // Here you can integrate with a plugin to actually play a sound
//   }
//
//
//   Future<dynamic> getEvents() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     String? uniqueID = preferences.getString('uniqueID');
//     final url = Uri.parse(AppUrl.getEvents);
//     var data = {
//       "requesterUniqueId":uniqueID
//     };
//     try {
//       final response = await http.post(url,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(data),);
//
//       if (response.statusCode == 200) {
//         // If the server returns a 200 OK response, parse the JSON
//         var responseData = jsonDecode(response.body);
//         myevents.clear();
//         myevents.addAll(responseData['todayEvents']);
//         print('myevents:$myevents');
//         // return json.decode(response.body);
//         return myevents;
//       } else {
//         // If the server returns an error, throw an exception
//         throw Exception('Failed to load data');
//       }
//     } catch (e) {
//       // Handle any exceptions that occur during the request
//       throw Exception('Failed to load data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.whiteColor,
//       appBar:  AppBar(
//         backgroundColor: AppColors.whiteColor,
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: InkWell(
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                 color: AppColors.primaryColor,
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
//             ),
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 20.0),
//             child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
//           ),
//         ],
//         centerTitle: true,
//         title: Text(
//           widget.eventType.toString(),
//           style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child:Column(
//             children: [
//               Text('Birthday\'s',style:text60017black),
//               FutureBuilder(
//                 future: getEvents(),
//                 builder: (context,snapshot) {
//                   if(snapshot.connectionState == ConnectionState.waiting){
//                     return Center(child: CircularProgressIndicator(),);
//                   }else if(snapshot.hasError){
//                     return Center(child: Text('Some error occured !'),);
//                   }else if(snapshot.hasData){
//                     return ListView.builder(
//                     shrinkWrap: true,
//                         itemCount: snapshot.data[0]['todayBirthday'].length,
//                         itemBuilder: (context,index) {
//                           var snapdata = snapshot.data[0]['todayBirthday'];
//                           return Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Stack(
//                                   children: [
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         color: AppColors.primaryColor,
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.only(
//                                           left: 25.0,
//                                           top: 10,
//                                           bottom: 10,
//                                           right: 10,
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             const Text(
//                                               'Hey !',
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.w500,
//                                                 color: AppColors.whiteColor,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                             Text(
//                                               'Its ${snapdata[index]['firstName']}\'s Birthday !',
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.w500,
//                                                 color: AppColors.whiteColor,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                             const Text(
//                                               'Wish an all the Best',
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.w500,
//                                                 color: AppColors.whiteColor,
//                                                 fontSize: 12,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 30),
//                                             Row(
//                                               children: [
//                                                 CircleAvatar(radius: 25,child: Text('${snapdata[index]['firstName'][3]}'),),
//                                                 SizedBox(width: 10),
//                                                 Column(
//                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                   children: [
//                                                     Text(
//                                                       '${snapdata[index]['firstName']}',
//                                                       style: TextStyle(
//                                                         fontWeight: FontWeight.w500,
//                                                         color: AppColors.whiteColor,
//                                                         fontSize: 12,
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       '${snapdata[index]['doc_qualification']}',
//                                                       style: TextStyle(
//                                                         fontWeight: FontWeight.w500,
//                                                         color: AppColors.whiteColor,
//                                                         fontSize: 9,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 )
//                                               ],
//                                             ),
//                                             const SizedBox(height: 10),
//                                             InkWell(
//                                               onTap: ()async{
//                                                 setAlarm();
//                                               },
//                                               child: SizedBox(
//                                                 width: 130,
//                                                 child: Container(
//                                                   decoration: BoxDecoration(
//                                                     color: AppColors.primaryColor2,
//                                                     borderRadius: BorderRadius.circular(6),
//                                                   ),
//                                                   child: const Padding(
//                                                     padding: EdgeInsets.all(8.0),
//                                                     child: Row(
//                                                       mainAxisAlignment: MainAxisAlignment.center,
//                                                       children: [
//                                                         Text(
//                                                           'Notify me',
//                                                           style: TextStyle(
//                                                             fontWeight: FontWeight.w500,
//                                                             color: AppColors.whiteColor,
//                                                             fontSize: 12,
//                                                           ),
//                                                         ),
//                                                         SizedBox(width: 10),
//                                                         Icon(
//                                                           Icons.notifications_active,
//                                                           color: AppColors.whiteColor,
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                     Positioned(
//                                       right: 0,
//                                       top: 0,
//                                       child: Container(
//                                         height: 70,
//                                         width: 100,
//                                         decoration: const BoxDecoration(
//                                           color: AppColors.primaryColor2,
//                                           borderRadius: BorderRadius.only(
//                                             bottomLeft: Radius.circular(21),
//                                             topRight: Radius.circular(6),
//                                           ),
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(15.0),
//                                           child: Image.asset('assets/icons/cake.png'),
//                                         ),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           );
//                         }
//                     );
//                     return Text('${snapshot.data[0]['todayBirthday']}');
//                   }else{
//                     // return Center(child: Text('No Data'),);
//                   }
//                   return Center(child: Text('Some error occured !,Please restart your application.'),);
//                 }
//               ),
//               SizedBox(height: 10,),
//               Text('Anniversary\'s',style:text60017black),
//               FutureBuilder(
//                   future: getEvents(),
//                   builder: (context,snapshot) {
//                     if(snapshot.connectionState == ConnectionState.waiting){
//                       return Center(child: CircularProgressIndicator(),);
//                     }else if(snapshot.hasError){
//                       return Center(child: Text('Some error occured !'),);
//                     }else if(snapshot.hasData){
//                       return ListView.builder(
//                           shrinkWrap: true,
//                           itemCount: snapshot.data[0]['todayAnniversary'].length,
//                           itemBuilder: (context,index) {
//                             var snapdata = snapshot.data[0]['todayAnniversary'][index];
//                             return Column(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Stack(
//                                     children: [
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           color: AppColors.primaryColor,
//                                           borderRadius: BorderRadius.circular(6),
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.only(
//                                             left: 25.0,
//                                             top: 10,
//                                             bottom: 10,
//                                             right: 10,
//                                           ),
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               const Text(
//                                                 'Hey !',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.w500,
//                                                   color: AppColors.whiteColor,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 'Its ${snapdata['firstName']}\'s Anniversary !',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.w500,
//                                                   color: AppColors.whiteColor,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                               const Text(
//                                                 'Wish an all the Best',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.w500,
//                                                   color: AppColors.whiteColor,
//                                                   fontSize: 12,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 30),
//                                               Row(
//                                                 children: [
//                                                   CircleAvatar(radius: 25,child: Text('${snapdata['firstName'][3].toString().toUpperCase()}'),),
//                                                   SizedBox(width: 10),
//                                                   Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     children: [
//                                                       Text(
//                                                         '${snapdata['firstName']}',
//                                                         style: TextStyle(
//                                                           fontWeight: FontWeight.w500,
//                                                           color: AppColors.whiteColor,
//                                                           fontSize: 12,
//                                                         ),
//                                                       ),
//                                                       Text(
//                                                         '${snapdata['doc_qualification']}',
//                                                         style: TextStyle(
//                                                           fontWeight: FontWeight.w500,
//                                                           color: AppColors.whiteColor,
//                                                           fontSize: 9,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   )
//                                                 ],
//                                               ),
//                                               const SizedBox(height: 10),
//                                               InkWell(
//                                                 onTap: ()async{
//
//                                                 },
//                                                 child: SizedBox(
//                                                   width: 130,
//                                                   child: Container(
//                                                     decoration: BoxDecoration(
//                                                       color: AppColors.primaryColor2,
//                                                       borderRadius: BorderRadius.circular(6),
//                                                     ),
//                                                     child: const Padding(
//                                                       padding: EdgeInsets.all(8.0),
//                                                       child: Row(
//                                                         mainAxisAlignment: MainAxisAlignment.center,
//                                                         children: [
//                                                           Text(
//                                                             'Notify me',
//                                                             style: TextStyle(
//                                                               fontWeight: FontWeight.w500,
//                                                               color: AppColors.whiteColor,
//                                                               fontSize: 12,
//                                                             ),
//                                                           ),
//                                                           SizedBox(width: 10),
//                                                           Icon(
//                                                             Icons.notifications_active,
//                                                             color: AppColors.whiteColor,
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       Positioned(
//                                         right: 0,
//                                         top: 0,
//                                         child: Container(
//                                           height: 70,
//                                           width: 100,
//                                           decoration: const BoxDecoration(
//                                             color: AppColors.primaryColor2,
//                                             borderRadius: BorderRadius.only(
//                                               bottomLeft: Radius.circular(21),
//                                               topRight: Radius.circular(6),
//                                             ),
//                                           ),
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(15.0),
//                                             child: SizedBox(
//                                               height:35,
//                                                 width:35,
//                                                 child: Image.asset('assets/icons/rings-wedding.png',color: AppColors.whiteColor,))
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }
//                       );
//                     }else{
//                       return Center(child: Text('No Data'),);
//                     }
//                     return Center(child: Text('Some error occured !,Please restart your application.'),);
//                   }
//               ),
//             ],
//           )
//         ),
//       ),
//     );
//   }
// }
//

import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../Util/Utils.dart';
import '../../app_colors.dart';
import '../../constants/styles.dart';
import '../../res/app_url.dart';
import '../../services/localnotifications.dart';
import '../homeView/home_view_rep.dart';

class Events extends StatefulWidget {
  final String eventType;
  Events({required this.eventType, super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {
  Future<Map<String, dynamic>> getEvents() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    final url = Uri.parse(AppUrl.getEvents);
    var data = {"requesterUniqueId": uniqueID};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Three tabs: Birthdays, Anniversaries, Upcoming
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: ProfileIconWidget(
                userName: Utils.userName![0].toString().toUpperCase() ?? 'N/A',
              ),
            ),
          ],
          centerTitle: true,
          title: Text(
            widget.eventType.toString(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primaryColor,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Birthdays"),
              Tab(text: "Anniversaries"),
              Tab(text: "Upcoming"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab for Birthdays
            FutureBuilder(
              future: getEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Some error occurred!'));
                } else if (snapshot.hasData) {
                  var events = snapshot.data as Map<String, dynamic>;
                  var birthdays = events['todayEvents'][0]['todayBirthday'] ?? [];
                  return ListView.builder(
                    itemCount: birthdays.length,
                    itemBuilder: (context, index) {
                      return buildEventCard(birthdays[index], 'Birthday');
                    },
                  );
                } else {
                  return const Center(child: Text('No Data'));
                }
              },
            ),
            // Tab for Anniversaries
            FutureBuilder(
              future: getEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                return const Center(child: Text('Some error occurred!'));
                } else if (snapshot.hasData) {
                var events = snapshot.data as Map<String, dynamic>;
                var anniversaries = events['todayEvents'][0]['todayAnniversary'] ?? [];
                return ListView.builder(
                itemCount: anniversaries.length,
                itemBuilder: (context, index) {
                return buildEventCard(anniversaries[index], 'Anniversary');
                },
                );
                } else {
                return const Center(child: Text('No Data'));
                }
              },
            ),
            // Tab for Upcoming Events
            FutureBuilder(
              future: getEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Some error occurred!'));
                } else if (snapshot.hasData) {
                  var events = snapshot.data as Map<String, dynamic>;
                  var upcomingEvents = events['UpcomingEvents'] ?? [];
                  return ListView.builder(
                    itemCount: upcomingEvents.length,
                    itemBuilder: (context, index) {
                      var birthdayNotifications = upcomingEvents[index]['BirthdayNotification'] ?? [];
                      var anniversaryNotifications = upcomingEvents[index]['AnniversaryNotification'] ?? [];
                      return Column(
                        children: [
                          ...birthdayNotifications.map((event) => buildEventCard(event, 'Upcoming Birthday')),
                          ...anniversaryNotifications.map((event) => buildEventCard(event, 'Upcoming Anniversary')),
                        ],
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No Data'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

// Method to build an event card for Birthday or Anniversary
  Widget buildEventCard(Map<String, dynamic> eventData, String eventType) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                top: 10,
                bottom: 10,
                right: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'It\'s ${eventData['firstName']}\'s $eventType!',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                      fontSize: 12,
                    ),
                  ),
                  const Text(
                    'Wish them all the best!',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        child: Text(eventData['firstName'][0].toString().toUpperCase()),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            eventData['firstName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.whiteColor,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            eventData['doc_qualification'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.whiteColor,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class SeeAllPage extends StatefulWidget {
  @override
  _SeeAllPageState createState() => _SeeAllPageState();
}

class _SeeAllPageState extends State<SeeAllPage> with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _subTabController;
  List<dynamic> todayBirthday = [];
  List<dynamic> todayAnniversary = [];
  List<dynamic> upcomingBirthday = [];
  List<dynamic> upcomingAnniversary = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this); // Main tabs
    _subTabController = TabController(length: 2, vsync: this); // Sub-tabs
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    final url = AppUrl.getEvents;
    final body = jsonEncode({
      "requesterUniqueId": uniqueID,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            todayBirthday = data['todayEvents'][0]['todayBirthday'] ?? [];
            todayAnniversary = data['todayEvents'][0]['todayAnniversary'] ?? [];
            upcomingBirthday = data['UpcomingEvents'][0]['BirthdayNotification'] ?? [];
            upcomingAnniversary = data['UpcomingEvents'][0]['AnniversaryNotification'] ?? [];
            isLoading = false; // Set loading to false after data is fetched
          });
        } else {
          print("Error: ${data['message']}");
        }
      } else {
        print("Server error: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching notifications: $error");
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _subTabController.dispose();
    super.dispose();
  }
  Widget _buildEventList(List<dynamic> events, String eventType) {
    if (events.isEmpty) {
      return Center(child: Text("No $eventType"));
    }
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final eventData = events[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(6),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'It\'s ${eventData['firstName']}\'s ${eventType == "Birthday" ? "Birthday" : "Anniversary"}!',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'Wish them all the best!',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      child: Text(
                        eventData['firstName'][0].toString().toUpperCase(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventData['firstName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.whiteColor,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          eventData['doc_qualification'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.whiteColor,
                            fontSize: 9,
                          ),
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Main tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text("Events"),
          bottom: TabBar(
            controller: _mainTabController,
            tabs: [
              Tab(text: "Today's Events"),
              Tab(text: "Upcoming Events"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _mainTabController,
          children: [
            // Today's Events
            Column(
              children: [
                TabBar(
                  controller: _subTabController,
                  tabs: [
                    Tab(text: "Today's Birthday"),
                    Tab(text: "Today's Anniversary"),
                  ],
                ),
                Expanded(
                  child: isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Set your desired color here
                    ),
                  ) // Loading indicator
                      : TabBarView(
                    controller: _subTabController,
                    children: [
                      _buildEventList(todayBirthday, "Birthday"),
                      _buildEventList(todayAnniversary, "Anniversary"),
                    ],
                  ),
                ),
              ],
            ),
            // Upcoming Events
            Column(
              children: [
                TabBar(
                  controller: _subTabController,
                  tabs: [
                    Tab(text: "Upcoming Birthday"),
                    Tab(text: "Upcoming Anniversary"),
                  ],
                ),
                Expanded(
                  child: isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Set your desired color here
                    ),
                  ) // Loading indicator
                      : TabBarView(
                    controller: _subTabController,
                    children: [
                      _buildEventList(upcomingBirthday, "Birthday"),
                      _buildEventList(upcomingAnniversary, "Anniversary"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

