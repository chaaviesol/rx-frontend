import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/My%20lists/Doctor_details/doctor_detials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../res/app_url.dart';

class HomesearchRep extends StatefulWidget {
  String? searachString;
  HomesearchRep({this.searachString, super.key});

  @override
  State<HomesearchRep> createState() => _HomesearchRepState();
}

class _HomesearchRepState extends State<HomesearchRep> {
  List<dynamic> list_of_doctors = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = true;
  bool _isSearching = false;

  Future<void> getdoctors() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueId = preferences.getString('uniqueID');
    String url = AppUrl.getdoctors;
    Map<String, dynamic> data = {
      "rep_UniqueId": uniqueId,
    };

    try {
      if (uniqueId == null || uniqueId.isEmpty) {
        Utils.flushBarErrorMessage('Please login again!', context);
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Full Doctor List: ${responseData['data']}');

        setState(() {
          list_of_doctors = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        setState(() {
          list_of_doctors = [];
          _isLoading = false;
        });
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
      "requesterUniqueId": uniqueId,
      "searchData": _searchController.text,
    };

    try {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('Search Results: ${responseData['data']}');

        setState(() {
          list_of_doctors = responseData['data'] ?? [];
          _isLoading = false;
          _isSearching = true;
        });
      } else {
        setState(() {
          _isLoading = false;
          list_of_doctors = [];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
    print('Search String: ${widget.searachString}');
    _searchController.text = widget.searachString ?? '';
    _searchController.addListener(_onSearchChanged);
    getdoctors();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
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
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : list_of_doctors.isEmpty
                    ? Center(child: Text("No doctors found"))
                    : ListView.builder(
                  itemCount: list_of_doctors.length,
                  itemBuilder: (context, index) {
                    var doctor = list_of_doctors[index];
                    String firstName = doctor['firstName'] + doctor['lastName'] ?? 'Unknown';
                    String spec = doctor['specialization'] ?? 'Unknown';
                    Color avatarColor = list_of_doctors[index]['visit_type'] == 'core'
                        ? AppColors.tilecolor2
                        : list_of_doctors[index]['visit_type'] == 'supercore'
                        ? AppColors.tilecolor1
                        : AppColors.tilecolor3;

                    String avatarLetter = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorDetailsPage(doctorId: doctor['id']),));
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: avatarColor,
                          child: Text(avatarLetter),
                        ),
                        title: Text(firstName),
                        subtitle: Text(spec),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
