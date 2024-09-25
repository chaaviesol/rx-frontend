import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/Login%20page.dart';
import 'package:rx_route_new/New%20Rx%20Project/Rep/Bottom%20navigation%20rep/Bottomnavigationrep.dart';
import 'package:rx_route_new/New%20Rx%20Project/Rep/Rep%20Home%20page.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../New Rx Project/Manager/BottomNav/BottomNavManager.dart';
import '../Util/Utils.dart';
import '../app_colors.dart';
import '../constants/styles.dart';
import '../widgets/bubble.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // _initPackageInfo();
    _navigateToHome();
    verifyPrefrencedata();
  }

  // Future<void> _initPackageInfo() async {
  //   final info = await PackageInfo.fromPlatform();
  //   setState(() {
  //     Utils.appversion = info.version;
  //   });
  // }

  Future<void> verifyPrefrencedata()async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID') ;
    if(uniqueID == 'null'){
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPageNew(),));
    }
  }

  _navigateToHome() async {
    debugPrint('navigate to home called...');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    String? userType = preferences.getString('userType');
    if(uniqueID != null){
      print('in pref uniqueid:${preferences.getString('uniqueID')}');
      print('in pref userid:${preferences.getString('userID')}');
      if(userType == 'Rep'){
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavigationRep()),
          );
        });
      }else if(userType == 'Manager'){
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavigationMngr()),
          );
        });
      }
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPageNew(),));
    }else{
      await Future.delayed(const Duration(seconds: 3), () {});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPageNew()),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      floatingActionButton: Text('${Utils.appversion}',style: text70014,),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: const Stack(
        children: [
          Positioned(
            top: -82,
            left: -87,
            child: Bubble(
              size: 246,
              color: AppColors.primaryColor2,
            ),
          ),

          Positioned(
            top: 67,
            left: 151,
            child: Bubble(
              size: 130,
              color: AppColors.primaryColor2,
            ),
          ),

          Positioned(
            top: 164,
            left: 66,
            child: Bubble(
              size: 75,
              color: AppColors.primaryColor2,
            ),
          ),

          // Bottom bubbles
          Positioned(
            bottom: -82,
            right: -87,
            child: Bubble(
              size: 246,
              color: AppColors.primaryColor2,
            ),
          ),
          Positioned(
            bottom: 67,
            right: 151,
            child: Bubble(
              size: 130,
              color: AppColors.primaryColor2,
            ),
          ),
          Positioned(
            bottom: 164,
            right: 66,
            child: Bubble(
              size: 75,
              color: AppColors.primaryColor2,
            ),
          ),
          Center(
            child: Text(
              'Rx ROUTE',
              style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontStyle: FontStyle.italic
              ),
            ),
          ),

        ],
      ),
    );
  }
}