import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app_colors.dart';
import '../../../../constants/styles.dart';
import 'Doctor_details/doctor_detials.dart';

class DoctorList extends StatefulWidget {
  const DoctorList({Key? key}) : super(key: key);

  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  List<dynamic> _doctors = [];
  List<dynamic> _filteredDoctors = [];
  bool _isLoading = true;
  String? _errorMessage;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctors() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('uniqueID');
    try {
      final response = await http.post(
        Uri.parse(AppUrl.getdoctors),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rep_UniqueId': userID}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _doctors = data['data'];
            _filteredDoctors = _doctors; // Initially, all doctors are shown.
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
    await _fetchDoctors();
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

  void _onSearchChanged() {
    String searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        String fullName = '${doctor['firstName']} ${doctor['lastName']}'.toLowerCase();
        String specialization = doctor['specialization']?.toLowerCase() ?? '';
        return fullName.contains(searchQuery) || specialization.contains(searchQuery);
      }).toList();
    });
  }

  void _handleMenuAction(String action, dynamic doctor) {
    switch (action) {
      case 'edit':
        print('Edit ${doctor['firstName']} ${doctor['lastName']}');
        break;
      case 'delete':
        _deleteDoctor(doctor['id']);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0,right: 10.0,top: 10.0,bottom: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextFormField(
                        controller: _searchController,
                        // focusNode: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 25,
                        width: 25,
                        child: Image.asset('assets/icons/settings.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : ListView.builder(
                itemCount: _filteredDoctors.length + 1,
                itemBuilder: (context, index) {
                  if(index == _filteredDoctors.length){
                    return SizedBox(height: 80,);
                  }
                  final doctor = _filteredDoctors[index];
                  final visitType = doctor['visit_type'] ?? 'unknown';

                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DoctorDetailsPage(doctorId: doctor['id']),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: doctor['visit_type'] == 'core'
                          ? AppColors.tilecolor2
                          : doctor['visit_type'] == 'supercore'
                          ? AppColors.tilecolor1
                          : AppColors.tilecolor3,
                      child: Text(
                        doctor['firstName'][0], // Display first letter
                        style: TextStyle(color: AppColors.whiteColor),
                      ),
                    ),
                    title: Text(
                      '${doctor['firstName']} ${doctor['lastName']}',
                      style: text50014black,
                    ),
                    subtitle: Text(
                      '${doctor['specialization']}',
                      style: text50012black,
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) =>
                          _handleMenuAction(action, doctor),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: const [
                                Icon(Icons.edit),
                                SizedBox(width: 10),
                                Text('Edit', style: text50012black),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete),
                                SizedBox(width: 10),
                                Text('Delete', style: text50012black),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

