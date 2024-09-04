
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../Util/Routes/routes_name.dart';
import '../../../../../Util/Utils.dart';
import '../../../../../View/homeView/Employee/add_rep.dart';
import '../../../../../app_colors.dart';
import '../../../../../constants/styles.dart';
import '../../../../../defaultButton.dart';
import '../../../../../res/app_url.dart';
import '../../../../../widgets/customDropDown.dart';



class Edit_employee_mngr extends StatefulWidget {
  const Edit_employee_mngr({super.key});

  @override
  State<Edit_employee_mngr> createState() => _Edit_employee_mngrState();
}

class _Edit_employee_mngrState extends State<Edit_employee_mngr> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _gender = '';

  List<Officer> _officers = [];
  String? _selectedReportingOfficer;

  Headquarter? selectedHeadquarter;

  String? fileName;
  Future<List<Headquarter>> fetchHeadquarters() async {
    String url = AppUrl.list_headqrts;
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<dynamic> headquartersJson = data['data'];
      return headquartersJson.map((json) => Headquarter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load headquarters');
    }
  }

  Future<List<Officer>> fetchofficers() async {
    String url = AppUrl.managers_list; // Replace with your actual API URL
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var officersJson = data['data'] as List;
      List<Officer> officers = officersJson.map((officer) => Officer.fromJson(officer)).toList();
      return officers;
    } else {
      throw Exception('Failed to load headquarters');
    }
  }

  void _loadOfficers() async {
    try {
      List<Officer> officers = await fetchofficers();
      setState(() {
        _officers = officers;
      });
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> editEmployee() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? myid = preferences.getString('userID');

    String url = AppUrl.edit_employee;

    Map<String, dynamic> data = {
      "name": _nameController.text,
      "gender": _gender,
      "dob": _dobController.text,
      "address": _addressController.text,
      "mobile": _mobileController.text,
      "email": _emailController.text,
      "designation": _designationController.text,
      "nationality": _nationalityController.text,
      "qualification": _qualificationController.text,
      "headquarters":int.parse(selectedHeadquarter!.id.toString()),// Assuming selectedHeadquarters is a list of objects
      "password": _passwordController.text,
      "role": _designationController.text, // Assuming role is the same as designation
      "reportingOfficer": int.parse(_selectedReportingOfficer.toString()),
      "reportingType": "Online", // Assuming this is static
      "createdBy": int.parse(myid.toString()),
      "adminid": 1, // Assuming this is static, or replace with a dynamic value
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
        Navigator.pushNamedAndRemoveUntil(context, RoutesName.successsplash, (route) => false);
        Utils.flushBarErrorMessage('Employee added successfully!', context);
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage('Failed to load data: $e', context);
    }
  }


  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qualificationController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    // _confirmPasswordController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    fetchHeadquarters();
    _loadOfficers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: InkWell(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  editEmployee();
                }
              },
              child: Defaultbutton(
                text: 'Submit',
                bgColor: AppColors.primaryColor,
                textstyle: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),


          SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Defaultbutton(
                text: 'Cancel',
                bgColor: AppColors.primaryColor,
                textstyle: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text('Basic information',style: text40014bordercolor,),
                Text('fill required fields and Get started',style: text40012bordercolor,),
                SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name',style: text50012black,),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.textfiedlColor,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 10),
                            hintStyle: text50010tcolor2,
                            hintText: 'Name'
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender',style: text50012black,),
                          SizedBox(height: 10,),
                          Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: CustomDropdown(
                                options: ['Male','Female','Other'],
                                onChanged: (value) {
                                  _gender = value.toString();
                                },
                              )
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mobile',style: text50012black,),
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.textfiedlColor,
                                borderRadius: BorderRadius.circular(6)
                            ),
                            child: TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10),
                                  border: InputBorder.none,
                                  hintText: 'Mobile Number',


                                  hintStyle: text50010tcolor2,
                                  counterText: ''
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qualification',style: text50012black,),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.textfiedlColor,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: TextFormField(
                        controller: _qualificationController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'qualification',
                            hintStyle: text50010tcolor2
                        ),
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email',style: text50012black,),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.textfiedlColor,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(left: 10),
                            hintText: 'email',
                            hintStyle: text50010tcolor2,
                            counterText: ''
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nationality',style: text50012black,),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.textfiedlColor,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: TextFormField(
                        controller: _nationalityController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Nationality',
                            hintStyle: text50010tcolor2,
                            contentPadding: EdgeInsets.only(left: 10),
                            counterText: ''
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date of Birth',style: text50012black,),
                          SizedBox(height: 10,),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.textfiedlColor,
                                borderRadius: BorderRadius.circular(6)
                            ),


                            child: TextFormField(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                              controller: _dobController,
                              decoration: InputDecoration(
                                hintStyle: text50010tcolor2,
                                hintText: 'Birth day',
                                isDense: true,
                                contentPadding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: const Icon(
                                  Icons.cake,
                                  size: 25,
                                  color: Colors.black,
                                ),
                              ),
                              readOnly: true,
                              onTap: () async {
                                DateTime currentDate = DateTime.now();
                                DateTime firstDate = DateTime(1500);
                                DateTime initialDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day - 1);
                                DateTime lastDate = DateTime(currentDate.year, currentDate.month + 2, 0); // Last day of the next month

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
                                  // Change the form  at of the date here
                                  String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                  setState(() {
                                    _dobController.text = formattedDate;
                                  });
                                }
                              },
                              validator: (value) {
                                if(value! == null && value.isEmpty){
                                  Utils.flushBarErrorMessage('Select birth day', context,);
                                }
                                return null;
                              },
                              // validator: (value) => value!.isEmpty ? 'Select Date' : null,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Designation',style: text50012black,),
                          SizedBox(height: 10,),
                          Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: CustomDropdown(
                                options: ['Reporter','Manager'],
                                onChanged: (value) {
                                  if(value == 'Reporter'){
                                    _designationController.text = "rep";
                                  }else if(value == 'Manager'){
                                    _designationController.text = value.toString();
                                  }
                                  // _designationController.text = value.toString();
                                },
                              )
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Head Quarters',style: text50012black,),
                    SizedBox(height: 10,),
                    FutureBuilder<List<Headquarter>>(
                      future: fetchHeadquarters(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No Headquarters Available'));
                        } else {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.textfiedlColor,
                            ),
                            child: CustomDropdownHeadQrt(
                              options: snapshot.data!,
                              selectedHeadquarter: selectedHeadquarter,
                              onChanged: (value) {
                                setState(() {
                                  selectedHeadquarter = value;
                                });
                              },
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),


                SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reporting Officer',style:text50012black,),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.textfiedlColor,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: CustomDropdown(
                        options:_officers.map((officer)=> officer.name).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReportingOfficer = _officers.firstWhere((officer) => officer.name == value).id.toString();
                          });
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Password',style: text50012black,),
                    SizedBox(height: 10,),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.textfiedlColor,
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Password',
                            hintStyle: text50010tcolor2,
                            contentPadding: EdgeInsets.only(left: 10),
                            counterText: ''
                        ),
                        validator: (value) {
                          if(value! == null && value.isEmpty){
                            return 'Please fill this field';
                          }
                          if(value.length <6){
                            return 'Password must contain 6 charecters';
                          }
                          return null;

                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personal Address',style: text50014black,),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.textfiedlColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextFormField(
                        controller: _addressController,
                        maxLines: 3,
                        maxLength: 118,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(left: 10),
                            border: InputBorder.none,
                            hintText: 'Personel Address',
                            counterText: '',
                            hintStyle: text50010tcolor2
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap:pickFile,
                          child: Container(
                            width: MediaQuery.of(context).size.width/1.1,

                            decoration: BoxDecoration(
                                color: AppColors.textfiedlColor,
                                borderRadius: BorderRadius.circular(6)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.file_present),
                                  SizedBox(width: 10,),
                                  Text('Add documents',style: text50012black,),
                                  SizedBox(width: 10,),
                                  fileName != null ? Icon(Icons.verified,color: AppColors.primaryColor,) : Icon(Icons.verified,color: Colors.grey,),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 100,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}