import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants/styles.dart';
import 'Doctor_details/doctor_detials.dart';

class DoctorList extends StatefulWidget {
  const DoctorList({Key? key}) : super(key: key);

  @override
  State<DoctorList> createState() => _DoctorListState();
}

class _DoctorListState extends State<DoctorList> {
  List<dynamic> _doctors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
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

  Color _getVisitTypeColor(String visitType) {
    switch (visitType.toLowerCase()) {
      case 'core':
        return Colors.green;
      case 'important':
        return Colors.yellow;
      case 'supercore':
        return Colors.red;
      default:
        return Colors.grey; // Default color if the visit_type is not recognized
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : ListView.builder(
          itemCount: _doctors.length,
          itemBuilder: (context, index) {
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
                child: Text(doctor['firstName'][0]),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: _getVisitTypeColor(visitType),
                  ),
                  const SizedBox(width: 10),
                  Text('${doctor['firstName']} ${doctor['lastName']}', style: text50014black),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text('${doctor['specialization']}', style: text50012black),
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
    );
  }
}
