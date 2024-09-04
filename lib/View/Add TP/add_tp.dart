import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../Util/Routes/routes_name.dart';
import '../../Util/Utils.dart';
import '../../app_colors.dart';
import 'package:http/http.dart' as http;

import '../../constants/styles.dart';
import '../../res/app_url.dart';
import '../homeView/home_view_rep.dart';

class AddTravelPlan extends StatefulWidget {
  const AddTravelPlan({super.key});

  @override
  State<AddTravelPlan> createState() => _AddTravelPlanState();
}

class _AddTravelPlanState extends State<AddTravelPlan> {
  List<Map<String, dynamic>> travelPlans = [];
  List<Map<String, dynamic>> dropdownOptions = [];
  Future<void> _fetchDropdownOptions() async {
    final response = await http.get(Uri.parse(AppUrl.list_headqrts));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        dropdownOptions = List<Map<String, dynamic>>.from(data['data']);
      });
    } else {
      // Handle error
      print('Failed to load dropdown options');
    }
  }

  Future<void> _submitTravelPlans() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    List<Map<String, String>> dateHeadquarters = [];

    for (var plan in travelPlans) {
      String date = plan['date']?.text ?? '';
      if (date.isNotEmpty && plan['selectedHeadquarter'] != null) {
        String headquarter = plan['selectedHeadquarter']['sub_headquarter'] ?? '';
        dateHeadquarters.add({'date': date, 'headquarters': headquarter});
      }
    }

    if (dateHeadquarters.isEmpty) {
      // Handle error - show a message or alert indicating that all fields must be filled.
      Utils.flushBarErrorMessage('Please fill all the fields !', context);
      print('Please fill all fields to submit the travel plan.');
      return;
    }

    Map<String, dynamic> requestData = {
      'requester_id':uniqueID , // Replace with actual requester_id if needed
      'date_headquarters': dateHeadquarters,
    };

    try{
      final response = await http.post(
        Uri.parse(AppUrl.generate_tp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      print('data:${jsonEncode(requestData)}');
      print('status code :${response.statusCode}');
      print('repons${response.body}');
      print('url :${AppUrl.generate_tp}');
      if (response.statusCode == 200) {
        // Handle success
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        Navigator.pushNamedAndRemoveUntil(context, RoutesName.successsplash, (route) => false,);
        print('Travel plan submitted successfully.');
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        // Handle error
        print('Failed to submit travel plan.');
      }

    }catch(e){
      throw Exception(e.toString());
    }

  }

  void _printTravelPlans() {
    for (var plan in travelPlans) {
      String date = plan['date']?.text ?? 'No date selected';
      Map<String, dynamic>? headquarter = plan['selectedHeadquarter'];
      String headquarterInfo = headquarter != null
          ? '${headquarter['headquarter_name']} - ${headquarter['sub_headquarter']}'
          : 'No headquarter selected';
      print('Date: $date, Headquarter: $headquarterInfo');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDropdownOptions();
    _addNewTravelPlan(); // Add initial travel plan fields
  }

  void _addNewTravelPlan() {
    setState(() {
      travelPlans.add({
        'date': TextEditingController(),
        'selectedHeadquarter': null,
      });
    });
  }

  void _removeTravelPlan(int index) {
    setState(() {
      if (travelPlans.length > 1) {
        travelPlans.removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    for (var plan in travelPlans) {
      plan['date']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
          ),
        ],
        title: const Text(
          'TP Request',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: travelPlans.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date', style: text50014black),
                                SizedBox(height: 10),
                                TextFormField(
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                  controller: travelPlans[index]['date'],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.arrow_drop_down,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                  ),
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime currentDate = DateTime.now();
                                    DateTime firstDate = DateTime(currentDate.year, currentDate.month - 1, 1);
                                    DateTime initialDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day - 1);
                                    DateTime lastDate = DateTime(currentDate.year, currentDate.month + 2, 0);

                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      firstDate: firstDate,
                                      initialDate: currentDate,
                                      lastDate: lastDate,
                                      builder: (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                            primaryColor: AppColors.primaryColor,
                                            hintColor: AppColors.primaryColor,
                                            colorScheme: const ColorScheme.light(primary: AppColors.primaryColor),
                                            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (pickedDate != null) {
                                      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                      setState(() {
                                        travelPlans[index]['date']!.text = formattedDate;
                                      });
                                    }
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Select Date';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Area', style: text50014black),
                                    SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.textfiedlColor,
                                      ),
                                      child: DropdownButtonFormField<Map<String, dynamic>>(
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                                          filled: true,
                                          fillColor: Colors.grey.shade100,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        value: travelPlans[index]['selectedHeadquarter'],
                                        items: dropdownOptions.map((option) {
                                          return DropdownMenuItem<Map<String, dynamic>>(
                                            value: option,
                                            child: Text(
                                              '${option['headquarter_name']} - ${option['sub_headquarter']}',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (newValue) {
                                          setState(() {
                                            travelPlans[index]['selectedHeadquarter'] = newValue;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10),

                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add_circle, color: AppColors.primaryColor),
                                onPressed: _addNewTravelPlan,
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: AppColors.primaryColor),
                                onPressed: () => _removeTravelPlan(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor, shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                        side: const BorderSide(color:AppColors.primaryColor), // Sets the border color
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        // if (_myformKey.currentState!.validate()) {
                          // Map data = {
                          //   "staff_id": Utils.empId,
                          //   "leave_type": selectedLeaveType.toString(),
                          //   "remarks": reasonController.text.toString(),
                          //   "from_date": dateInput.text.toString(),

//   "to_date": dateInput2.text.toString(),
                          //   // "name": "$firstname $lastname"
                          // };
                          // if (selectedLeaveType != null &&
                          //     dateInput.text.isNotEmpty &&
                          //     dateInput2.text.isNotEmpty &&
                          //     reasonController.text.isNotEmpty) {
                          //   applyLeave();
                          // } else {
                          //   // Show an error message or alert indicating that all required fields must be filled.
                          //   Utils.flushBarErrorMessage('Please fill all fields to apply leave', context);
                          // }
                        // }
                        _printTravelPlans();
                        _submitTravelPlans();
                        print('${travelPlans}');

                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          maximumSize: const Size(100, 40),
                          minimumSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontWeight: FontWeight.w600,color: AppColors.whiteColor),
                      )),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
