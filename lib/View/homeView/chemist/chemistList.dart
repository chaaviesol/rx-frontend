import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../Util/Routes/routes_name.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../res/app_url.dart';
import '../home_view_rep.dart';
import 'edit_chemist.dart';

class Chemistlist extends StatefulWidget {
  const Chemistlist({super.key});

  @override
  State<Chemistlist> createState() => _ChemistlistState();
}

class _ChemistlistState extends State<Chemistlist> {
  List<dynamic> list_of_chemist = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true; // To handle loading state
  bool _isSearching = false; // To handle searching state

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    getchemists(); // Fetch the initial list of doctors
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<dynamic> getchemists() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueId = preferences.getString('uniqueID');
    String url = AppUrl.get_chemists;
    // Map<String, dynamic> data = {
    //   "rep_UniqueId": uniqueId
    // };

    try {
      final response = await http.get(
        Uri.parse(url),
      );
      // print('$data');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('chemist list : $responseData');
        setState(() {
          list_of_chemist = responseData['data'];
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

  Future<void> searchchemists() async {
    String url = AppUrl.search_chemists;
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
          list_of_chemist = responseData['data'];
          _isSearching = true;
        });
        if (responseData['data'].isEmpty) {
          getchemists();
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

  Future<void> deletechemists(int chemistID) async {
    print('delete chemists called....');
    String url = AppUrl.delete_chemists; // Assuming there's a delete URL
    Map<String, dynamic> data = {
      "chemist_id": int.parse(chemistID.toString())
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        print('delete success');
        var responseData = jsonDecode(response.body);
        // Navigator.pushNamedAndRemoveUntil(context, RoutesName.successsplash, (route) => false,);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        getchemists();
      } else {
        print('delete failed...');
        var responseData = jsonDecode(response.body);
        Utils.snackBar('${responseData['message']}', context);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }


  _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      getchemists();
    } else {
      searchchemists();
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
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color:AppColors.primaryColor, // Replace with your desired color
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(onTap: (){
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
        centerTitle: true,
        title: const Text(
          'Chemist List',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          onPressed: (){
            Navigator.pushNamed(context, RoutesName.add_chemist);
          },
          child: Icon(Icons.add,color: AppColors.whiteColor,),
        ),
      body: RefreshIndicator(
        onRefresh: getchemists,
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
                  child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(
                    itemCount: list_of_chemist.length,
                    itemBuilder: (context, index) {
                      var chemist = list_of_chemist[index];
                      print('chemist:$chemist');
                      return InkWell(
                        onTap: () {
                          // Navigator.push(context, MaterialPageRoute(
                          //   builder: (context) => DoctorDetails(doctorID: doctor['id']),
                          // ));
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getPastelColor(chemist['building_name']),
                            child: Text("${chemist['building_name'][0]}"),
                          ),
                          title: Text(chemist['building_name']),
                          subtitle: Text(chemist['address']),
                          trailing: PopupMenuButton<String>(
                            color: AppColors.whiteColor,
                            onSelected: (String result) async {
                              if (result == 'edit') {
                                print('Edit action');
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Edit_chemist(chemistId: chemist['id'],),));
                              } else if (result == 'delete') {
                                print('else if of delete');
                                await _showDeleteConfirmationDialog(context, chemist['building_name'], chemist['id']);
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
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
  Future<void> _showDeleteConfirmationDialog(BuildContext context, String doctorName, int chemistID)async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Chemist"),
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
                await deletechemists(chemistID);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
