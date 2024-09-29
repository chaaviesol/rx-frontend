import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Tabs_widgets/Travel_plan_pages2.dart';
import 'package:rx_route_new/Util/Utils.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app_colors.dart';
import '../../../../constants/styles.dart';
import '../../../../res/app_url.dart';

class MyApprovalDoctor extends StatefulWidget {
  const MyApprovalDoctor({super.key});

  @override
  State<MyApprovalDoctor> createState() => _MyApprovalDoctorState();
}

class _MyApprovalDoctorState extends State<MyApprovalDoctor>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> pendingDoctors = [];
  List<dynamic> rejectedDoctors = [];
  List<dynamic> acceptedDoctors = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDoctorData();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> fetchDoctorData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');

    if (userID == null) {
      setState(() {
        errorMessage = 'User ID not found';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(AppUrl.gettingapproval_doctors),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"userId": int.parse(userID)}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = json.decode(response.body);
      print('Data: $data');

      if (data['data'] != null) {
        final List<dynamic> doctorList = [];
        for (var rep in data['data']) {
          if (rep['doctorList'] != null) {
            // Attach "name" to each doctor in the doctorList
            for (var doctor in rep['doctorList']) {
              doctor['repName'] = rep['name']; // Store the rep's name inside the doctor data
              doctorList.add(doctor);
            }
          }
        }

        setState(() {
          pendingDoctors = doctorList
              .where((doc) => doc['approvalStatus'] == 'Pending')
              .toList();
          rejectedDoctors = doctorList
              .where((doc) => doc['approvalStatus'] == 'Rejected')
              .toList();
          acceptedDoctors = doctorList
              .where((doc) => doc['approvalStatus'] == 'Accepted')
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No doctor data found';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception caught: $e');
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }


  Future<void> approveDoctor(int doctorId, String status) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrl.approving_doctors),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"dr_id": doctorId, "status": status}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Utils.flushBarErrorMessage('$status successfully !', context);
        setState(() {
          fetchDoctorData(); // Refresh the doctor data after approval/rejection
        });
      } else {
        Utils.flushBarErrorMessage('$status failed !', context);
        print('Failed to update doctor status');
      }
    } catch (e) {
      print('Error while approving doctor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Rejected'),
                  Tab(text: 'Accepted'),
                ],
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage))
                    : TabBarView(
                  controller: _tabController,
                  children: [
                    DoctorList(
                        doctors: pendingDoctors,
                        showActions: true,
                        onApproveDoctor: approveDoctor),
                    DoctorList(
                        doctors: rejectedDoctors,
                        showActions: false,
                        onApproveDoctor: approveDoctor),
                    DoctorList(
                        doctors: acceptedDoctors,
                        showActions: false,
                        onApproveDoctor: approveDoctor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorList extends StatelessWidget {
  final List<dynamic> doctors;
  final bool showActions;
  final Function(int, String) onApproveDoctor;

  const DoctorList({
    required this.doctors,
    required this.showActions,
    required this.onApproveDoctor, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const Center(child: Text('No doctors available'));
    }

    return ListView.builder(
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              InkWell(
                onTap: (){
                  // Navigator.push(context, MaterialPageRoute(builder: TravelPlanPages2(tpid: tpid, monthandyear: monthandyear, tp_status: tp_status)))
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textfiedlColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display "name": "Manu"
                        Text(
                          'From: ${doctor['repName']}', // Display the rep's name
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              child: Text(doctor['firstName'][0]),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${doctor['firstName']} ${doctor['lastName']}',
                                    style: text60014black),
                                Text(doctor['specialization'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.borderColor,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(doctor['approvalStatus'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        if (showActions)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (doctor['id'] != null) {
                                    onApproveDoctor(doctor['id'], 'Accepted');
                                  } else {
                                    print('Doctor ID is null');
                                  }
                                },
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: Text('Accept')),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  if (doctor['id'] != null) {
                                    onApproveDoctor(doctor['id'], 'Rejected');
                                  } else {
                                    print('Doctor ID is null');
                                  }
                                },
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(child: Text('Reject')),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

