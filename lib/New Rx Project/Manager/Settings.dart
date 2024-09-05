import 'package:flutter/material.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/Login%20page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../app_colors.dart';
import '../../constants/styles.dart';
import '../../res/app_url.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String name = '';
  String qualification = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    final response = await http.post(
      Uri.parse(AppUrl.single_employee_details),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"uniqueId": uniqueID}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        name = data['name'];
        qualification = data['qualification'];
        email = data['email'];
      });
    } else {
      // Handle errors
      print('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        centerTitle: true,
        title: Text(
          'Settings',
          style: text40016black,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      color: AppColors.primaryColor,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height / 5.5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              child: Text(name.isNotEmpty ? name[0] : 'A'),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.isNotEmpty ? name : 'Manager',
                                  style: text60017,
                                ),
                                Text(qualification.isNotEmpty ? qualification : 'Qualification', style: text40012),
                                Text(email.isNotEmpty ? email : 'email@example.com', style: text40012),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildListTile(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      // Handle Edit Profile action
                    },
                  ),
                  _buildListTile(
                    icon: Icons.notifications,
                    title: 'Notification',
                    onTap: () {
                      // Handle Notification action
                    },
                  ),
                  _buildListTile(
                    icon: Icons.lock,
                    title: 'Reset Password',
                    onTap: () {
                      // Handle Reset Password action
                    },
                  ),
                  _buildListTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPageNew(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            child: Icon(icon, color: AppColors.primaryColor),
            backgroundColor: Colors.grey[200],
          ),
          title: Text(
            title,
            style: text60017black,
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.primaryColor,
          ),
          onTap: onTap,
        ),
        Divider(
          color: Colors.grey[300],
          thickness: 1,
        ),
      ],
    );
  }
}
