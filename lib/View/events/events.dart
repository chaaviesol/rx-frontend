import 'dart:convert';
import 'dart:isolate';

// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../Util/Utils.dart';
import '../../app_colors.dart';
import 'package:http/http.dart' as http;

import '../../constants/styles.dart';
import '../../res/app_url.dart';
import '../homeView/home_view_rep.dart';

class Events extends StatefulWidget {
  String eventType;
  Events({required this.eventType,super.key});

  @override
  State<Events> createState() => _EventsState();
}


class _EventsState extends State<Events> {

  List<dynamic> myevents = [];

  static const int alarmId = 0;

  void setAlarm() async {
    // Set the alarm for 5 seconds from now
    final DateTime now = DateTime.now();
    final int isolateId = Isolate.current.hashCode;
    print("[$now] Setting alarm for 5 seconds from now...");
    // await AndroidAlarmManager.oneShot(
    //   const Duration(seconds: 5),
    //   alarmId,
    //   alarmCallback,
    //   exact: true,
    //   wakeup: true,
    // );
  }

  static void alarmCallback(BuildContext context) {
    Utils.flushBarErrorMessage('Alarm fired!', context);
    // FlutterRingtonePlayer.play(
    //   android: AndroidSounds.alarm,
    //   ios:IosSounds.alarm,
    //   looping: true,
    //   volume: 1.0,
    //   asAlarm: true,
    // );
    print("Alarm fired!");
    // Here you can integrate with a plugin to actually play a sound
  }


  Future<dynamic> getEvents() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    final url = Uri.parse(AppUrl.getEvents);
    var data = {
      "requesterUniqueId":uniqueID
    };
    try {
      final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),);

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON
        var responseData = jsonDecode(response.body);
        myevents.clear();
        myevents.addAll(responseData['todayEvents']);
        print('myevents:$myevents');
        // return json.decode(response.body);
        return myevents;
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
      backgroundColor: AppColors.whiteColor,
      appBar:  AppBar(
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
            child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
          ),
        ],
        centerTitle: true,
        title: Text(
          widget.eventType.toString(),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child:Column(
            children: [
              Text('Birthday\'s',style:text60017black),
              FutureBuilder(
                future: getEvents(),
                builder: (context,snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }else if(snapshot.hasError){
                    return Center(child: Text('Some error occured !'),);
                  }else if(snapshot.hasData){
                    return ListView.builder(
                    shrinkWrap: true,
                        itemCount: snapshot.data[0]['todayBirthday'].length,
                        itemBuilder: (context,index) {
                          var snapdata = snapshot.data[0]['todayBirthday'];
                          return Column(
                            children: [
                              Padding(
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
                                            const Text(
                                              'Hey !',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.whiteColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              'Its ${snapdata[index]['firstName']}\'s Birthday !',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.whiteColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const Text(
                                              'Wish an all the Best',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.whiteColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 30),
                                            Row(
                                              children: [
                                                CircleAvatar(radius: 25,child: Text('${snapdata[index]['firstName'][3]}'),),
                                                SizedBox(width: 10),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${snapdata[index]['firstName']}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: AppColors.whiteColor,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${snapdata[index]['doc_qualification']}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        color: AppColors.whiteColor,
                                                        fontSize: 9,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            InkWell(
                                              onTap: ()async{
                                                setAlarm();
                                              },
                                              child: SizedBox(
                                                width: 130,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryColor2,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          'Notify me',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            color: AppColors.whiteColor,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        Icon(
                                                          Icons.notifications_active,
                                                          color: AppColors.whiteColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Positioned(
                                    //   right: 0,
                                    //   top: 0,
                                    //   child: Container(
                                    //     height: 70,
                                    //     width: 100,
                                    //     decoration: const BoxDecoration(
                                    //       color: AppColors.primaryColor2,
                                    //       borderRadius: BorderRadius.only(
                                    //         bottomLeft: Radius.circular(21),
                                    //         topRight: Radius.circular(6),
                                    //       ),
                                    //     ),
                                    //     child: Padding(
                                    //       padding: const EdgeInsets.all(15.0),
                                    //       child: Image.asset('assets/icons/cake.png'),
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                    );
                    return Text('${snapshot.data[0]['todayBirthday']}');
                  }else{
                    // return Center(child: Text('No Data'),);
                  }
                  return Center(child: Text('Some error occured !,Please restart your application.'),);
                }
              ),
              SizedBox(height: 10,),
              Text('Anniversary\'s',style:text60017black),
              FutureBuilder(
                  future: getEvents(),
                  builder: (context,snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }else if(snapshot.hasError){
                      return Center(child: Text('Some error occured !'),);
                    }else if(snapshot.hasData){
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data[0]['todayAnniversary'].length,
                          itemBuilder: (context,index) {
                            var snapdata = snapshot.data[0]['todayAnniversary'][index];
                            return Column(
                              children: [
                                Padding(
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
                                              const Text(
                                                'Hey !',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.whiteColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                'Its ${snapdata['firstName']}\'s Anniversary !',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.whiteColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const Text(
                                                'Wish an all the Best',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.whiteColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 30),
                                              Row(
                                                children: [
                                                  CircleAvatar(radius: 25,child: Text('${snapdata['firstName'][3].toString().toUpperCase()}'),),
                                                  SizedBox(width: 10),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '${snapdata['firstName']}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: AppColors.whiteColor,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${snapdata['doc_qualification']}',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w500,
                                                          color: AppColors.whiteColor,
                                                          fontSize: 9,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              const SizedBox(height: 10),
                                              InkWell(
                                                onTap: ()async{

                                                },
                                                child: SizedBox(
                                                  width: 130,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primaryColor2,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Padding(
                                                      padding: EdgeInsets.all(8.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            'Notify me',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              color: AppColors.whiteColor,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Icon(
                                                            Icons.notifications_active,
                                                            color: AppColors.whiteColor,
                                                          ),
                                                        ],
                                                      ),
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
                                            color: AppColors.primaryColor2,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(21),
                                              topRight: Radius.circular(6),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: SizedBox(
                                              height:35,
                                                width:35,
                                                child: Image.asset('assets/icons/rings-wedding.png',color: AppColors.whiteColor,))
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                      );
                    }else{
                      return Center(child: Text('No Data'),);
                    }
                    return Center(child: Text('Some error occured !,Please restart your application.'),);
                  }
              ),
            ],
          )
        ),
      ),
    );
  }
}

