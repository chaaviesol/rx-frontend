
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import 'package:http/http.dart' as http;
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/AutoTP/autoTP.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/Doctors_mngr/Add%20Doctor.dart';
import 'package:rx_route_new/New%20Rx%20Project/Rep/Rep%20Home%20page.dart';
import 'package:rx_route_new/View/homeView/Doctor/add_doctor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Util/Routes/routes_name.dart';
import '../../Util/Utils.dart';
import '../../View/profile/settings/privacypolicy.dart';
import '../../View/profile/settings/terms_and_conditions.dart';
import '../../app_colors.dart';
import '../../res/app_url.dart';
import '../Rep/Bottom navigation rep/Bottomnavigationrep.dart';
import 'BottomNav/BottomNavManager.dart';
import 'BottomNav/Travel plan/New_tp.dart';


class LoginPageNew extends StatefulWidget {
  const LoginPageNew({super.key});

  @override
  _LoginPageNewState createState() => _LoginPageNewState();
}

class _LoginPageNewState extends State<LoginPageNew> {

  final LocalAuthentication _localAuthentication = LocalAuthentication();

  Future<void> checkBiometric() async {
    try {
      bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
      print('Can check biometrics: $canCheckBiometrics');
    } catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  Future<void> getAvailableBiometrics() async {
    try {
      List<BiometricType> availableBiometrics = await _localAuthentication.getAvailableBiometrics();
      print('Available biometrics: $availableBiometrics');
    } catch (e) {
      print('Error getting available biometrics: $e');
    }
  }

  Future<void> authenticate() async {
    try {
      bool isAuthenticated = await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      print('Biometric authentication successful: $isAuthenticated');
    } catch (e) {
      print('Error during biometric authentication: $e');
    }
  }

  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  final TextEditingController userid = TextEditingController();
  final TextEditingController password = TextEditingController();

  final FocusNode useridNode = FocusNode();
  final FocusNode passwordNode = FocusNode();
  final FocusNode loginButtonNode = FocusNode();



  // Future<dynamic> login() async {
  //   String url = AppUrl.login;
  //   Map<String, dynamic> data = {
  //     "userId": userid.text,
  //     "password": password.text,
  //   };
  //
  //   try {
  //     print('api:${AppUrl.login}');
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(data),
  //     );
  //     print('hhhh${userid.text}');
  //     print('${password.text}');
  //     print('st code :${response.statusCode}');
  //     print('res:${response.body}');
  //     if (response.statusCode == 200) {
  //       print('new response is :${jsonDecode(response.body)} ');
  //       var responseData = jsonDecode(response.body);
  //       print("user id:${responseData['data'][0]['id']}");
  //       print("user uid:${responseData['data'][0]['uniqueId'].toString()}");
  //       print("user role:${responseData['data'][0]['role'].toString()}");
  //       print("user name:${responseData['data'][0]['name'].toString()}");
  //       // setState(() async{
  //         final SharedPreferences prefrence =await SharedPreferences.getInstance();
  //         // var responseData = jsonDecode(response.body);
  //         prefrence.setString('userID', responseData['data'][0]['id'].toString());
  //         prefrence.setString('uniqueID', '${responseData['data'][0]['uniqueId'].toString()}');
  //         prefrence.setString('userType', '${responseData['data'][0]['role'].toString()}');
  //         prefrence.setString('userName', '${responseData['data'][0]['name'].toString()}');
  //
  //         print('userID:${prefrence.getString('userID')}');
  //         print('uni:${prefrence.getString('uniqueID')}');
  //         print('userID:${prefrence.getString('userType')}');
  //         print('userID:${prefrence.getString('userName')}');
  //
  //         if(prefrence.getString('userType') == 'rep'){
  //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RepHomepage(),));
  //           // Navigator.pushNamedAndRemoveUntil(context, RoutesName.home_rep,(route) => false,);
  //           Utils.flushBarErrorMessage('${responseData['message']}'+' ${prefrence.getString('userName').toString().toUpperCase()}', context);
  //           Utils.getuser();
  //         }else if(prefrence.getString('userType') == 'Manager'){
  //           // Navigator.pushNamedAndRemoveUntil(context, RoutesName.home_manager,(route) => false,);
  //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationMngr(),));
  //           Utils.flushBarErrorMessage('${responseData['message']}'+' ${prefrence.getString('userName').toString().toUpperCase()}', context);
  //           Utils.getuser();
  //           return responseData;
  //         }
  //       // });
  //       //sharedpreferences
  //
  //     } else {
  //       var responseData = jsonDecode(response.body);
  //       Utils.flushBarErrorMessage('${responseData['message']}', context);
  //     }
  //   } catch (e) {
  //     Utils.flushBarErrorMessage('${e.toString()}', context);
  //     throw Exception('Failed to load data: $e');
  //   }
  // }



  Future<dynamic> login() async {
    String url = AppUrl.login;
    Map<String, dynamic> data = {
      "userId": userid.text,
      "password": password.text,
    };

    try {
      print('API URL: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('User ID: ${userid.text}');
      print('Password: ${password.text}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['success']) {
          print("Login Successful");
          SharedPreferences preferences = await SharedPreferences.getInstance();
          var userData = responseData['data'][0];

          preferences.setString('userID', userData['id'].toString());
          preferences.setString('uniqueID', userData['uniqueId'].toString());
          preferences.setString('userType', userData['role'].toString());
          preferences.setString('userName', userData['name'].toString());

          print('Stored User ID: ${preferences.getString('userID')}');
          print('Stored Unique ID: ${preferences.getString('uniqueID')}');
          print('Stored User Type: ${preferences.getString('userType')}');
          print('Stored User Name: ${preferences.getString('userName')}');

          if (preferences.getString('userType') == 'Rep') {
            print('oooo');
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationRep()));
            Utils.flushBarErrorMessage('${responseData['message']} ${preferences.getString('userName')!.toUpperCase()}', context);
            Utils.getuser();
          } else if (preferences.getString('userType') == 'Manager') {
            print('dhddh');
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavigationMngr()));
            Utils.flushBarErrorMessage('${responseData['message']} ${preferences.getString('userName')!.toUpperCase()}', context);
            Utils.getuser();
          }
          return responseData;
        } else {
          Utils.flushBarErrorMessage(responseData['message'], context);
        }
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage(responseData['message'], context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage('Failed to load data: $e', context);
      throw Exception('Failed to load data: $e');
    }
  }



  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50,),
                // InkWell(
                //   onTap: (){
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => NewTravelPlan(),));
                //   },
                //   child: Text('New Travel plan'),
                // ),
                InkWell(
                  onTap: (){
                    getAvailableBiometrics();
                    authenticate();
                  },
                    child: Icon(Icons.fingerprint,color: AppColors.primaryColor,size: 55,)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icons/rxlogo.png',
                      height:35,
                      width: 35,),
                    const Text(
                        'RxROUTE',
                        style:TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: AppColors.primaryColor,

                        )
                    ),
                  ],
                ),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AddDoctor(),));
                  },
                    child: Text('data')),InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorSchedulePage(),));
                  },
                    child: Text('data set')),
                const SizedBox(height: 10),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: TextFormField(
                          controller: userid,
                          focusNode: useridNode,
                          onFieldSubmitted: (value){
                            Utils.fieldFocusChange(context, useridNode, passwordNode);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please fill this field';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'User ID',
                            prefixIcon: const Icon(Icons.person_2_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.2,
                        child: TextFormField(
                          controller: password,
                          focusNode: passwordNode,
                          onFieldSubmitted: (value){
                            Utils.fieldFocusChange(context, passwordNode, loginButtonNode);
                          },
                          obscureText: !_passwordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please fill this field';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_open),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // const Text(
                      //   'Forgot password',
                      //   style: TextStyle(
                      //     decoration: TextDecoration.underline,
                      //     color: AppColors.primaryColor,
                      //   ),
                      // ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Center(
                  child: InkWell(
                    focusNode: loginButtonNode,
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          login();
                        });
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Login with user ID',
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0,right: 25),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'By clicking Login, you agree to our ',
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Handle Terms & Conditions click
                                print('Terms & Conditions clicked');
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TermsAndConditions()));
                              },
                          ),
                          const TextSpan(
                            text: ' and ',
                          ),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Handle Privacy Policy click
                                print('Privacy Policy clicked');
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
                              },
                          ),
                          const TextSpan(
                            text: '.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
//
// import '../../Util/Utils.dart';
// import '../../View/profile/settings/terms_and_conditions.dart';
// import '../../app_colors.dart';
// import '../../constants/styles.dart';
// import 'BottomNav/BottomNavManager.dart';
// import 'BottomNav/HomepageManagerNew.dart';
//
// class LoginPageNew extends StatefulWidget {
//   const LoginPageNew({Key? key}) : super(key: key);
//
//   @override
//   State<LoginPageNew> createState() => _LoginPageNewState();
// }
//
// class _LoginPageNewState extends State<LoginPageNew> {
//
//   final _formKey = GlobalKey<FormState>();
//   bool _passwordVisible = false;
//
//   final TextEditingController userid = TextEditingController();
//   final TextEditingController password = TextEditingController();
//
//   final FocusNode useridNode = FocusNode();
//   final FocusNode passwordNode = FocusNode();
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('User Login ',style: text70014black,),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('User ID',style: text50012black,),
//                     SizedBox(height: 10,),
//                     Container(
//                       decoration: BoxDecoration(
//                           color: AppColors.textfiedlColor,
//                           borderRadius: BorderRadius.circular(6)
//                       ),
//                       child: TextFormField(
//                         controller: userid,
//                         focusNode: useridNode,
//                         onFieldSubmitted: (value){
//                           Utils.fieldFocusChange(context, useridNode, passwordNode);
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please fill this field';
//                           }
//                           return null;
//                         },
//
//                         decoration: InputDecoration(
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.only(left: 10),
//                             // hintText: 'User id',
//                             hintStyle: text50010tcolor2,
//                             counterText: ''
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10,),
//
//                     Text('Password',style: text50012black,),
//                     SizedBox(height: 10,),
//                     Container(
//                       decoration: BoxDecoration(
//                           color: AppColors.textfiedlColor,
//                           borderRadius: BorderRadius.circular(6)
//                       ),
//                       child: TextFormField(
//                         controller: password,
//                         focusNode: passwordNode,
//                         onFieldSubmitted: (value){
//                           Utils.fieldFocusChange(context, passwordNode, passwordNode);
//                         },
//                         obscureText: !_passwordVisible,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please fill this field';
//                           }
//                           return null;
//                         },
//                         decoration: InputDecoration(
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.only(left: 10),
//
//                             hintStyle: text50010tcolor2,
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _passwordVisible
//                                   ? Icons.visibility
//                                   : Icons.visibility_off,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _passwordVisible = !_passwordVisible;
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 10,),
//                     Row(mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         RichText(
//                           textAlign: TextAlign.center,
//                           text: TextSpan(
//
//                             children: [
//                               TextSpan(
//                                 text: 'Forgot Password',
//                                 style: const TextStyle(
//                                   color: Colors.blue,
//                                   decoration: TextDecoration.underline,
//                                 ),
//                                 recognizer: TapGestureRecognizer()
//                                   ..onTap = () {
//                                     // Handle Terms & Conditions click
//                                     print('Terms & Conditions clicked');
//                                     Navigator.push(context, MaterialPageRoute(builder: (context) => TermsAndConditions()));
//                                   },
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 10,),
//                     Center(
//                       child: InkWell(
//                         onTap: () {
//                           // if (_formKey.currentState!.validate()) {
//                           //   setState(() {
//                           //     // login();
//                           //   });
//                           // }
//                           Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNavigationMngr(),));
//                         },
//                         child: Container(
//
//                           decoration: BoxDecoration(
//                             color: AppColors.primaryColor,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Center(
//                               child: Text(
//                                 'Login',
//                                 style: TextStyle(
//                                   color: AppColors.whiteColor,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//                   ],
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



