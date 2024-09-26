
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rx_route_new/View/homeView/chemist/edit_chemist.dart';
import 'package:rx_route_new/constants/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../res/app_url.dart';

class ChemistList extends StatefulWidget {
  const ChemistList({Key? key}) : super(key: key);

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
        Uri.parse(AppUrl.delete_chemists),
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
          _showToast("Failed to delete chemist: ${data['message']}");
        }
      } else {
        _showToast("Failed to delete chemist");
      }
    } catch (e) {
      _showToast("An error occurred: $e");
    }
  }

  Future<void> _fetchChemists() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');

    final response = await http.post(
      Uri.parse(AppUrl.get_chemists),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uniqueId': uniqueID}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          _chemists = List<Map<String, dynamic>>.from(data['data']);
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
        _errorMessage = 'Failed to load data: ${response.statusCode}';
        _isLoading = false;
      });
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleMenuAction(String action, dynamic chemist) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Edit_chemist(chemistId: chemist['id']),
          ),
        );
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
            return ListTile(
              title: Text(
                chemist['building_name'] ?? 'No Building Name',
                style: text50014black,
              ),
              subtitle: Text(
                chemist['address'] ?? 'No Address',
                style: text50012black,
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (action) => _handleMenuAction(action, chemist),
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