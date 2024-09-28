import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/View/homeView/Doctor/edit_doctor.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../View/MarkasVisited/markasVisited.dart';
import '../../../../../View/homeView/Leave/LeaveRequest.dart';
import '../../../../../app_colors.dart';
import '../../../../../constants/styles.dart';
import '../../../Doctors_mngr/Edit_Doctor.dart';

class DoctorDetailsPage extends StatefulWidget {
  final int doctorId;
  final int? tpid;
   DoctorDetailsPage({this.tpid,required this.doctorId, Key? key}) : super(key: key);

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
  String _selectedMonth = "01";
  List<dynamic> _performanceData = [];

  Future<void> _fetchPerformanceData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = await preferences.getString('uniqueID');
    final response = await http.post(
      Uri.parse(AppUrl.getuserPerformance),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"requesterUniqueId": uniqueID, "drId": widget.doctorId, "month": _selectedMonth}),
    );
    if (response.statusCode == 200 && json.decode(response.body)['success']) {
      setState(() => _performanceData = json.decode(response.body)['data']);
    } else {
      throw Exception('Failed to load performance data');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _taggedTabController = TabController(length: 5, vsync: this);
    _fetchDoctorDetails();
    _fetchVisitHistory();
    _fetchPerformanceData();
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
      body: Center(
        child: _isLoading
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
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            color:_doctorDetails?['visit_type'] == 'core'
                                ? AppColors.tilecolor2
                                : _doctorDetails?['visit_type'] == 'supercore'
                                ? AppColors.tilecolor1
                                : AppColors.tilecolor3,
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 5.5,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: AppColors.whiteColor,
                                    child: Text(_doctorDetails?['firstName'][0] ?? '',),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_doctorDetails!['firstName']} ${_doctorDetails!['lastName']}',
                                        style: text60017black,
                                      ),
                                      Text('${_doctorDetails!['doc_qualification']}', style: text40012black),
                                      Text('${_doctorDetails!['specialization']}', style: text40012black),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            right: 10,
                            top: 10,
                            child: InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Edit_Doctor(doctorID: _doctorDetails!['id'],),));
                              },
                                child: Icon(Icons.edit))),
                        Positioned(
                          bottom: 20,
                          right: 0,
                          child: ClipPath(
                            clipper: MyCustomClipper(),
                            child: Container(
                              width: 150,
                              color: Colors.white30,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('${_doctorDetails?['visit_type'].toString().toUpperCase()}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
                                  ),),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Basic Information', style: text50014black),
                        _doctorDetails!['approvalStatus'] == "Accepted"? InkWell(
                          onTap: (){
                            // Navigator.pushNamed(context, RoutesName.markasvisited,arguments: doctorDetails);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MarkAsVisited(
                              doctorID: widget.doctorId,products:_doctorDetails!["addressDetail"][0][0]['product'],),));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor2,
                                borderRadius: BorderRadius.circular(50)),
                            child: const Padding(
                              padding: EdgeInsets.only(top: 8.0,bottom: 8.0,left: 10,right: 10),
                              child: Text(
                                'Mark as Visited',
                                style: text40012
                              ),
                            ),
                          ),
                        ):InkWell(
                          onTap: (){

                            // Navigator.pushNamed(context, RoutesName.markasvisited,arguments: doctorDetails);
                            // Navigator.push(context, MaterialPageRoute(builder: (context) => MarkAsVisited(
                            //   doctorID: widget.doctorId,products:_doctorDetails!["addressDetail"][0][0]['product'],),));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(50)),
                            child: const Padding(
                              padding: EdgeInsets.only(top: 8.0,bottom: 8.0,left: 10,right: 10),
                              child: Text(
                                  'Mark as Visited',
                                  style: text40012
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      controller: _tabController,
                      labelColor: AppColors.primaryColor,
                      unselectedLabelColor: Colors.black54,
                      indicatorColor: AppColors.primaryColor,
                      tabs: const [
                        // Tab(text: 'Address',),
                        Tab(text: 'Report',),
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
                          _buildReportTab(),
                          // _buildAddressTab(),
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
              // Positioned(
              //   left: MediaQuery.of(context).size.width/4,
              //   bottom: MediaQuery.of(context).size.height/14.9,
              //   child: ElevatedButton(style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.primaryColor),
              //     onPressed: () {
              //       Navigator.push(context, MaterialPageRoute(builder: (context) => MarkAsVisited(doctorID: widget.doctorId, products: _doctorDetails!["addressDetail"][0][0]['product'],),));
              //     }, child: Text('Mark As Visited',style: text50012,),),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  //performance widgets......
  Widget _buildHeaderWithDropdown() {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            value: _selectedMonth,
            items: List.generate(12, (index) {
              String month = (index + 1).toString().padLeft(2, '0');
              return DropdownMenuItem(child: Text(monthNames[index]), value: month);
            }),
            onChanged: (value) {
              setState(() {
                _selectedMonth = value!;
                _fetchPerformanceData();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceContainer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('Total Visits', _performanceData.isNotEmpty ? _performanceData[0]['total_visits'].toString() : '0', Colors.purple),
            _buildStatCard('Visited', _performanceData.isNotEmpty ? _performanceData[0]['visited'].toString() : '0', Colors.green),
            _buildStatCard('Balance Visits', _performanceData.isNotEmpty ? _performanceData[0]['balance_visit'].toString() : '0', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Column(
      children: [
        Text(count, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildDoctorTable() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8)],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                      children: ['Doctor Name', 'Assigned Calls', 'Completed Calls', 'Pending Calls'].map((title) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        );
                      }).toList(),
                    ),
                    ..._performanceData.map<TableRow>((data) {
                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(8.0), child: Text('Dr. ${data['dr_Id']}', style: TextStyle(color: Colors.blue))),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(data['total_visits'].toString(), textAlign: TextAlign.center)),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(data['visited'].toString(), textAlign: TextAlign.center)),
                          Padding(padding: const EdgeInsets.all(8.0), child: Text(data['balance_visit'].toString(), textAlign: TextAlign.center)),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // .........
  Widget _buildAddressTab(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    Padding(
    padding: EdgeInsets.all(25.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context,index) {
        return Text('${_doctorDetails!['addressDetail'][0]}');
      }
    ),
    SizedBox(height: 10,),
    ],
    ),
    )
      ],
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
  Widget _buildReportTab(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderWithDropdown(),
        _buildPerformanceContainer(),
        _buildDoctorTable()
      ],
    );
  }

  Widget _buildScheduleTab() {
    return ListView.builder(
      itemCount:_doctorDetails!['addressDetail'].length,
      // _doctorDetails!['schedule'].length,
      itemBuilder: (context, index) {
        print('${_doctorDetails!['addressDetail'].length}');
        final schedule = _doctorDetails!['schedule'][index][0];
        return Stack(
          children: [
            // Positioned(
            //     top: 10,
            //     right: 10,
            //     child: Row(
            //       children: [
            //         Icon(Icons.delete,size: 20,),
            //         Icon(Icons.edit,size: 20,),
            //       ],
            //     )),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sub HeadQuart : ${_doctorDetails!['addressDetail'][index][0]['address']['subHeadQuarter']}',style: TextStyle(fontWeight: FontWeight.bold),),
                  Text('Area : ${_doctorDetails!['addressDetail'][index][0]['address']['address']}',style: TextStyle(fontWeight: FontWeight.bold),),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount:_doctorDetails!['addressDetail'][index][0]['address']['schedule'].length ,
                    itemBuilder: (context,subIndex) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width:100,
                                decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(9)
                            ),
                                child: Center(child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('${_doctorDetails!['addressDetail'][index][0]['address']['schedule'][subIndex]['day']}',style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.bold),),
                                ))),
                            Text('${_doctorDetails!['addressDetail'][index][0]['address']['schedule'][subIndex]['start_time']}',style: TextStyle(fontWeight: FontWeight.bold),),
                            Text('${_doctorDetails!['addressDetail'][index][0]['address']['schedule'][subIndex]['end_time']}',style: TextStyle(fontWeight: FontWeight.bold))
                          ],
                        ),
                      );
                    }
                  ),
                  Divider()

                  // Text('${_doctorDetails!['addressDetail'][1][0]['address']['address']}',style: TextStyle(fontWeight: FontWeight.bold),),
                  // SizedBox(height: 10,),
                  // Text('${_doctorDetails!['addressDetail'][index]}'),
                  // SizedBox(height: 10,),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: AppColors.textfiedlColor
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Text('${_doctorDetails!['addressDetail'][index][0]['address']['subHeadQuarter']}',style: TextStyle(fontWeight: FontWeight.bold),),
                  //   ),
                  // ),
                  // SizedBox(height: 10,),
                  // // Text('${_doctorDetails!['addressDetail'][index][0]}'),
                  // ListView.builder(
                  //   shrinkWrap: true,
                  //   itemCount: _doctorDetails!['addressDetail'][index][0]['address']['schedule'].length,
                  //   itemBuilder: (context,subIndex) {
                  //     return Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: [
                  //         Container(
                  //           height: 50,
                  //           width: 100,
                  //           decoration: BoxDecoration(
                  //             color: AppColors.primaryColor
                  //           ),
                  //             child: Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: Text('${_doctorDetails!['addressDetail'][0][subIndex]['address']['schedule'][subIndex]['day']}',style: text50012,),
                  //             )),
                  //         Text('${_doctorDetails!['addressDetail'][0][subIndex]['address']['schedule'][subIndex]['start_time']}'),
                  //         Text('${_doctorDetails!['addressDetail'][0][subIndex]['address']['schedule'][subIndex]['end_time']}'),
                  //       ],
                  //     );
                  //   }
                  // ),
                ],
              ),
            ),
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
        int itemNum = index=1;
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
          leading: CircleAvatar(
            backgroundColor: AppColors.pastelColors[index],
            child: Text('${chemist['buildingName'][0]}'),
          ),
          title: Text(chemist['buildingName'], style: text50014black),
          // subtitle: Text('Pincode: ${chemist['pincode']}', style: text50014black),
        );
      },
    );
    // return Text('${_doctorDetails!['addressDetail'][0][0]['chemist'][0]['buildingName']}');
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


class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return _getCustomPath(size);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }

  // Function to create a custom path matching the shape in the image
  // Function to create a W-cut path on the left side of the ribbon
  Path _getCustomPath(Size size) {
    Path path = Path();

    // Start from top-left corner
    path.moveTo(0, 0);

    // Move to a point to create the first diagonal cut for the W shape
    path.lineTo(20, 20);

    // Move back to the left to create the bottom of the first "V" of the "W"
    path.lineTo(0, 40);

    // Create the second diagonal for the next cut
    path.lineTo(20, 60);

    // Move back to the left to create the bottom of the second "V" of the "W"
    path.lineTo(0, 80);

    // Move to the bottom-left corner of the container
    path.lineTo(0, size.height);

    // Draw the remaining rectangle around the other sides
    path.lineTo(size.width, size.height); // Right-bottom corner
    path.lineTo(size.width, 0); // Top-right corner
    path.close(); // Close the path

    return path;
  }
}