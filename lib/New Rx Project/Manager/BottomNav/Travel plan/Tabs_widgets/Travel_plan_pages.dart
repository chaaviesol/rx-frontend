import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/AutoTP/autoTP.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Manual/ManualTP.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/New_tp.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Tabs_widgets/Travel_plan_pages2.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Tabs_widgets/viewTP.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../Util/Utils.dart';
import '../../../../../app_colors.dart';
import '../../../../../constants/styles.dart';
import '../../My lists/Doctor_details/doctor_detials.dart';
import '../Manual/NewManualTP.dart';

class TravelPlanmainpage extends StatefulWidget {
  const TravelPlanmainpage({Key? key}) : super(key: key);

  @override
  State<TravelPlanmainpage> createState() => _TravelPlanmainpageState();
}

class _TravelPlanmainpageState extends State<TravelPlanmainpage> {
  List travelPlans = [];

  Future<void> gettravelplans() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int userId = int.parse(preferences.getString('userID').toString());
    final url = Uri.parse(AppUrl.getTravelPlans);
    var data = {
      'userId': userId,
    };
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Parse the response body
        final decodedResponse = jsonDecode(response.body);

        setState(() {
          travelPlans = decodedResponse['data']; // Assuming 'data' is where your travel plans are
          print('${travelPlans}');
        });

        print('get response : ${response.body}');
      } else {
        // Handle error
        print('Failed to fetch travel plans: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to fetch travel plans');
    }
  }

  Map<String, int> monthNames = {
    'January': 1,
    'February': 2,
    'March': 3,
    'April': 4,
    'May': 5,
    'June': 6,
    'July': 7,
    'August': 8,
    'September': 9,
    'October': 10,
    'November': 11,
    'December': 12,
  };

//generate TP
  Future<dynamic> sendPostRequest(String userId, String month) async {
    final Uri url = Uri.parse(AppUrl.generateautoTP); // Replace with your API URL

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'month': month,
      }),
    );
    print('body is:${jsonEncode({
      'userId': userId,
      'month': month,
    })}');
    print('auto tp is called .. wiht st code :${response.statusCode}');
    print('respon:${response.body}');
    if (response.statusCode == 200) {
      // Successful response
      var responseData = jsonDecode(response.body);
      Utils.flushBarErrorMessage('${responseData['message']}', context);
      // Utils.flushBarErrorMessage('${responseData['data']['message']}', context);
      // Navigator.push(context, MaterialPageRoute(builder: (context) => Autotp(data: responseData['data']['data'],),));
      // Utils.flushBarErrorMessage('${responseData['data']['message']}', context);
      print('Response data: ${response.body}');
      print('Response datas: ${responseData['data']['data']}');
      return responseData['data'];
      // Handle successful response here
    } else {
      var responseData = jsonDecode(response.body);
      Utils.flushBarErrorMessage('${responseData['data']['message']}', context);
      // Error response
      print('Error: ${response.statusCode}');
      print('Error details: ${response.body}');
      // Handle error response here
    }
  }

  Future<void> _selectMonthAndGenerateTP() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueId = preferences.getString('uniqueID');

    final selectedMonth = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners for the dialog
          ),
          title: Center(
            child: Text(
              'Select a Month',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor, // Stylish title color
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height / 2,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Number of columns
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10, // Spacing between tiles
                  childAspectRatio: 1, // Make the tiles square
                ),
                itemCount: monthNames.length,
                itemBuilder: (context, index) {
                  final monthName = monthNames.keys.elementAt(index);
                  final monthNumber = monthNames[monthName]!;
                  final currentMonth = DateTime.now().month;
                  final isPastMonth = monthNumber < currentMonth; // Condition for past months

                  return GestureDetector(
                    onTap: isPastMonth
                        ? null // Disable onTap for past months
                        : ()async {
                      final formattedMonth = '$monthNumber-${DateTime.now().year}';
                      if (formattedMonth != null) {
                        // _showLoaderDialog(context); // Show loader dialog

                        try {
                          // Call your API request here
                          var data = await sendPostRequest('${uniqueId}', formattedMonth);
                          print('auto data: $data');

                          // Ensure the response data is valid before navigating
                          if (data != null) {
                            // Navigate to the Autotp page
                            print('sending data to next page :${data['data']}');
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Autotp(
                              selectedMonth:formattedMonth,
                              data: data['data'],),),
                            );

                            // Optionally show success message after navigation
                            Flushbar(
                              message: "Travel plan generated successfully for $formattedMonth!",
                              icon: Icon(
                                Icons.check_circle,
                                size: 28.0,
                                color: Colors.green,
                              ),
                              duration: Duration(seconds: 3),
                              leftBarIndicatorColor: Colors.green,
                            ).show(context);
                          } else {
                            throw Exception("No data returned from the API");
                          }
                        } catch (e) {
                          // Dismiss the loader in case of an error
                          // Navigator.of(context).pop(); // Close the loader dialog

                          // Show error message
                          Flushbar(
                            message: "Error generating travel plan. Please try again.",
                            icon: Icon(
                              Icons.error,
                              size: 28.0,
                              color: Colors.red,
                            ),
                            duration: Duration(seconds: 3),
                            leftBarIndicatorColor: Colors.red,
                          ).show(context);
                        }
                      }else{
                        Utils.flushBarErrorMessage2('Some error occured !', context);
                      }
                    },
                    child: Opacity(
                      opacity: isPastMonth ? 0.5 : 1, // Reduce opacity for past months
                      child: Container(
                        decoration: BoxDecoration(
                          color: isPastMonth ? Colors.grey : AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(4, 4), // Shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month_sharp,
                              size: 15,
                              color: Colors.white, // Calendar icon
                            ),
                            SizedBox(height: 8),
                            Text(
                              monthName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Month text color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );



  }


// Function to show a loader dialog
  void _showLoaderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by clicking outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Generating travel plan..."),
              ],
            ),
          ),
        );
      },
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    gettravelplans();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation:FloatingActionButtonLocation.startTop,
      floatingActionButton:Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            // onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) => Newmanualtp(),)),
            onPressed: () => Navigator.push(context,MaterialPageRoute(builder: (context) => Manualtp(),)),
            child: Text(
              'Manual TP',
              style: TextStyle(color: AppColors.whiteColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,),
            onPressed: _selectMonthAndGenerateTP,
            child: Text(
              'Auto Generate TP',
              style: TextStyle(color: AppColors.whiteColor),
            ),
          ),
        ],
      ) ,
      body: SafeArea(
        child:travelPlans.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50,),
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Number of columns
                    crossAxisSpacing: 8.0, // Horizontal space between containers
                    mainAxisSpacing: 8.0, // Vertical space between containers
                    childAspectRatio: 160 / 150, // Adjust the ratio based on width and height of your container
                  ),
                  shrinkWrap: true, // To prevent GridView from expanding infinitely
                  physics: NeverScrollableScrollPhysics(), // Disable scroll if it's within a scrollable parent
                  itemCount: travelPlans.length,
                  itemBuilder: (context, index) {
                    String monthName = Utils.getMonthName(travelPlans[index]['month']);
                    String year = DateFormat('yyyy').format(DateTime.parse(travelPlans[index]['created_date']));
                    return InkWell(
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => Viewtp(
                        //   tpid: travelPlans[index]['id'],
                        //     tp_status: travelPlans[index]['status'],
                        //     monthandyear: '${monthName} ${year}',
                        // ),));
                        // Handle the tap event
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TravelPlanPages2(
                          tpid: travelPlans[index]['id'],
                          tp_status: travelPlans[index]['status'],
                          monthandyear: '${monthName} ${year}',
                        )));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.textfiedlColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 20,
                              right: 0,
                              child: ClipPath(
                                clipper: MyCustomClipper(),
                                child: Container(
                                  width: 100,
                                  color: travelPlans[index]['status'] == 'Approved'
                                      ? Colors.green
                                      : travelPlans[index]['status'] == 'Submitted'
                                      ? AppColors.primaryColor2
                                      : AppColors.primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        '   ${travelPlans[index]['status']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text("${monthName+year}",
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Travel Plan ${travelPlans.length-index}',
                                    style: TextStyle(color: AppColors.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 100), // Add space at the end of the tile list
              ],
            ),
          ),
        )
            : Center(child: Text('No Travel Plans Yet ! Create One.'))
      ),
    );
  }
}
