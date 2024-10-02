
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/BottomNavManager.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20lists/Doctor%20list.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20lists/Doctor_details/doctor_detials.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Tabs_widgets/Travel_plan_pages.dart';
import 'package:rx_route_new/Util/Utils.dart';
import 'package:rx_route_new/View/homeView/Doctor/doctor_details.dart';
import 'package:rx_route_new/View/homeView/Doctor/doctors_list.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app_colors.dart';
import '../../../constants/styles.dart';

class TpDoctorListPage extends StatefulWidget {
  final int month;

  // Constructor to accept the month
  TpDoctorListPage({required this.month});

  @override
  _TpDoctorListPageState createState() => _TpDoctorListPageState();
}

class _TpDoctorListPageState extends State<TpDoctorListPage> {
  String getMonthName(int month) {
    DateTime date = DateTime(0, month);
    return DateFormat.MMMM().format(date);
  }

  Future<List<dynamic>> fetchDoctorData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    try {
      var data = {"userId": int.parse(userID.toString()), "month": widget.month};
      final response = await http.post(
        Uri.parse(AppUrl.doctorsInTp),
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );
      print('Aaa  ${Utils.userId}');
      print('heloo:$data');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        if (data['success']) {
          List<dynamic> doctorsList = [];
          for (var sublist in data['data']) {
            doctorsList.addAll(sublist);
          }
          return doctorsList;
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred while fetching data');
    }
  }

  void _showNoDataDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false, // Prevent closing by tapping outside
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Travel Plans Yet'),
          content: Text('What would you like to do?'),
          actions: <Widget>[
            TextButton(
              child: Text('Create TP'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      // TravelPlanmainpage()
                    BottomNavigationMngr()
                  ), // Replace with actual page
                );
              },
            ),
            TextButton(
              child: Text('Doctor List'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DoctorList()), // Replace with actual page
                );
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the dialog

              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    print('paassed month:${widget.month}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(); // Manually trigger going back
        return true;  // Returning true allows the back button to pop the page
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primaryColor,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Doctors List for Month ${getMonthName(widget.month)}',
            style: text40016black,
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<List<dynamic>>(
          future: fetchDoctorData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showNoDataDialog(context); // Show dialog when no data
              });
              return Center(child: Text('No data available'));
            } else {
              final doctors = snapshot.data!;
              return ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorDetailsPage(doctorId: doctor['id']),));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(width: 1,color: doctor['visit_type'] == 'core'
                                    ? AppColors.tilecolor2
                                    : doctor['visit_type'] == 'supercore'
                                    ? AppColors.tilecolor1
                                    : AppColors.tilecolor3,)
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: doctor['visit_type'] == 'core'
                              ? AppColors.tilecolor2
                              : doctor['visit_type'] == 'supercore'
                              ? AppColors.tilecolor1
                              : AppColors.tilecolor3,
                                  child: Text('${doctor['firstName'][3]}'),
                                ),
                                title: Text('${doctor['firstName']} ${doctor['lastName']}'),
                                // subtitle: Text('Specialization: ${doctor['specialization']}'),
                                // trailing: Text('Phone: ${doctor['mobile']}'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}