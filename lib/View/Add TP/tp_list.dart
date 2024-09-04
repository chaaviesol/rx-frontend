import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import '../../Util/Routes/routes_name.dart';
import '../../Util/Utils.dart';
import '../../app_colors.dart';
import '../../constants/styles.dart';
import '../../res/app_url.dart';
import '../homeView/home_view_rep.dart';

class ListTP extends StatefulWidget {
  const ListTP({super.key});

  @override
  State<ListTP> createState() => _ListTPState();
}

class _ListTPState extends State<ListTP> {
  Future<dynamic> gettplist() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    // Replace with your API endpoint URL
    var apiUrl = Uri.parse(AppUrl.list_tp);

    // Replace with your actual data payload
    var data = {
      "requesterId": uniqueID
    };

    try {
      var response = await http.post(
        apiUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Add any other headers as needed
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Successful API call
        print('API response: ${response.body}');
        return jsonDecode(response.body);
      } else {
        // Error in API call
        print('Failed to post data: ${response.statusCode}');
        throw Exception('Failed to post data');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Failed to connect to the server');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
          ),
        ],
        centerTitle: true,
        title: const Text(
          'My Requests',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: (){
          Navigator.pushNamed(context, RoutesName.addTp);
        },
        child: Icon(Icons.add,color: AppColors.whiteColor,),
      ),
      body: FutureBuilder(
          future: gettplist(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(),);
            } else if (snapshot.hasError) {
              return Center(child: Text('Some error occurred!'),);
            } else if (snapshot.hasData) {
              List<dynamic> dataList = snapshot.data!['data'];
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.5, color: AppColors.borderColor),
                                borderRadius: BorderRadius.circular(6)
                            ),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10,),
                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(6)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              height: 25, width: 25,
                              child: Image.asset('assets/icons/settings.png'),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: dataList.length + 1, // Add 1 for the white tile
                      itemBuilder: (context, index) {
                        if (index < dataList.length) {
                          var snapdata = dataList[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: ListTile(
                                title: Text('${snapdata['headquarters_date']['date']}'),
                                subtitle: Text('${snapdata['headquarters_date']['headquarters']}'),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    snapdata['accepted_by'] == null ? Text('Pending', style: text50010tcolor2,) : Text('Accepted', style: text50010tcolor2,),
                                    Text('${snapdata['amount'] ?? 'N/A'}'),
                                    // snapdata['accepted_by'] == null ? Icon(Icons.verified, color: Colors.grey,) : Icon(Icons.verified, color: Colors.green,)
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          // This is the white tile at the end
                          return Container(
                            height: 100, // Adjust height as needed
                            color: Colors.white,
                            child: Center(
                              child: Text(''),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            }
            return Center(child: Text('Some error occurred, please restart your application'),);
          }
      ),
    );
  }
}
