import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../constants/styles.dart';
import '../../../res/app_url.dart';
class ExpenseApprovalsWidgets{

 static TextEditingController searchController = TextEditingController();
  static Future<dynamic> getexpenserequests(String userID) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    String url = AppUrl.get_expense_request_rep;
    Map<String, dynamic> data = {
      "uniqueid":uniqueID,
      "searchData":searchController.text
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      print('body:${jsonEncode(data)}');
      print('st code :${response.statusCode}');
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print('resp data = ${responseData}');
        return responseData['data'];
      } else {
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  static Widget approved(String uniqueID) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5,color: AppColors.borderColor),
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
                      height: 25,width: 25,
                      child: Image.asset('assets/icons/settings.png')),
                ),
              )
            ],
          ),
          FutureBuilder(
            future: getexpenserequests(uniqueID),
            builder: (context,snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }else if(snapshot.hasError){
                return Center(child: Text('Some error occured !'),);
              }else if(snapshot.hasData){
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.where((item) => item['status'] == 'Accept').toList().length,
                      itemBuilder: (context,index) {
                        var snapdata = snapshot.data!.where((item) => item['status'] == 'Accept').toList();
                        return Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(radius: 5,backgroundColor: AppColors.primaryColor,),
                                          SizedBox(width: 10,),
                                          Text('#TRNX${snapdata[index]['id']}'),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 20.0),
                                        child: Text('${snapdata[index]['doctorDetails'][0]['doc_name']}',style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.borderColor,
                                            fontSize: 12)),
                                      ),
                                      // Padding(
                                      //   padding: EdgeInsets.only(left: 20.0),
                                      //   child: Text('${snapdata}',style: TextStyle(
                                      //       fontWeight: FontWeight.w400,
                                      //       color: AppColors.borderColor,
                                      //       fontSize: 12)),
                                      // ),
                                      SizedBox(height: 30,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.currency_rupee,size: 22,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 12.0),
                                                    child: Text('${snapdata[index]['amount']}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),
                                                  ),
                                                  Text('cash',style: TextStyle(
                                                      fontWeight: FontWeight.w400,
                                                      color: AppColors.borderColor,
                                                      fontSize: 12),),

                                                ],
                                              ),
                                            ],
                                          ),
                                          Text('${snapdata[index]['remark']}',style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.borderColor,
                                              fontSize: 12),),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                               Positioned(
                                right: 10,
                                top: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${Utils.getTime(snapdata[index]['created_date'].toString())}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
                                    Text('${Utils.formatDate(snapdata[index]['created_date'].toString())}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
                                  ],
                                ),
                              ),
                               Positioned(
                                right: 20,
                                top: 65,
                                child: Text('${snapdata[index]['status']}',style: text40016),
                              )
                            ],
                          ),
                        );
                      }
                  ),
                );
              }
              return Center(child: Text('Please restart your application'),);
            }
          )
        ],
      ),
    );
  }


  static Widget rejected(String uniqueID) {
    return  Padding(
      padding: EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5,color: AppColors.borderColor),
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
                      height: 25,width: 25,
                      child: Image.asset('assets/icons/settings.png')),
                ),
              )
            ],
          ),
          FutureBuilder(
              future: getexpenserequests(uniqueID),
              builder: (context,snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }else if(snapshot.hasError){
                  return Center(child: Text('Some error occured !'),);
                }else if(snapshot.hasData){
                  return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data!.where((item) => item['status'] == 'Rejected').toList().length,
                        itemBuilder: (context,index) {
                          var snapdata = snapshot.data!.where((item) => item['status'] == 'Rejected').toList();
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.textfiedlColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(radius: 5,backgroundColor: AppColors.primaryColor,),
                                            SizedBox(width: 10,),
                                            Text('#TRNX${snapdata[index]['id']}'),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 20.0),
                                          child: Text('${snapdata[index]['doctorDetails'][0]['doc_name']}',style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.borderColor,
                                              fontSize: 12)),
                                        ),
                                        // Padding(
                                        //   padding: EdgeInsets.only(left: 20.0),
                                        //   child: Text('Inna Fred',style: TextStyle(
                                        //       fontWeight: FontWeight.w400,
                                        //       color: AppColors.borderColor,
                                        //       fontSize: 12)),
                                        // ),
                                        SizedBox(height: 30,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.currency_rupee,size: 22,),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 12.0),
                                                      child: Text('${snapdata[index]['amount']}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),
                                                    ),
                                                    Text('cash',style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        color: AppColors.borderColor,
                                                        fontSize: 12),)
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${Utils.getTime(snapdata[index]['created_date'].toString())}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
                                      Text('${Utils.formatDate(snapdata[index]['created_date'].toString())}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  top: 65,
                                  child: Text('${snapdata[index]['status']}',style: text40016red),
                                )
                              ],
                            ),
                          );
                        }
                    ),
                  );
                }
                return Center(child: Text('Please restart your application'),);
              }
          )
        ],
      ),
    );
  }

  static Widget pending(String uniqueID) {
    return  Padding(
      padding: EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5,color: AppColors.borderColor),
                      borderRadius: BorderRadius.circular(6)
                  ),
                  child: TextFormField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onFieldSubmitted: (value){
                      searchController.text = value.toString();
                    },
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
                      height: 25,width: 25,
                      child: Image.asset('assets/icons/settings.png')),
                ),
              )
            ],
          ),
          FutureBuilder(
              future: getexpenserequests(uniqueID),
              builder: (context,snapshot) {
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator(),);
                }else if(snapshot.hasError){
                  return Center(child: Text('Some error occured !'),);
                }else if(snapshot.hasData){
                  return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data!.where((item) => item['status'] == 'Pending').toList().length,
                        itemBuilder: (context,index) {
                          var snapdata = snapshot.data!.where((item) => item['status'] == 'Pending').toList();
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.textfiedlColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(radius: 5,backgroundColor: AppColors.primaryColor,),
                                            SizedBox(width: 10,),
                                            Text('#TRNX${snapdata[index]['id']}'),
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 20.0),
                                          child: Text('${snapdata[index]['doctorDetails'][0]['doc_name']}',style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.borderColor,
                                              fontSize: 12)),
                                        ),

                                        SizedBox(height: 30,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.currency_rupee,size: 22,),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(top: 12.0),
                                                      child: Text('${snapdata[index]['amount']}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),
                                                    ),
                                                    Text('cash ',style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        color: AppColors.borderColor,
                                                        fontSize: 12),),
                                                    Text('${snapdata[index]['remark']}',style: TextStyle(
                                                        fontWeight: FontWeight.w400,
                                                        color: AppColors.borderColor,
                                                        fontSize: 12),),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 10,
                                  top: 10,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${Utils.getTime(snapdata[index]['created_date'].toString())}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
                                      Text('${Utils.formatDate(snapdata[index]['created_date'].toString())}',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 20,
                                  top: 65,
                                  child: Text('${snapdata[index]['status']}',style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16
                                  ),),
                                )
                              ],
                            ),
                          );
                        }
                    ),
                  );
                }
                return Center(child: Text('Please restart your application'),);
              }
          )
        ],
      ),
    );
  }


  static Widget ExpenseTile(){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.textfiedlColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 5,backgroundColor: AppColors.primaryColor,),
                      SizedBox(width: 10,),
                      Text('#TRNX781754'),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text('Sreya Alfrod',style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.borderColor,
                        fontSize: 12)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text('Inna Fred',style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.borderColor,
                        fontSize: 12)),
                  ),
                  SizedBox(height: 30,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.currency_rupee,size: 22,),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 12.0),
                                child: Text('50000',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 16),),
                              ),
                              Text('cash',style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.borderColor,
                                  fontSize: 12),),
                              Text('cash',style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.borderColor,
                                  fontSize: 12),),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            right: 10,
            top: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('10:00 AM',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
                Text('12-10-2024',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
              ],
            ),
          ),
          const Positioned(
            right: 20,
            top: 65,
            child: Text('APPROVED',style: TextStyle(
                color: AppColors.primaryColor3,
                fontWeight: FontWeight.w400,
                fontSize: 14
            ),),
          )
        ],
      ),
    );
  }
}