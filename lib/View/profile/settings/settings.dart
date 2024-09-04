import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../constants/styles.dart';
import '../../../res/app_url.dart';
import 'change_language.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool isPushNotificationOn = false;

   Future<dynamic> getUserDetails() async {
     SharedPreferences preferences = await SharedPreferences.getInstance();
     String? uniqueID = preferences.getString('uniqueID');
    Map<String, dynamic> data = {
      "uniqueId":uniqueID
    };
    String url = AppUrl.single_employee_details;
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
        return responseData;
      } else {
        throw Exception('Failed to post data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    var pre = Utils.getuser();
    print(pre);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: (){
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
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: Text('Version ${Utils.appversion}'),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: FutureBuilder(
          future: getUserDetails(),
          builder: (context,snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }else if(snapshot.hasError){
              return Center(child: Text('Some error occured !'),);
            }else if(snapshot.hasData){
              var snapdata = snapshot.data['data'][0];
              return Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      SizedBox(width: 20,),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryColor,
                        child: Text('${snapdata['name'][0].toString().toUpperCase()}',style: text90048,),
                      ),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${snapdata['name'].toString().toUpperCase()}',style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),),
                          SizedBox(height: 10,),
                          Text('${snapdata['designation'].toString().toUpperCase()}',style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),),
                          SizedBox(height: 10,),
                          Text('${snapdata['mobile']}',style: TextStyle(
                            color: Color.fromRGBO(143, 143, 143, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),),
                          SizedBox(height: 10,),
                          Text('${snapdata['email']}',style: TextStyle(
                            color: Color.fromRGBO(143, 143, 143, 1),
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0,right: 20),
                    child: Divider(),
                  ),
                  ListTile(
                    leading: const Text(
                      'Push notification',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Switch(
                      value: isPushNotificationOn,
                      onChanged: (value) {
                        setState(() {
                          isPushNotificationOn = value;
                        });
                      },
                      activeColor: AppColors.whiteColor,
                      activeTrackColor: AppColors.primaryColor,
                      inactiveThumbColor: AppColors.whiteColor,
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeLanguage(),));
                    },
                    child: ListTile(
                      leading: const Text('Language',style: TextStyle(
                        fontSize:   14,
                        fontWeight: FontWeight.w600,
                      ),),
                      trailing:Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.arrow_forward, color: AppColors.whiteColor),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Text('Search history',style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                    ),),
                    trailing:Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.arrow_forward, color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Text('Change Password',style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                    ),),
                    trailing:Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.arrow_forward, color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Text('Logout',style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                    ),),
                    trailing:Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.arrow_forward, color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(child: Text('Some error occured ! , Please restart your application !'),);

          }
        ),
      ),
    );
  }
}
