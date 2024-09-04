import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../View/MarkasVisited/markasVisited.dart';
import '../../../../../View/homeView/Leave/LeaveRequest.dart';
import '../../../../../app_colors.dart';
import '../../../../../constants/styles.dart';

class DoctorDetailsPage extends StatefulWidget {
  final int doctorId;

  const DoctorDetailsPage({required this.doctorId, Key? key}) : super(key: key);

  @override
  _DoctorDetailsPageState createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> with TickerProviderStateMixin {
  Map<String, dynamic>? _doctorDetails;
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;
  late TabController _taggedTabController;
  List<dynamic> _visitHistory = [];
  bool _isVisitHistoryLoading = true;
  String? _visitHistoryErrorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _taggedTabController = TabController(length: 2, vsync: this);
    _fetchDoctorDetails();
    _fetchVisitHistory();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      final response = await http.post(
        Uri.parse(AppUrl.single_doctor_details),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'dr_id': widget.doctorId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _doctorDetails = data['data'][0];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load doctor details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchVisitHistory() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('uniqueID');

    try {
      final response = await http.post(
        Uri.parse(AppUrl.getvisitedDates), // Update with your actual API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requesterUniqueId': userID,
          'docId': widget.doctorId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _visitHistory = data['data'];
            _isVisitHistoryLoading = false;
          });
        } else {
          setState(() {
            _visitHistoryErrorMessage = data['message'];
            _isVisitHistoryLoading = false;
          });
        }
      } else {
        setState(() {
          _visitHistoryErrorMessage = 'Failed to load visit history';
          _isVisitHistoryLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _visitHistoryErrorMessage = 'An error occurred: $e';
        _isVisitHistoryLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
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
          'Doctor Details',
          style: text40016black,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: AppColors.primaryColor,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 5.5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              child: Text(_doctorDetails?['firstName'][0] ?? ''),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_doctorDetails!['firstName']} ${_doctorDetails!['lastName']}',
                                  style: text60017,
                                ),
                                Text('${_doctorDetails!['doc_qualification']}', style: text40012),
                                Text('${_doctorDetails!['specialization']}', style: text40012),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('Basic Information', style: text50014black),
                  const SizedBox(height: 10),
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    controller: _tabController,
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: AppColors.primaryColor,
                    tabs: const [
                      Tab(text: 'Schedule'),
                      Tab(text: 'Overview'),
                      Tab(text: 'Tagged'),
                      Tab(text: 'Visit History'),
                    ],
                  ),
                  SizedBox(
                    height: 400, // Adjust the height based on your content
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildScheduleTab(),
                        _buildOverviewTab(),
                        _buildTaggedTab(),
                        _buildVisitHistoryTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width/4,
              bottom: MediaQuery.of(context).size.height/14.9,
              child: ElevatedButton(style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor),
                onPressed: () {
                print('00000${_doctorDetails!["addressDetail"][0][0]['product']}');
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MarkAsVisited(doctorID: widget.doctorId, products: _doctorDetails!["addressDetail"][0][0]['product'],),));

                }, child: Text('Mark As Visited',style: text50012,),),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mobile: ${_doctorDetails!['mobile']}', style: text50014black),
          Text('Gender: ${_doctorDetails!['gender']}', style: text50014black),
          Text('Date of Birth: ${_doctorDetails!['date_of_birth']}', style: text50014black),
          Text('Wedding Date: ${_doctorDetails!['wedding_date']}', style: text50014black),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return ListView.builder(
      itemCount: _doctorDetails!['schedule'].length,
      itemBuilder: (context, index) {
        final schedule = _doctorDetails!['schedule'][index][0];
        return Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10,),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 30,width:100,
                    color: AppColors.primaryColor,
                    child: Center(child: Text(schedule['schedule']['day'], style: text50014))),
              ),
              Text('${schedule['schedule']['start_time']} - ${schedule['schedule']['end_time']}', style: text50014black),
            ],

        );
      },
    );
  }

  Widget _buildTaggedTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            controller: _taggedTabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'Products'),
              Tab(text: 'Chemist'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _taggedTabController,
              children: [
                _buildProductsTab(),
                _buildChemistTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return ListView.builder(
      itemCount: _doctorDetails!['addressDetail'][0][0]['product'].length,
      itemBuilder: (context, index) {
        final product = _doctorDetails!['addressDetail'][0][0]['product'][index];
        return ListTile(
          title: Text(product['product'], style: text50014black),
        );
      },
    );
  }

  Widget _buildChemistTab() {
    return ListView.builder(
      itemCount: _doctorDetails!['addressDetail'][0][0]['chemist'].length,
      itemBuilder: (context, index) {
        final chemist = _doctorDetails!['addressDetail'][0][0]['chemist'][index];
        return ListTile(
          title: Text(chemist['address'], style: text50014black),
          subtitle: Text('Pincode: ${chemist['pincode']}', style: text50014black),
        );
      },
    );
  }

  Widget _buildVisitHistoryTab() {
    if (_isVisitHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_visitHistoryErrorMessage != null) {
      return Center(child: Text(_visitHistoryErrorMessage!));
    } else {
      return ListView.builder(
        itemCount: _visitHistory.length,
        itemBuilder: (context, index) {
          final visit = _visitHistory[index];
          return ListTile(
            title: Text('Reporting Type: ${visit['reporting_type']}', style: text50014black),
            subtitle: Text('Date and Time: ${visit['datetime']}', style: text50014black),
          );
        },
      );
    }
  }
}
