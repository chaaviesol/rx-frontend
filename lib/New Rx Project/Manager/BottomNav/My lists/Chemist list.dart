import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rx_route_new/constants/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChemistList extends StatefulWidget {
  const ChemistList({super.key});

  @override
  State<ChemistList> createState() => _ChemistListState();
}

class _ChemistListState extends State<ChemistList> {
  List<Map<String, dynamic>> _chemists = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchChemists();
  }

  Future<void> _refreshData() async {
    await _fetchChemists(); // Refresh data
  }

  Future<void> _deleteChemist(int chemistId) async {
    try {
      final response = await http.post(
        Uri.parse('http://52.66.145.37:3004/rep/delete_chemist'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'chemist_id': chemistId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          Fluttertoast.showToast(
            msg: "Chemist deleted successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          await _refreshData(); // Reload the list
        } else {
          Fluttertoast.showToast(
            msg: "Failed to delete chemist: ${data['message']}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to delete chemist",
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

  Future<void> _fetchChemists() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    var requestData = {
      "userId": uniqueID
    };
    final url = 'http://52.66.145.37:3004/user/addedChemist';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(requestData),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          List<Map<String, dynamic>> parsedChemists = [];

          // Flatten the data list, extracting each chemist entry
          for (var chemistList in responseData['data']) {
            for (var chemist in chemistList) {
              parsedChemists.add(chemist);
            }
          }

          setState(() {
            _chemists = parsedChemists;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = responseData['message'];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load data';
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


  void _handleMenuAction(String action, dynamic chemist) {
    switch (action) {
      case 'edit':
      // Implement edit functionality here
        print('Edit ${chemist['building_name']}');
        break;
      case 'delete':
        _deleteChemist(chemist['id']);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage))
            : ListView.builder(
          itemCount: _chemists.length,
          itemBuilder: (context, index) {
            final chemist = _chemists[index];
            print('chemist list is:$_chemists');
            return ListTile(
              // title: Text(chemist['building_name'] ?? 'No Building Name',style: text50014black,),
              title: Text(chemist['chemist'][0]['address'] ?? 'No Building Name',style: text50014black,),
              // subtitle: Text(chemist['address'] ?? 'No Address',style: text50012black,),
              subtitle: Text(chemist['chemist'][0]['pincode'] ?? 'No Address',style: text50012black,),
              trailing: PopupMenuButton<String>(
                onSelected: (action) => _handleMenuAction(action, chemist),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: const [
                          Icon(Icons.edit,),
                          SizedBox(width: 10),
                          Text('Edit',style: text50012black,),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: const [
                          Icon(Icons.delete),
                          SizedBox(width: 10),
                          Text('Delete',style: text50012black,),
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
