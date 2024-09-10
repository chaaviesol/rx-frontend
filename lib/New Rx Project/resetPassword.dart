
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/Util/Utils.dart';
import 'dart:convert';

import 'package:rx_route_new/app_colors.dart';

class ResetPasswordPage extends StatefulWidget {
  final int userId;

  ResetPasswordPage({required this.userId});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _resetPassword() async {
    final String apiUrl = 'http://52.66.145.37:3004/user/resetPassword';
    final Map<String, dynamic> body = {
      "userId": widget.userId,
      "password": _newPasswordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${response.body}'),
            ),
          );
          Navigator.pop(context);

        } else {
          Utils.flushBarErrorMessage('${data['message']}', context);
        }
      } else {
        Utils.flushBarErrorMessage('error : ${response.statusCode}', context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage('${e.toString()}', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      floatingActionButtonLocation:FloatingActionButtonLocation.centerFloat,
      floatingActionButton:  ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor
        ),
        onPressed: () {
          final newPassword = _newPasswordController.text;
          final confirmPassword = _confirmPasswordController.text;

          if (newPassword.isNotEmpty && confirmPassword.isNotEmpty) {
            if (newPassword == confirmPassword) {
              _resetPassword();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Passwords do not match'),
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please fill in all fields'),
              ),
            );
          }
        },
        child: Text('Reset Password',style: TextStyle(color: AppColors.whiteColor),),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Please update your password continue !',style: TextStyle(
              color: AppColors.primaryColor,fontWeight: FontWeight.bold
            ),),

            SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: AppColors.textfiedlColor,
                borderRadius: BorderRadius.circular(9)
              ),
              child: TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border:InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isNewPasswordVisible,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: AppColors.textfiedlColor,
                borderRadius: BorderRadius.circular(9)
              ),
              child: TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}