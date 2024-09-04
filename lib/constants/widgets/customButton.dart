import 'package:flutter/material.dart';


import '../../app_colors.dart';
import '../styles.dart';

class CustomButton extends StatelessWidget {

  final String title;
  final bool loading;
  final VoidCallback onPress;

  const CustomButton({
    Key? key,
    required this.title,
    this.loading=false,
    required this.onPress ,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onPress ,
      child: Container(
        height: 50,
        width: MediaQuery
            .of(context)
            .size
            .width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: AppColors.primaryColor,
        ),
        child: Center(
            child: loading ? const CircularProgressIndicator(color: Colors.white,) : Text(
              title, style: text60024,)),
      ),
    );
  }
}