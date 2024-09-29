
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app_colors.dart';

class Myreports extends StatefulWidget {
  @override
  _MyreportsState createState() => _MyreportsState();
}

class _MyreportsState extends State<Myreports> {
  String _selectedMonth = "01"; // Default selected month
  int _selectedYear = 2024; // Default selected year
  List<dynamic> _performanceData = [];
  bool _isLoading = false; // Loading state

  List<int> years = [2024, 2025, 2026, 2027, 2028, 2029, 2030];

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
  }

  Future<void> _fetchPerformanceData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    setState(() {
      _isLoading = true; // Set loading state
    });

    final response = await http.post(
      Uri.parse(AppUrl.userPerformance),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "requesterUniqueId": uniqueID,
        "month": _selectedMonth,
        "year": _selectedYear,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _performanceData = data['data'].map((entry) {
            return {
              'total_visits': entry['total_visits'],
              'visited': entry['visited'],
              'balance_visit': entry['balance_visit'],
              'doctorName': entry['doctorDetails'][0]['firstName'] + ' ' +
                  entry['doctorDetails'][0]['lastName'],
              'dateTime': entry['dateTime'],
              // Added date
              'specialization': entry['doctorDetails'][0]['specialization'],
              // Added specialization
              'qualification': entry['doctorDetails'][0]['doc_qualification'],
              // Added qualification
            };
          }).toList();

          if (_performanceData.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(
                  'No performance data available for selected month and year')),
            );
          }
        });
      }
    } else {
      setState(() {
        _performanceData = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load performance data')),
      );
    }

    setState(() {
      _isLoading = false; // Reset loading state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MY Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildPerformanceHeaderWithDropdown(),
            _buildDoctorTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceHeaderWithDropdown() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStyledDropdown(
            value: _selectedMonth,
            items: [
              DropdownMenuItem(child: Text("January"), value: "01"),
              DropdownMenuItem(child: Text("February"), value: "02"),
              DropdownMenuItem(child: Text("March"), value: "03"),
              DropdownMenuItem(child: Text("April"), value: "04"),
              DropdownMenuItem(child: Text("May"), value: "05"),
              DropdownMenuItem(child: Text("June"), value: "06"),
              DropdownMenuItem(child: Text("July"), value: "07"),
              DropdownMenuItem(child: Text("August"), value: "08"),
              DropdownMenuItem(child: Text("September"), value: "09"),
              DropdownMenuItem(child: Text("October"), value: "10"),
              DropdownMenuItem(child: Text("November"), value: "11"),
              DropdownMenuItem(child: Text("December"), value: "12"),
            ],
            onChanged: (value) {
              setState(() {
                _selectedMonth = value!;
                _fetchPerformanceData(); // Fetch data for the selected month
              });
            },
          ),
          _buildYearDropdown(), // Year dropdown
        ],
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButton<int>(
        value: _selectedYear,
        items: years.map<DropdownMenuItem<int>>((int year) {
          return DropdownMenuItem<int>(
            value: year,
            child: Text(year.toString()),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedYear = value!;
            _fetchPerformanceData(); // Fetch data for the selected year
          });
        },
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDoctorTable() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: _performanceData.isEmpty
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No data available for the selected month and year.',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        )
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Allow horizontal scroll if needed
          child: Column(
            children: [
              _buildTableHeaders(),
              Divider(),
              ..._performanceData.map<Widget>((data) {
                return Column(
                  children: [
                    _buildDoctorRow(data),
                    Divider(),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeaders() {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(150), // Width for "Doctor Name"
        1: FixedColumnWidth(80), // Width for "Total Visits"
        2: FixedColumnWidth(80), // Width for "Visited"
        3: FixedColumnWidth(100), // Width for "Pending Calls"
        4: FixedColumnWidth(150), // Width for "Specialization"
        5: FixedColumnWidth(100), // Width for "Qualification"
      },
      border: TableBorder(
        bottom: BorderSide(color: Colors.grey),
      ),
      children: [
        TableRow(
          children: [
            _buildTableHeader('Doctor Name'),
            _buildTableHeader('Total Visits'),
            _buildTableHeader('Visited'),
            _buildTableHeader('Pending Calls'),
            _buildTableHeader('Specialization'),
            _buildTableHeader('Qualification'),
          ],
        ),
      ],
    );
  }

  Widget _buildDoctorRow(Map<String, dynamic> data) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(150),
        1: FixedColumnWidth(80),
        2: FixedColumnWidth(80),
        3: FixedColumnWidth(100),
        4: FixedColumnWidth(150),
        5: FixedColumnWidth(100),
      },
      children: [
        TableRow(
          children: [
            _buildTableCell(data['doctorName'].toString(), color: Colors.blue),
            // Blue for Doctor Name
            _buildTableCell(
                data['total_visits'].toString(), color: Colors.purple),
            // Violet for Total Visits
            _buildTableCell(
                data['visited']?.toString() ?? '0', color: Colors.green),
            // Green for Visited
            _buildTableCell(
                data['balance_visit']?.toString() ?? '0', color: Colors.red),
            // Red for Pending Calls
            _buildTableCell(data['specialization'].toString()),
            _buildTableCell(data['qualification'].toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black, // Black color for header
        ),
      ),
    );
  }

  Widget _buildTableCell(String data, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        data,
        style: TextStyle(
          color: color ??
              Colors.black87, // Apply specific color or default to black
        ),
        overflow: TextOverflow.ellipsis, // Handle text overflow
      ),
    );
  }
}