import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Util/Routes/routes_name.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../res/app_url.dart';
import '../home_view_rep.dart';
import 'doctor_details.dart';
import 'edit_doctor.dart';

class DoctorsListManager extends StatefulWidget {
  const DoctorsListManager({super.key});

  @override
  State<DoctorsListManager> createState() => _DoctorsListManagerState();
}

class _DoctorsListManagerState extends State<DoctorsListManager> {
  List<dynamic> list_of_doctors = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true; // To handle loading state
  bool _isSearching = false; // To handle searching state

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    getdoctors(); // Fetch the initial list of doctors
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

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
    String url = AppUrl.searchdoctors;
    Map<String, dynamic> data = {
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
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> deletedoctor(int doctorID) async {
    print('delete doctor called....');
    String url = AppUrl.delete_doctor; // Assuming there's a delete URL
    Map<String, dynamic> data = {
      "dr_id": doctorID
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
        print('delete success');
        var responseData = jsonDecode(response.body);
        Utils.snackBar('${responseData['message']}', context);
        getdoctors(); // Refresh the list after deletion
      } else {
        print('delete failed...');
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        throw Exception('Failed to load data (status code: ${response.statusCode})');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Doctors list', style: TextStyle(),),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor, // Replace with your desired color
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(onTap: () {
              Navigator.pop(context);
            },
                child: const Icon(Icons.arrow_back, color: Colors.white)), // Adjust icon color
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: (){
          Navigator.pushNamed(context, RoutesName.add_doctor);
        },
        child: Icon(Icons.add,color: AppColors.whiteColor,),
      ),
      body: RefreshIndicator(
        onRefresh: getdoctors,
        child: SafeArea(
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
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ListView.builder(
                          itemCount: list_of_doctors.length + 1, // Add 1 for the blank space
                          itemBuilder: (context, index) {
                            if (index < list_of_doctors.length) {
                              var doctor = list_of_doctors[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorDetails(doctorID: doctor['id']),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: getPastelColor(doctor['doc_name']),
                                    child: Text("${doctor['doc_name'][0]}"),
                                  ),
                                  title: Text(doctor['doc_name']),
                                  subtitle: Text(doctor['specialization']),
                                  trailing: PopupMenuButton<String>(
                                    color: AppColors.whiteColor,
                                    onSelected: (String result) async {
                                      if (result == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditDoctor(doctorID: doctor['id'].toString()),
                                          ),
                                        );
                                      } else if (result == 'delete') {
                                        await _showDeleteConfirmationDialog(context, doctor['doc_name'], doctor['id']);
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String doctorName, int doctorID)async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Doctor"),
          content: Text("Do you want to delete $doctorName from the list?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () async{
                print('pressed yes');
                await deletedoctor(doctorID);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
