import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:rx_route_new/View/homeView/Employee/widgets.dart';
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
@override
  void initState() {
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
    return Center(
      child: Text("Doctors List"),
    );
  }

  Widget ChemistsList(BuildContext context) {
    return Center(
      child: Text("Chemists List"),
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
        AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: false), // Hide grid lines
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                      Widget text;
                      switch (value.toInt()) {
                        case 0:
                          text = const Text('Jan', style: style);
                          break;
                        case 1:
                          text = const Text('Feb', style: style);
                          break;
                        case 2:
                          text = const Text('Mar', style: style);
                          break;
                        case 3:
                          text = const Text('Apr', style: style);
                          break;
                        case 4:
                          text = const Text('May', style: style);
                          break;
                        case 5:
                          text = const Text('Jun', style: style);
                          break;
                        case 6:
                          text = const Text('Jul', style: style);
                          break;
                        case 7:
                          text = const Text('Aug', style: style);
                          break;
                        case 8:
                          text = const Text('Sep', style: style);
                          break;
                        case 9:
                          text = const Text('Oct', style: style);
                          break;
                        case 10:
                          text = const Text('Nov', style: style);
                          break;
                        case 11:
                          text = const Text('Dec', style: style);
                          break;
                        default:
                          text = const Text('', style: style);
                          break;
                      }
                      return SideTitleWidget(child: text, axisSide: meta.axisSide);
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      );
                      return SideTitleWidget(
                        child: Text(value.toInt().toString(), style: style),
                        axisSide: meta.axisSide,
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.black, width: 1),
              ),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(toY: 10, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(toY: 20, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(toY: 30, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(toY: 40, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 4,
                  barRods: [
                    BarChartRodData(toY: 50, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 5,
                  barRods: [
                    BarChartRodData(toY: 60, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 6,
                  barRods: [
                    BarChartRodData(toY: 70, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 7,
                  barRods: [
                    BarChartRodData(toY: 80, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 8,
                  barRods: [
                    BarChartRodData(toY: 90, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 9,
                  barRods: [
                    BarChartRodData(toY: 100, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 10,
                  barRods: [
                    BarChartRodData(toY: 90, color: Colors.blue),
                  ],
                ),
                BarChartGroupData(
                  x: 11,
                  barRods: [
                    BarChartRodData(toY: 80, color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
            ),
          ],
        ),
        body: SafeArea(
          child: FutureBuilder(
            future: single_employee_details(),
            builder: (context,snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }else if(snapshot.hasError){
                return Center(child: Text('Some error occured !'),);
              }else if(snapshot.hasData){
                final List<Widget> _pages = [
                  EmpDetailsWidgets.BasicInfo(snapshot.data),
                  PerformanceWidget(context),
                  EmployeeList(context)
                ];
                // return Text('${snapshot.data}');
                var snapdata = snapshot.data;
                return Column(
                  children: [
                    ListTile(
                      leading:  CircleAvatar(
                        radius: 50,
                        child: Text('${snapdata[0]['name'][0]}'),
                      ),
                      title:  Text('${snapdata[0]['name']}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${snapdata[0]['qualification']}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                          Text('${snapdata[0]['designation']}', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                        ],
                      ),
                      trailing: InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditRep(uniqueID: snapdata['unique_id'],userID: snapdata['id'],),));
                        },
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: Image.asset('assets/icons/edit.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
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
              }
            return Center(child: Text('Some error occured , Please restart your application !'),);
            }
          ),
        ),
      ),
    );
  }
}
