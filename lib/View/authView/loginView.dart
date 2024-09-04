// import 'dart:convert';
//
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
//
// import 'package:http/http.dart' as http;
// import 'package:local_auth/local_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../New Rx Project/Manager/Login page.dart';
// import '../../Util/Routes/routes_name.dart';
// import '../../Util/Utils.dart';
// import '../../app_colors.dart';
// import '../../res/app_url.dart';
// import '../profile/settings/privacypolicy.dart';
// import '../profile/settings/terms_and_conditions.dart';
//
//
// class LoginView extends StatefulWidget {
//   const LoginView({super.key});
//
//   @override
//   _LoginViewState createState() => _LoginViewState();
// }
//
// class _LoginViewState extends State<LoginView> {
//
//   final LocalAuthentication _localAuthentication = LocalAuthentication();
//
//   Future<void> checkBiometric() async {
//     try {
//       bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;
//       print('Can check biometrics: $canCheckBiometrics');
//     } catch (e) {
//       print('Error checking biometrics: $e');
//     }
//   }
//
//   Future<void> getAvailableBiometrics() async {
//     try {
//       List<BiometricType> availableBiometrics = await _localAuthentication.getAvailableBiometrics();
//       print('Available biometrics: $availableBiometrics');
//     } catch (e) {
//       print('Error getting available biometrics: $e');
//     }
//   }
//
//   Future<void> authenticate() async {
//     try {
//       bool isAuthenticated = await _localAuthentication.authenticate(
//         localizedReason: 'Authenticate to access the app',
//         options: AuthenticationOptions(
//           biometricOnly: true,
//           useErrorDialogs: true,
//           stickyAuth: true,
//         ),
//       );
//       print('Biometric authentication successful: $isAuthenticated');
//     } catch (e) {
//       print('Error during biometric authentication: $e');
//     }
//   }
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
//
//   Future<dynamic> login() async {
//     String url = AppUrl.login;
//     Map<String, dynamic> data = {
//       "userId": userid.text,
//       "password": password.text,
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(data),
//       );
//       print('st code :${response.statusCode}');
//       if (response.statusCode == 200) {
//         setState(() async{
//           final SharedPreferences prefrence =await SharedPreferences.getInstance();
//           var responseData = jsonDecode(response.body);
//           prefrence.setString('userID', responseData['data'][0]['id'].toString());
//           prefrence.setString('uniqueID', '${responseData['data'][0]['unique_id'].toString()}');
//           prefrence.setString('userType', '${responseData['data'][0]['type'].toString()}');
//           prefrence.setString('userName', '${responseData['data'][0]['name'].toString()}');
//
//           print('userID:${prefrence.getString('userID')}');
//           print('uni:${prefrence.getString('uniqueID')}');
//           print('userID:${prefrence.getString('userType')}');
//           print('userID:${prefrence.getString('userName')}');
//
//           if(prefrence.getString('userType') == 'rep'){
//             Navigator.pushNamedAndRemoveUntil(context, RoutesName.home_rep,(route) => false,);
//             Utils.flushBarErrorMessage('${responseData['message']}'+' ${prefrence.getString('userName').toString().toUpperCase()}', context);
//             Utils.getuser();
//           }else if(prefrence.getString('userType') == 'manager'){
//             Navigator.pushNamedAndRemoveUntil(context, RoutesName.home_manager,(route) => false,);
//             Utils.flushBarErrorMessage('${responseData['message']}'+' ${prefrence.getString('userName').toString().toUpperCase()}', context);
//             Utils.getuser();
//             return responseData;
//           }
//         });
//         //sharedpreferences
//
//       } else {
//         var responseData = jsonDecode(response.body);
//         Utils.flushBarErrorMessage('${responseData['message']}', context);
//       }
//     } catch (e) {
//       Utils.flushBarErrorMessage('${e.toString()}', context);
//       throw Exception('Failed to load data: $e');
//     }
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     _passwordVisible = false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(height: 50,),
//             InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPageNew(),)),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset('assets/icons/rxlogo.png',
//                     height:35,
//                     width: 35,),
//                   const Text(
//                     'RxROUTE',
//                     style:TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 24,
//                       color: AppColors.primaryColor,
//
//                     )
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 10),
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width / 1.2,
//                     child: TextFormField(
//                       controller: userid,
//                       focusNode: useridNode,
//                       onFieldSubmitted: (value){
//                         Utils.fieldFocusChange(context, useridNode, passwordNode);
//                       },
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please fill this field';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'User ID',
//                         prefixIcon: const Icon(Icons.person_2_outlined),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width / 1.2,
//                     child: TextFormField(
//                       controller: password,
//                       focusNode: passwordNode,
//                       onFieldSubmitted: (value){
//                         Utils.fieldFocusChange(context, passwordNode, passwordNode);
//                       },
//                       obscureText: !_passwordVisible,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please fill this field';
//                         }
//                         return null;
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'Password',
//                         prefixIcon: const Icon(Icons.lock_open),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _passwordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _passwordVisible = !_passwordVisible;
//                             });
//                           },
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   // const Text(
//                   //   'Forgot password',
//                   //   style: TextStyle(
//                   //     decoration: TextDecoration.underline,
//                   //     color: AppColors.primaryColor,
//                   //   ),
//                   // ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//             Center(
//               child: InkWell(
//                 onTap: () {
//                   if (_formKey.currentState!.validate()) {
//                     setState(() {
//                       login();
//                     });
//                   }
//                 },
//                 child: Container(
//                   width: MediaQuery.of(context).size.width / 1.2,
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryColor,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Center(
//                       child: Text(
//                         'Login with user ID',
//                         style: TextStyle(
//                           color: AppColors.whiteColor,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.only(left: 25.0,right: 25),
//               child: Center(
//                 child: RichText(
//                   textAlign: TextAlign.center,
//                   text: TextSpan(
//                     text: 'By clicking Login, you agree to our ',
//                     style: const TextStyle(color: Colors.black, fontSize: 16),
//                     children: [
//                       TextSpan(
//                         text: 'Terms & Conditions',
//                         style: const TextStyle(
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                             // Handle Terms & Conditions click
//                             print('Terms & Conditions clicked');
//                             Navigator.push(context, MaterialPageRoute(builder: (context) => TermsAndConditions()));
//                           },
//                       ),
//                       const TextSpan(
//                         text: ' and ',
//                       ),
//                       TextSpan(
//                         text: 'Privacy Policy',
//                         style: const TextStyle(
//                           color: Colors.blue,
//                           decoration: TextDecoration.underline,
//                         ),
//                         recognizer: TapGestureRecognizer()
//                           ..onTap = () {
//                             // Handle Privacy Policy click
//                             print('Privacy Policy clicked');
//                             Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
//                           },
//                       ),
//                       const TextSpan(
//                         text: '.',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
