
import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_colors.dart';
import 'Routes/routes_name.dart';
class Utils{

  static const platform = MethodChannel('com.example.rxroute_test/alarm');

  static String? appversion;

  static String? UserType;
  static String? userName;
  static String? email;
  static String? userId;
  static String? uniqueID ;

  static final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  // next field focused in textField
  static fieldFocusChange(
      BuildContext context,
      FocusNode current,
      FocusNode nextFocus,){
    current.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }


  static flushBarErrorMessage(String message , BuildContext context){
    showFlushbar(context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        positionOffset: 20,
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.circular(20),
        icon: const Icon(Icons.error ,size: 28,color: Colors.white,),
        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        padding: const EdgeInsets.all(15),
        message: message,
        backgroundColor: AppColors.primaryColor,
        messageColor: Colors.white,
        duration: const Duration(seconds: 3),
      )..show(context),
    );}

  static flushBarErrorMessage2(String message , BuildContext context){
    showFlushbar(context: context,
      flushbar: Flushbar(
        forwardAnimationCurve: Curves.decelerate,
        reverseAnimationCurve: Curves.easeOut,
        positionOffset: 20,
        flushbarPosition: FlushbarPosition.TOP,
        borderRadius: BorderRadius.circular(20),
        icon: const Icon(Icons.error ,size: 28,color: Colors.white,),
        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        padding: const EdgeInsets.all(15),
        message: message,
        backgroundColor: Colors.red,
        messageColor: Colors.white,
        duration: const Duration(seconds: 3),
      )..show(context),
    );}

  static snackBar(String message , BuildContext context){
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text(message))
    );
  }

  //date formating...
  static String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    // You can specify your desired format here
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    return formattedDate;
  }

  // Function to extract and format time
  static String getTime(String dateTime) {
    DateTime parsedDate = DateTime.parse(dateTime);
    String formattedTime = DateFormat.Hm().format(parsedDate);
    return formattedTime;
  }

  static String formatMonth(String dateString) {
    // Parse the date string with the initial format
    DateFormat originalFormat = DateFormat('dd-MM-yyyy');
    DateTime dateTime = originalFormat.parse(dateString);
    // Format the date to 'MMM yyyy'
    String formattedMonth = DateFormat('MMM yyyy').format(dateTime);
    return formattedMonth;
  }

  static String formatDay(String dateString) {
    // Parse the date string with the initial format
    DateFormat originalFormat = DateFormat('dd-MM-yyyy');
    DateTime dateTime = originalFormat.parse(dateString);
    // Format the date to display only the day
    String formattedDay = DateFormat('EEEE').format(dateTime);
    return formattedDay;
  }

  static int calculateDaysDifference(String fromDate, String toDate) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    DateTime start = dateFormat.parse(fromDate);
    DateTime end = dateFormat.parse(toDate);
    return end.difference(start).inDays; // +1 to include both start and end date
  }


  static Future<dynamic>getuser()async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
   Utils.userName = preferences.getString('userName');
   Utils.userId = preferences.getString('userID');
   Utils.uniqueID = preferences.getString('unique');
   Utils.UserType = preferences.getString('userType');
    return true;
  }

  static Future<dynamic>deleteuser(BuildContext context)async{
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('userName');
    preferences.remove('userID');
    preferences.remove('unique');
    preferences.remove('userType');
    preferences.remove('userEmail');
    preferences.clear();
    Navigator.pushNamedAndRemoveUntil(context, RoutesName.login, (route) => false,);
    return true;
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }
// //web credential storing
//   static void saveLoginState(String token) {
//     window.localStorage['token'] = token; // Store token in localStorage
//   }
//
//   static bool isLoggedIn() {
//     String? token = window.localStorage['token'];
//     return token != null;
//   }
//
//   static void logout() {
//     window.localStorage.remove('token');
//   }

  static String getMonthName(int month) {
    const List<String> monthNames = [
      '', // Placeholder for 0 index (not used)
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    // Ensure the month is between 1 and 12
    if (month < 1 || month > 12) {
      return 'Invalid month';
    }

    return monthNames[month];
  }


}