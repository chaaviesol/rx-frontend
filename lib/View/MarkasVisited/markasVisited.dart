import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../Util/Routes/routes_name.dart';
import '../../Util/Utils.dart';
import '../../app_colors.dart';
import '../../constants/styles.dart';
import '../../res/app_url.dart';
import 'package:http/http.dart' as http;

class MarkAsVisited extends StatefulWidget {
  int doctorID;
  List<dynamic> products;
  MarkAsVisited({required this.doctorID,required this.products,Key? key}) : super(key: key);

  @override
  State<MarkAsVisited> createState() => _MarkAsVisitedState();
}

class _MarkAsVisitedState extends State<MarkAsVisited> {
  bool _isChecked = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _remark = TextEditingController();

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

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        doctorDetails.clear();
        doctorDetails.addAll(responseData['data']);
        return responseData;
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage('${e.toString()}', context);
      throw Exception('Failed to load data: $e');
    }
  }


  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  Future<dynamic>markasvisited()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    String? userID = preferences.getString('userID');
    String url = AppUrl.mark_as_visited;
    Map<String,dynamic> data = {
      "reporterUniqueId":uniqueID,
      "reporterId":int.parse(userID.toString()),
      "date":_selectedDate?.toIso8601String(),
      "time":_selectedTime != null ? _selectedTime!.format(context):null,
      "products":widget.products,
      "remark":_remark.text,
      "doctorId":widget.doctorID
    };
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print('body:${(data)}');
      print('st code :${response.statusCode}');
      print('st code :${response.body}');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        Navigator.pushNamedAndRemoveUntil(context, RoutesName.successsplash, (route) => false,);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData}', context);
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    print('passed products is :${widget.products}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Mark as visited',
          style: TextStyle(),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor, // Replace with your desired color
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ), // Adjust icon color
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder(
            future: single_doctordetails(),
            builder: (context,snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }else if(snapshot.hasError){
                return Center(child: Text('Some error happend !'),);
              }else if(snapshot.hasData){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          checkColor: AppColors.whiteColor,
                          activeColor: AppColors.primaryColor,
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = value ?? false;
                            });
                          },
                        ),
                        Text('Offline reporting'),
                      ],
                    ),
                    Visibility(
                      visible: _isChecked,
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _pickDate,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Select Date',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                ),
                                child: Text(
                                  _selectedDate == null
                                      ? 'No date selected'
                                      : _selectedDate!.toLocal().toString().split(' ')[0],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: _pickTime,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Select Time',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                ),
                                child: Text(
                                  _selectedTime == null
                                      ? 'No time selected'
                                      : _selectedTime!.format(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Products',style: text50014black,),
                    SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: doctorDetails[0]['addressDetail'][0][0]['product'].length,
                      itemBuilder: (context, index) {
                        print('555${doctorDetails[0]['addressDetail'][0][0]['product']}');
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            width: 50,
                            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(5), ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon(Icons.circle, size: 8.0), // Dot icon
                                 // Spacing between icon and text
                                Center(child: Text('${doctorDetails[0]["addressDetail"][0][0]['product'][index]['product']}',style:text50014,)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Text('Remark',style: text50014black,),
                    SizedBox(height: 10,),
                    TextField(
                      onChanged: (value) {
                        _remark.text = value;
                      },
                      maxLines: 3,
                      maxLength: 362,
                      decoration: InputDecoration(
                        labelText: 'Remarks',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        counterText: '', // Hide character count
                      ),
                    ),
                    SizedBox(height: 20),
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
                                markasvisited();
                                // if (_myformKey.currentState!.validate()) {
                                // Map data = {
                                //   "staff_id": Utils.empId,
                                //   "leave_type": selectedLeaveType.toString(),
                                //   "remarks": reasonController.text.toString(),
                                //   "from_date": dateInput.text.toString(),

                                //   "to_date": dateInput2.text.toString(),
                                //   // "name": "$firstname $lastname"
                                // };
                                // if (selectdDoctor != null &&
                                //     dateInput.text.isNotEmpty &&
                                //     amount.text.isNotEmpty &&
                                //     reasonController.text.isNotEmpty) {
                                // Proceed with leave application
                                // applyleave(context);

                                // } else {
                                // Show an error message or alert indicating that all required fields must be filled.
                                // Utils.flushBarErrorMessage('Please fill in all required fields', context, Colors.red);
                                // }
                                // leaveApplication.leaveAppApi(jsonEncode(data), context);

                                // }

                                // _showMaterialDialog();
                                // showAboutDialog(context: context);

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
                );
              }
              return Center(child: Text('Some error occured , Please restart !'),);
            }
          ),
        ),
      ),
    );
  }
}
