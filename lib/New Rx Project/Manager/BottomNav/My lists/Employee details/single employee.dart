import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/res/app_url.dart';

import '../../../../../app_colors.dart';
import '../../../../../constants/styles.dart';

class EmployeeDetailsPage extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailsPage({required this.employeeId, Key? key})
      : super(key: key);

  @override
  _EmployeeDetailsPageState createState() => _EmployeeDetailsPageState();
}

class _EmployeeDetailsPageState extends State<EmployeeDetailsPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _employeeDetails;
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;
  late TabController _taggedTabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _taggedTabController = TabController(length: 2, vsync: this);
    _fetchEmployeeDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taggedTabController.dispose();
    super.dispose();
  }

  // Future<void> _fetchEmployeeDetails() async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(AppUrl.single_employee_details),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'uniqueId': widget.employeeId}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       if (data['success']) {
  //         setState(() {
  //           _employeeDetails = data['data'];
  //           _isLoading = false;
  //         });
  //       } else {
  //         setState(() {
  //           _errorMessage = data['message'];
  //           _isLoading = false;
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         _errorMessage = 'Failed to load employee details';
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _errorMessage = 'An error occurred: $e';
  //       _isLoading = false;
  //     });
  //   }
  // }

  Future<void> _fetchEmployeeDetails() async {
    try {
      final response = await http.post(
        Uri.parse(AppUrl.single_employee_details),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uniqueId': widget.employeeId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _employeeDetails = data['data'];
            _isLoading = false;
          });
        } else {
          // Even though the success flag is false, you still received data
          if (data['data'] != null) {
            setState(() {
              _employeeDetails = data['data'];
              _errorMessage = 'Received data, but with a failed status';
              _isLoading = false;
            });
          } else {
            setState(() {
              _errorMessage = data['message'] ?? 'Unknown error';
              _isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load employee details: ${response.statusCode}';
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
        backgroundColor: AppColors.whiteColor,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.primaryColor,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Employee Details',
          style: text40016black,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: AppColors.primaryColor,
                  width: double.infinity,
                  height:
                  MediaQuery.of(context).size.height / 5.5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          child: Text(_employeeDetails?['name'][0] ??
                              ''),
                        ),
                        const SizedBox(width: 20),
                        Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_employeeDetails!['name']}',
                              style: text60017,
                            ),
                            Text(
                                '${_employeeDetails!['designation']}',
                                style: text40012),
                            Text(
                                '${_employeeDetails!['qualification']}',
                                style: text40012),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Details'),
                  Tab(text: 'Address'),
                  Tab(text: 'Tagged'),
                  Tab(text: 'Another Tab'),
                ],
                labelColor: AppColors.primaryColor,
                indicatorColor: AppColors.primaryColor,
                unselectedLabelColor: AppColors.primaryColor,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(),
                    _buildAddressTab(),
                    _buildTaggedTab(),
                    _buildAnotherTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mobile: ${_employeeDetails?['mobile'] ?? 'N/A'}',
              style: text50014black),
          Text('Gender: ${_employeeDetails?['gender'] ?? 'N/A'}',
              style: text50014black),
          Text('Date of Birth: ${_employeeDetails?['date_of_birth'] ?? 'N/A'}',
              style: text50014black),
          Text('Joining Date: ${_employeeDetails?['joining_date'] ?? 'N/A'}',
              style: text50014black),
        ],
      ),
    );
  }

  Widget _buildAddressTab() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Address: ${_employeeDetails?['address'] ?? 'N/A'}',
              style: text50014black),
        ],
      ),
    );
  }

  Widget _buildTaggedTab() {
    return Column(
      children: [
        TabBar(
          controller: _taggedTabController,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Chemist'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _taggedTabController,
            children: [
              Center(child: Text('Products tagged to this employee')),
              Center(child: Text('Chemists tagged to this employee')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnotherTab() {
    return const Center(child: Text('Another Tab Content'));
  }
}
