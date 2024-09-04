import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../res/app_url.dart';
import '../Doctor/doctor_details.dart';

class HomesearchRep extends StatefulWidget {
  const HomesearchRep({super.key});

  @override
  State<HomesearchRep> createState() => _HomesearchRepState();
}

class _HomesearchRepState extends State<HomesearchRep> {

  final List<Color> pastelColors = [
    Color(0xFFB39DDB), // Light Purple
    Color(0xFF81D4FA), // Light Blue
    Color(0xFFAED581), // Light Green
    Color(0xFFFFF176), // Light Yellow
    Color(0xFFFFAB91), // Light Orange
    Color(0xFFE57373), // Light Red
    Color(0xFFFFF9C4), // Light Cream
    Color(0xFFD1C4E9), // Light Lavender
    Color(0xFFFFCDD2), // Light Pink
  ];
  Color getPastelColor(String name) {
    final int hash = name.codeUnits.fold(0, (int sum, int char) => sum + char);
    return pastelColors[hash % pastelColors.length];
  }

  List<dynamic> list_of_doctors = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = true; // To handle loading state
  bool _isSearching = false; // To handle searching state


  Future<void> getdoctors() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueId = preferences.getString('uniqueID');
    String url = AppUrl.getdoctors;
    Map<String, dynamic> data = {
      "rep_UniqueId": uniqueId
    };

    try {
      if (preferences.getString('uniqueID')!.isEmpty) {
        Utils.flushBarErrorMessage('Please login again!', context);
        return;
      }
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print('$data');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('doctors list : $responseData');
        setState(() {
          list_of_doctors = responseData['data'];
          _isLoading = false;
        });
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> searchdoctors() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueId = preferences.getString('uniqueID');
    String url = AppUrl.searchdoctors;
    Map<String, dynamic> data = {
      "requesterUniqueId":uniqueId,
      "searchData": _searchController.text
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
        print('filtered list : $responseData');
        setState(() {
          list_of_doctors = responseData['data'];
          _isSearching = true;
        });
        if (responseData['data'].isEmpty) {
          getdoctors();
        }
      } else {
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      getdoctors();
    } else {
      searchdoctors();
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    getdoctors(); // Fetch the initial list of doctors
    WidgetsBinding.instance.addPostFrameCallback((_){
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
            ),
          ),
        ),
      ),
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
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextFormField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
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
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(
                        itemCount: list_of_doctors.length,
                        itemBuilder: (context, index) {
                          // return Text('${list_of_doctors[0]['addedBy_']}');
                          var doctor = list_of_doctors[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => DoctorDetails(doctorID: doctor['id']),
                              ));
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: getPastelColor(doctor['doc_name']),
                                child: Text("${doctor['doc_name'][0]}"),
                              ),
                              title: Text(doctor['doc_name']),
                              subtitle: Text(doctor['specialization']),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
