
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:rx_route_new/View/homeView/Employee/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../New Rx Project/Manager/BottomNav/My lists/Doctor_details/doctor_detials.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../res/app_url.dart';
import '../home_view_rep.dart';
import 'edit_emp.dart';

class EmpDetails extends StatefulWidget {
  int empID;
  String uniqueID;
  String phone;
  EmpDetails({required this.empID,required this.uniqueID,required this.phone,super.key});

  @override
  State<EmpDetails> createState() => _EmpDetailsState();
}

class _EmpDetailsState extends State<EmpDetails> with SingleTickerProviderStateMixin {

  List<dynamic> empDetails = [];

  List<dynamic> _doctors = [];

  bool _isLoading = true;
  String? _errorMessage;

  late TabController _tabController;

  final List<Widget> _tabs = [
    const Tab(text: 'Basic information'),
    const Tab(text: 'Perfomance'),
    const Tab(text: 'Employees'),
  ];



  Future<dynamic> single_employee_details() async {
    String url = AppUrl.single_employee_details;
    Map<String, dynamic> data = {
      "uniqueId": widget.uniqueID,
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('responseData is: ${responseData['data']}');
        return responseData['data'];
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage('${e.toString()}', context);
      throw Exception('Failed to load data: $e');
    }
  }


  Future<void> _fetchDoctors() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('uniqueID');
    try {
      final response = await http.post(
        Uri.parse(AppUrl.getdoctors),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rep_UniqueId': widget.uniqueID}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _doctors = data['data'];
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
          _errorMessage = 'Failed to load doctors';
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

  Future<void> _refreshData() async {
    await _fetchDoctors(); // Refresh data
  }

  Future<void> _deleteDoctor(int doctorId) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrl.delete_doctor),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'dr_id': doctorId}),
      );

    if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data['success']) {
    Fluttertoast.showToast(
    msg: "Doctor deleted successfully",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    );
    // Reload the page
    await _refreshData();
    } else {
    Fluttertoast.showToast(
    msg: "Failed to delete doctor: ${data['message']}",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    );
    }
    } else {
    Fluttertoast.showToast(
    msg: "Failed to delete doctor",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    );
    }
    } catch (e) {
    Fluttertoast.showToast(
    msg: "An error occurred: $e",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    );
    }
  }

  void _handleMenuAction(String action, dynamic doctor) {
    switch (action) {
      case 'edit':
      // Implement edit functionality here
        print('Edit ${doctor['firstName']} ${doctor['lastName']}');
        break;
      case 'delete':
        _deleteDoctor(doctor['id']);
        break;
    }
  }


  Future<List<Map<String, dynamic>>> fetchChemists() async {
    String url = AppUrl.getaddedChemist;
    Map<String, dynamic> data = {
      "userId": widget.uniqueID, // Ensure this matches the parameter expected by your API
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success']) {
          // Extract the list of chemists from the response
          var chemistsData = responseData['data'];
          // Flatten the nested list and map to extract chemists
          List<Map<String, dynamic>> chemists = [];
          for (var list in chemistsData) {
            for (var item in list) {
              if (item['chemist'] is List) {
                for (var chemist in item['chemist']) {
                  chemists.add(chemist);
                }
              }
            }
          }
          return chemists;
        } else {
          Utils.flushBarErrorMessage('${responseData['message']}', context);
          return [];
        }
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        return [];
      }
    } catch (e) {
      Utils.flushBarErrorMessage('${e.toString()}', context);
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  void initState() {
    _fetchDoctors();
    print('emp id:${widget.empID}');
    // TODO: implement initState
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  Widget DoctorsList(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : ListView.builder(
          itemCount: _doctors.length + 1,
          itemBuilder: (context, index) {
            if(index < _doctors.length){
              final doctor = _doctors[index];
              final visitType = doctor['visit_type'] ?? 'unknown';

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorDetailsPage(doctorId: doctor['id']),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: doctor['visit_type'] == 'core'
                      ? AppColors.tilecolor2
                      : doctor['visit_type'] == 'supercore'
                      ? AppColors.tilecolor1
                      : AppColors.tilecolor3,
                  child: Text(doctor['firstName'][0]),
                ),
                title: Row(
                  children: [
                    const SizedBox(width: 10),
                    Text('${doctor['firstName']} ${doctor['lastName']}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black)),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text('${doctor['specialization']}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black)),
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) => _handleMenuAction(action, doctor),
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: const [
                            Icon(Icons.edit),
                            SizedBox(width: 10),
                            Text('Edit', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black)),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.black)),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              );
            }else{
              return Container(
                height: 100, // Adjust height as needed
                color: Colors.white,
              );
            }
          },
        ),
      ),);
  }



  Widget ChemistsList(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchChemists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Some error occurred!'));
        } else if (snapshot.hasData) {
          var chemists = snapshot.data!;
          if (chemists.isEmpty) {
            return Center(child: Text('No chemists found.'));
          }
          return ListView.builder(
            itemCount: chemists.length,
            itemBuilder: (context, index) {
              var chemist = chemists[index];
              return ListTile(
                title: Text(chemist['address'] ?? 'No Address'),
                subtitle: Text('Pincode: ${chemist['pincode'] ?? 'N/A'}'),
              );
            },
          );
        }
        return Center(child: Text('No data found.'));
      },
    );
  }

  Widget EmployeeList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        SizedBox(height: 20),
        TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelStyle: TextStyle(
              color: AppColors.primaryColor
          ),
          tabs: [
            Tab(text: "Doctors List",),
            Tab(text: "Chemists List"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              DoctorsList(context),
              ChemistsList(context),
            ],
          ),
        ),
      ],
    );
  }
  Widget PerformanceWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      SizedBox(height: 10,),
    Center(
    child: Text(
    'Employee Analytics',
    style: TextStyle(fontSize: 20,),
    ),
    ),
    SizedBox(height: 20),

    // AspectRatio(
    // aspectRatio: 1.5,
    // child: BarChart(
    // BarChartData(
    // gridData: FlGridData(show: false), // Hide grid lines
    // titlesData: FlTitlesData(
    // topTitles: AxisTitles(
    // sideTitles: SideTitles(showTitles: false),
    // ),
    // rightTitles: AxisTitles(
    // sideTitles: SideTitles(showTitles: false),
    // ),
    // bottomTitles: AxisTitles(
    // sideTitles: SideTitles(
    // showTitles: true,
    // getTitlesWidget: (value, meta) {
    // const style = TextStyle(
    // color: Colors.black,
    // fontWeight: FontWeight.bold,
    // fontSize: 12,
    // );
    // Widget text;
    // switch (value.toInt()) {
    // case 0:
    // text = const Text('Jan', style: style);
    // break;
    // case 1:
    // text = const Text('Feb', style: style);
    // break;
    // case 2:
    // text = const Text('Mar', style: style);
    // break;
    // case 3:
    // text = const Text('Apr', style: style);
    // break;
    // case 4:
    // text = const Text('May', style: style);
    // break;
    // case 5:
    // text = const Text('Jun', style: style);
    // break;
    // case 6:
    // text = const Text('Jul', style: style);
    // break;
    // case 7:
    // text = const Text('Aug', style: style);
    // break;
    // case 8:
    // text = const Text('Sep', style: style);
    // break;
    // case 9:
    // text = const Text('Oct', style: style);
    // break;
    // case 10:
    // text = const Text('Nov', style: style);
    // break;
    // case 11:
    // text = const Text('Dec', style: style);
    // break;
    // default:
    // text = const Text('', style: style);
    // break;
    // }
    // return SideTitleWidget(child: text, axisSide: meta.axisSide);
    // },
    // reservedSize: 30,
    // ),
    // ),
    // leftTitles: AxisTitles(
    // sideTitles: SideTitles(
    // showTitles: true,
    // interval: 10,
    //
    // getTitlesWidget: (value, meta) {
    // const style = TextStyle(
    // color: Colors.black,
    // fontWeight: FontWeight.bold,
    // fontSize: 12,
    // );
    // return SideTitleWidget(
    // child: Text(value.toInt().toString(), style: style),
    // axisSide: meta.axisSide,
    // );
    // },
    // reservedSize: 40,
    // ),
    // ),
    // ),
    // borderData: FlBorderData(
    // show: true,
    // border: Border.all(color: Colors.black, width: 1),
    // ),
    // barGroups: [
    // BarChartGroupData(
    // x: 0,
    // barRods: [
    // BarChartRodData(toY: 10, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 1,
    // barRods: [
    // BarChartRodData(toY: 20, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 2,
    // barRods: [
    // BarChartRodData(toY: 30, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 3,
    // barRods: [
    // BarChartRodData(toY: 40, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 4,
    // barRods: [
    // BarChartRodData(toY: 50, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 5,
    // barRods: [
    // BarChartRodData(toY: 60, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 6,
    // barRods: [
    // BarChartRodData(toY: 70, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 7,
    // barRods: [
    // BarChartRodData(toY: 80, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 8,
    // barRods: [
    // BarChartRodData(toY: 90, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 9,
    // barRods: [
    // BarChartRodData(toY: 100, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 10,
    // barRods: [
    // BarChartRodData(toY: 90, color: Colors.blue),
    // ],
    // ),
    // BarChartGroupData(
    // x: 11,
    // barRods: [
    // BarChartRodData(toY: 80, color: Colors.blue),
    // ],
    // ),
    // ],
    // ),
    // ),
    // ),
    ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          backgroundColor: AppColors.whiteColor,
          floatingActionButton: SizedBox(
            width: MediaQuery.of(context).size.width/3,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: (){
                Utils.makePhoneCall(widget.phone);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call, color: AppColors.whiteColor),
                  SizedBox(width: 10),
                  Text('Call', style: TextStyle(color: AppColors.whiteColor)),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

          appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          title: const Text('Employee Details', style: TextStyle(color: Colors.black)),
          centerTitle: true,
            leading: IconButton(
              icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: AppColors.primaryColor,
                  )), // Replace with your desired icon
              onPressed: () {
                // Handle the button press
                Navigator.pop(context);
              },
            ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
            ),
          ],
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: single_employee_details(), // Fetch employee details
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Some error occurred!'));
              } else if (snapshot.hasData) {
                var snapdata = snapshot.data; // Since it's a Map, we use it as an object.

                // Check if snapdata is not null and is a map
                if (snapdata is Map<String, dynamic>) {
                  // List of pages you want to display in TabBarView
                  final List<Widget> _pages = [
                    EmpDetailsWidgets.BasicInfo(snapdata),
                    PerformanceWidget(context),
                    EmployeeList(context),
                  ];

                  // Building UI with snapdata (since it's a map, access fields directly)
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          radius: 50,
                          child: Text('${snapdata['name'][0]}'), // Display first letter of the name
                        ),
                        title: Text('${snapdata['name']}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${snapdata['qualification']}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                            Text('${snapdata['designation']}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                          ],
                        ),
                        trailing: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditRep(
                                  uniqueID: snapdata['uniqueId'],
                                  userID: snapdata['id'],
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: Image.asset('assets/icons/edit.png'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TabBar(
                        tabs: _tabs,
                        labelColor: Colors.black,
                        indicatorColor: Colors.green,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: _pages,
                        ),
                      ),
                    ],
                  );
                } else {
                  // In case of an unexpected data structure
                  return Center(child: Text('Unexpected data format.'));
                }
              }
              return Center(child: Text('No data found.'));
            },
          ),
        )

    ),
    );
  }
}