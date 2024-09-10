import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/AutoTP/autoTP.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Manual/ManualTP.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/New_tp.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Tabs_widgets/Travel_plan_pages2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../Util/Utils.dart';
import '../../../../../app_colors.dart';
import '../../../../../constants/styles.dart';

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
    final url = Uri.parse("http://52.66.145.37:3004/user/userAddedTP");
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

  Map<String, String> monthNames = {
    'January': '01',
    'February': '02',
    'March': '03',
    'April': '04',
    'May': '05',
    'June': '06',
    'July': '07',
    'August': '08',
    'September': '09',
    'October': '10',
    'November': '11',
    'December': '12',
  };

  Future<dynamic> sendPostRequest(String userId, String month) async {
    final Uri url = Uri.parse('http://52.66.145.37:3004/generate-visit-plan'); // Replace with your API URL

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
      Navigator.push(context, MaterialPageRoute(builder: (context) => Autotp(data: '${responseData}',),));
      Utils.flushBarErrorMessage('${responseData['data']['message']}', context);
      print('Response data: ${response.body}');
      return responseData;
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
                  return GestureDetector(
                    onTap: () {
                      final monthNumber = monthNames[monthName];
                      final formattedMonth = '$monthNumber-${DateTime.now().year}';
                      Navigator.of(context).pop(formattedMonth); // Pass the selected month
                    },
                    child: Container(
                      decoration: BoxDecoration(
                       color: AppColors.primaryColor,
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
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (selectedMonth != null) {
      // _showLoaderDialog(context); // Show loader dialog

      try {
        var data = await sendPostRequest('${uniqueId}', selectedMonth); // Call your API request here
        print('auto data :$data');
        // Wait a moment to ensure the loader is properly dismissed before showing Flushbar
        await Future.delayed(Duration(milliseconds: 200));

        // Dismiss loader
        Navigator.of(context).pop(); // Close the loader dialog
        // Show success message and return to the previous page
        Flushbar(
          message: "Travel plan generated successfully for $selectedMonth!",
          icon: Icon(
            Icons.check_circle,
            size: 28.0,
            color: Colors.green,
          ),
          duration: Duration(seconds: 3),
          leftBarIndicatorColor: Colors.green,
        );
      } catch (e) {
        // Dismiss loader
        Navigator.of(context).pop(); // Close the loader dialog
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
    }
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
                Wrap(
                  spacing: 8.0, // Horizontal space between containers
                  runSpacing: 8.0, // Vertical space between containers
                  children: List.generate(travelPlans.length, (index) {
                    return InkWell(
                      onTap: () {
                        // Handle the tap event
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TravelPlanPages2(
                          tpid: travelPlans[index]['id'],
                          monthandyear: '${DateFormat('MMMM yyyy').format(DateTime.parse(travelPlans[index]['created_date']))}',),));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 18, // Half of screen width with padding
                        height: MediaQuery.of(context).size.width / 2 - 18, // Square containers
                        decoration: BoxDecoration(
                          color: AppColors.textfiedlColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Icon(Icons.more_vert, color: AppColors.primaryColor),
                            ),
                            Positioned(
                              top: 100,
                              right: 10,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                  child: Text(
                                    '${travelPlans[index]['status']}',
                                    style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                DateFormat('MMMM yyyy').format(DateTime.parse(travelPlans[index]['created_date'])),
                                style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.w500,fontSize: 12),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Travel Plan ${travelPlans[index]['id']}',
                                    style: TextStyle(color: AppColors.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 100), // Add space at the end of the tile list
              ],
            ),
          ),
        )
            : Center(child: CircularProgressIndicator())
      ),
    );
  }
}
