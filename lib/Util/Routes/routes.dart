import 'package:flutter/material.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/BottomNavManager.dart';
import 'package:rx_route_new/Util/Routes/routes_name.dart';
import 'package:rx_route_new/Util/Utils.dart';


import '../../New Rx Project/Manager/Login page.dart';
import '../../New Rx Project/Rep/Rep Home page.dart';
import '../../Splash/splashscreen.dart';
import '../../Splash/successfully_added.dart';
import '../../View/Add TP/add_tp.dart';
import '../../View/authView/loginView.dart';
import '../../View/homeView/Doctor/add_doctor.dart';
import '../../View/homeView/Employee/add_rep.dart';
import '../../View/homeView/Expense/expense_request.dart';
import '../../View/homeView/Leave/LeaveRequest.dart';
import '../../View/homeView/chemist/add_chemist.dart';
import '../../View/homeView/home_view.dart';
import '../../View/homeView/home_view_rep.dart';
import '../../constants/styles.dart';

class Routes{

  static Route<dynamic> generateRoute(RouteSettings settings,{Object? arguments}){

    switch (settings.name){

      case RoutesName.splash:
        return MaterialPageRoute(builder: (BuildContext context)=>const SplashScreen());

      case RoutesName.successsplash:
        return MaterialPageRoute(builder: (BuildContext context) =>const SuccessfullyAdded() ,);

      case RoutesName.home_rep:
        return MaterialPageRoute(builder: (BuildContext context)=>const RepHomepage());

      case RoutesName.home_manager:
        return MaterialPageRoute(builder: (BuildContext context)=>const BottomNavigationMngr());

      case RoutesName.login:
        return MaterialPageRoute(builder: (BuildContext context)=>const LoginPageNew());

      case RoutesName.add_doctor:
        return MaterialPageRoute(builder: (BuildContext context)=> AddDoctor());

      case RoutesName.add_employee:
        return MaterialPageRoute(builder: (BuildContext context)=>const AddRep());

      case RoutesName.add_chemist:
        return MaterialPageRoute(builder: (BuildContext context)=>const AddChemist());

      case RoutesName.requestLeave:
        return MaterialPageRoute(builder: (BuildContext context) => const LeaveApplyPage(),);

      case RoutesName.requestExpense:
        return MaterialPageRoute(builder: (BuildContext context) => const ExpenseRequestPage(),);

      case RoutesName.addTp:
        return MaterialPageRoute(builder: (BuildContext context) => const AddTravelPlan(),);

      default:
        return MaterialPageRoute(builder: (BuildContext context) => const LoginPageNew());

    }
  }
}