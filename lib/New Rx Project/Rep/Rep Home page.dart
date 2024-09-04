
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/New%20Rx%20Project/Manager/Settings.dart';
import 'package:rx_route_new/View/profile/settings/settings.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/styles.dart';
import '../../View/events/upcoming_events.dart';

class RepHomepage extends StatefulWidget {
  const RepHomepage({Key? key}) : super(key: key);

  @override
  State<RepHomepage> createState() => _RepHomepageState();
}

class _RepHomepageState extends State<RepHomepage> {
  bool isLoading = true;

  List<dynamic> myeventstoday = [];
  List<dynamic> myeventsupcoming = [];
  Map<String,dynamic> allevents = {};
  @override
  void initState() {
    super.initState();
    getEvents();
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child:
              Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.location_solid,
                    color: AppColors.primaryColor,
                  ),
                  Text(
                    'Kozhikode',
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
              SizedBox(height: 10),
              Text('Calls', style: text40016black),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height / 6,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: Image.asset('assets/icons/mytelephone.png', height: 100, width: 100),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Calls',
                                style: text60012,
                              ),
                              Text('Missed: 5', style: text40012),
                              Text('14-08-2024', style: text40012),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(8.0),
                      height: MediaQuery.of(context).size.height / 6,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            child: Image.asset('assets/icons/mytelephone.png', height: 100, width: 100),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Calls',
                                style: text60012,
                              ),
                              Text('1800', style: text40012),
                              Text('14-08-2024', style: text40012),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
    );
  }
}

