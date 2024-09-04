import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../constants/styles.dart';
import '../../../../res/app_url.dart';
import 'Employee details/single employee.dart';

class EmployeeList extends StatefulWidget {
  const EmployeeList({super.key});

  @override
  State<EmployeeList> createState() => _EmployeeListState();
}

class _EmployeeListState extends State<EmployeeList> {
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  Future<void> _refreshData() async {
    await _fetchEmployees(); // Refresh data
  }

  Future<void> _deleteEmployee(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://52.66.145.37:3004/rep/delete_rep'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          Fluttertoast.showToast(
            msg: "Representative deleted successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          await _refreshData(); // Reload the page
        } else {
          Fluttertoast.showToast(
            msg: "Failed to delete representative: ${data['message']}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to delete representative",
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

  void _handleMenuAction(String action, Map<String, dynamic> employee) {
    switch (action) {
      case 'edit':
      // Implement edit functionality here
        print('Edit ${employee['name']}');
        break;
      case 'delete':
        _deleteEmployee(employee['id']);
        break;
    }
  }



  Future<void> _fetchEmployees() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('uniqueID');
    try {
      final url = 'http://52.66.145.37:3004/manager/get_Replist';
      final response = await http.post(

        Uri.parse(url),

        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'manager_id': int.parse(userID.toString())}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {

          setState(() {
            _employees = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Unknown error';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee List', style: text40016black),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: _employees.length,
          itemBuilder: (context, index) {
            final employee = _employees[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(employee['name']?.substring(0, 1) ?? '?'),
              ),
              title: Text(employee['name'] ?? 'No Name',
                  style: text50014black),
              subtitle: Text(employee['email'] ?? 'No Email',
                  style: text50012black),
              trailing: PopupMenuButton<String>(
                onSelected: (action) =>
                    _handleMenuAction(action, employee),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeDetailsPage(
                        employeeId: employee['id']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
