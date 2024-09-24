
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/Util/Utils.dart';
import 'package:rx_route_new/app_colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../res/app_url.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;
  bool isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _genderController = TextEditingController();
  // final TextEditingController _designationController = TextEditingController();
  // final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _qualificationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String uniqueID = preferences.getString('uniqueID') ?? 'GIK771';

    final response = await http.post(
      Uri.parse(AppUrl.single_employee_details),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"uniqueId": uniqueID}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      print('Fetched Data: ${data}');
      setState(() {
        _nameController.text = data['name'];
        // _genderController.text = data['gender'];
        // _designationController.text = data['designation'];
        // _nationalityController.text = data['nationality'];
        _dobController.text = data['date_of_birth'];
        _addressController.text = data['address'];
        _mobileController.text = data['mobile'];
        _emailController.text = data['email'];

        _qualificationController.text = data['qualification'];
        isLoading = false;
      });
    } else {
      print('Failed to load data');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveProfileData() async {
    final url = AppUrl.edit_employee;
    print('API URL: $url');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userID = int.parse(preferences.getString('userID').toString());
    String? uniqueID = preferences.getString('uniqueID');
    final body = {
      "repId": userID,
      "uniqueId": uniqueID, // Ensure this is the right value
      "name": _nameController.text,
      // "gender": _genderController.text,
      // "designation": _designationController.text,
      // "nationality": _nationalityController.text,
      "date_of_birth": _dobController.text,
      "address": _addressController.text,
      "mobile": _mobileController.text,
      "email": _emailController.text,


      "qualification": _qualificationController.text,
    };

    print('Request Body: ${json.encode(body)}');

    final response = await http.post(
      Uri.parse(url),
      body: json.encode(body),
      headers: {"Content-Type": "application/json"},
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      isEditing = !isEditing;
      final jsonResponse = json.decode(response.body);
      // Change this check based on your actual API response structure
      if (jsonResponse['success'] == true) { // Check if 'success' is true
        Utils.flushBarErrorMessage('Profile updated successfully..!', context);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Profile updated successfully!')),
        // );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }

  void toggleEditMode() {
    if (isEditing) {

    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
        actions: [
          IconButton(
            icon: Icon( Icons.edit),
            onPressed: toggleEditMode,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField('Name', _nameController),
              // buildTextField('Gender', _genderController),
              // buildTextField('Designation', _designationController),
              // buildTextField('Nationality', _nationalityController),
              buildTextField('Date of Birth', _dobController),
              buildTextField('Address', _addressController),
              buildTextField('Mobile', _mobileController),
              buildTextField('Email', _emailController),


              buildTextField('Qualification', _qualificationController),
              SizedBox(height: 20),
              // Save Button
             isEditing ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor
                ),
                onPressed: (){
                  saveProfileData();
                },
                child: Text('Save',style: TextStyle(color: AppColors.whiteColor),),
              ):Text(''),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}