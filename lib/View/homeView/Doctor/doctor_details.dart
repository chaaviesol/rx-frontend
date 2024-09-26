import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../../../Util/Routes/routes_name.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../constants/styles.dart';
import '../../../res/app_url.dart';
import '../../MarkasVisited/markasVisited.dart';
import '../Employee/widgets.dart';
import '../home_view_rep.dart';
import 'edit_doctor.dart';

class DoctorDetails extends StatefulWidget {
  int doctorID;
  DoctorDetails({required this.doctorID,super.key});

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Widget> _tabs = [
    const Tab(text: 'Basic information'),
    const Tab(text: 'Documents'),
    const Tab(text: 'Notes'),
  ];


  List<dynamic> doctorDetails = [];

  Future<dynamic> single_doctordetails() async {
    String url = AppUrl.single_doctor_details;
    Map<String,dynamic> data = {
      "dr_id":widget.doctorID
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print('single doctor details called');
      print('${response.statusCode}');
      print('${response.body}');
      print('bdy:${data}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        doctorDetails.clear();
        doctorDetails.addAll(responseData['data']);
        return doctorDetails;
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
    super.initState();
    print('doctor id :${widget.doctorID}');
    single_doctordetails();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Details', style: TextStyle(),),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor, // Replace with your desired color
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(onTap: () {
              Navigator.pop(context);
            },
                child: const Icon(Icons.arrow_back, color: Colors.white)), // Adjust icon color
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
          ),
        ],
      ),
      body: FutureBuilder(
        future: single_doctordetails(),
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          } else if (snapshot.hasError) {
            return Center(child: Text(
                'Some error occured , please restart your application${snapshot.data}'),);
          } else if (snapshot.hasData) {
            print('${snapshot.data}');
            final List<Widget> _pages = [
              EmpDetailsWidgets.BasicInfo(snapshot.data),
              EmpDetailsWidgets.Documents(snapshot.data),
              EmpDetailsWidgets.Notes(snapshot.data),
            ];
            var snapdata = snapshot.data[0];
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                     CircleAvatar(
                      backgroundColor:AppColors.primaryColor,
                        radius: 35,
                    child: Text('${snapdata['doc_name'][0]}',style: text70014,),),
                     Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${snapdata['doc_name']}',
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 17),
                        ),
                        Text(
                          '${snapdata['doc_qualification']}',
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                        Text(
                          '${snapdata['specialization']}',
                          style: TextStyle(
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditDoctor(doctorID: snapdata['id'].toString(),),));
                      },
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: Image.asset('assets/icons/edit.png'),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(right: 20.0, left: 20.0),
                  child: Divider(
                    color: AppColors.dividerColor,
                    thickness: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.only(right: 20.0, left: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reports',
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 17),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TabBar(
                  controller: _tabController,
                  tabs: _tabs,
                  labelColor: Colors.black,
                  indicatorColor: Colors.green,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _pages,
                  ),
                ),

              ],
            );
          }
          return Text('Some error occured please restart your application');
        }
      ),
    );
  }
}