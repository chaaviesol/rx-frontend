import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Util/Routes/routes_name.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../res/app_url.dart';
import '../home_view_rep.dart';
import 'add_rep.dart';
import 'edit_emp.dart';
import 'emp_details.dart';

class EmpList extends StatefulWidget {
  const EmpList({super.key});

  @override
  State<EmpList> createState() => _EmpListState();
}

class _EmpListState extends State<EmpList> {
  List<dynamic> employeesList = [];

  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true; // To handle loading state
  bool _isSearching = false; // To handle searching state

  Future<void> getemployees() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    print('user ID is :$userID');
    String url = AppUrl.get_employee;
    Map<String, dynamic> data = {
      "manager_id": int.parse(userID.toString())
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print(userID);
      print(response.body);
      print('st:${response.statusCode}');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('employee list : $responseData');
        setState(() {
          employeesList = responseData['data'];
          _isLoading = false;
        });
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> deleteemployee(String empID) async {
    String url = AppUrl.delete_employee;
    Map<String, dynamic> data = {
      "userId": int.parse(empID.toString())
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print('Status code :${response.statusCode}');
      if (response.statusCode == 200) {
        var responsedata = jsonDecode(response.body);
        if (responsedata['success'] == true) {
          // Successfully deleted
          Navigator.pushNamed(context, RoutesName.successsplash);
          Utils.flushBarErrorMessage('${responsedata['message']}', context);
          getemployees();  // Refresh the employee list
        } else {
          // Failed to delete
          Utils.flushBarErrorMessage('${responsedata['message']}', context);
        }
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        throw Exception('Failed to delete (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }


  Future<void> searchemployee() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    String url = AppUrl.search_employee;
    Map<String, dynamic> data = {
      "searchName": _searchController.text,
      "created_by": int.parse(userID.toString())
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
        print('search response:${jsonDecode(response.body)}');
        var responseData = jsonDecode(response.body);
        print('filtered list : $responseData');
        setState(() {
          employeesList = responseData['data'];
          _isSearching = true;
          print('filtered data :$employeesList');
        });
        if (responseData['data'].isEmpty) {
          getemployees();
        }
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    getemployees(); // Fetch the initial list of employees
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      getemployees();
    } else {
      searchemployee();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.5, color: AppColors.borderColor),
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: TextFormField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(6)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                          height: 25, width: 25,
                          child: Image.asset('assets/icons/settings.png')
                      ),
                    ),
                  )
                ],
              ),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: employeesList.length + 1, // Add 1 for the blank space
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (index < employeesList.length) {
                      var employee = employeesList[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            print('emp data:$employee');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmpDetails(
                                  empID: employee['id'],
                                  uniqueID: employee['uniqueId'],
                                  phone: employee['mobile'],
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${employee['name'][0]}'),
                            ),
                            title: Text('${employee['name']}'),
                            subtitle: Text('${employee['email']}'),
                            trailing: PopupMenuButton<String>(
                              color: AppColors.whiteColor,
                              onSelected: (String result) {
                                if (result == 'edit') {
                                  print('Edit action');
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EditRep(uniqueID: employee['uniqueId'], userID: employee['id'],),));
                                } else if (result == 'delete') {
                                  _showDeleteConfirmationDialog(context, '${employee['name']}', '${employee['id']}');
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Return a blank container as the last item
                      return Container(
                        height: 100, // Adjust height as needed
                        color: Colors.white,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String employeeName, String empID) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Employee"),
          content: Text("Do you want to delete $employeeName from the list?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () async {
                await deleteemployee(empID);
              },
            ),
          ],
        );
      },
    );
  }
}
