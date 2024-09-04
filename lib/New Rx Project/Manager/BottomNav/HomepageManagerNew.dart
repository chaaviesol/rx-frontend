import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/New%20Rx%20Project/Manager/Settings.dart';
import 'package:rx_route_new/New%20Rx%20Project/Rep/Bottom%20navigation%20rep/Leave%20and%20expense/Leave%20and%20expense.dart';
import 'package:rx_route_new/View/profile/settings/settings.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:rx_route_new/res/app_url.dart';

import '../../../constants/styles.dart';

class HomepageManager extends StatefulWidget {
  const HomepageManager({Key? key}) : super(key: key);

  @override
  State<HomepageManager> createState() => _HomepageManagerState();
}

class _HomepageManagerState extends State<HomepageManager> {
  List<dynamic> todayAnniversaries = [];
  List<dynamic> upcomingBirthdays = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final url = Uri.parse(AppUrl.getEvents); // Replace with your API URL
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"requesterUniqueId": "MUS854"}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          todayAnniversaries = data['todayEvents'][0]['todayAnniversary'];
          upcomingBirthdays = data['UpcomingEvents'][0]['BirthdayNotification'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false; // Stop loading if error
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading if exception
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            'Location',
            style: text50012black,
          ),
        ),
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
      body: Stack(
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
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.call, color: AppColors.primaryColor),
                                ),
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
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.call, color: AppColors.primaryColor),
                                ),
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
                  SizedBox(height: 10),
                  Text('Events', style: text40016black),
                  SizedBox(height: 10),

                  // Events Section
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (todayAnniversaries.isEmpty && upcomingBirthdays.isEmpty)
                          Center(
                            child: Text(
                              'There are no events',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.whiteColor,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else ...[
                          // Display Upcoming Birthdays
                          if (upcomingBirthdays.isNotEmpty) ...[
                            Text(
                              'Upcoming Birthdays',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.whiteColor,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 10),
                            for (var birthday in upcomingBirthdays) ...[
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.cake,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${birthday['firstName']} ${birthday['lastName']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.whiteColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          'DOB: ${birthday['date_of_birth']}',
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                            ],
                          ],
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor2,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                  Icon(Icons.notifications_active, color: AppColors.whiteColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),


                  // Positioned(
                  //   left: MediaQuery.of(context).size.width/3,
                  //   bottom: MediaQuery.of(context).size.height/7.9,
                  //   child:
                    ElevatedButton(style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyLeaveandexpense(),));
                      }, child: Text('MY Leave And Expense',style: text50012,),),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
