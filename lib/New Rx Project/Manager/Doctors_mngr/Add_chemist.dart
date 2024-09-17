import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:rx_route_new/Util/Utils.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app_colors.dart';
import '../../../constants/styles.dart';
import '../../../defaultButton.dart';

class Adding_chemistmngr extends StatefulWidget {
  const Adding_chemistmngr({Key? key}) : super(key: key);

  @override
  State<Adding_chemistmngr> createState() => _Adding_chemistmngrState();
}

class _Adding_chemistmngrState extends State<Adding_chemistmngr> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _pharmacynameController = TextEditingController();
  final TextEditingController _licencenumberController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  String? fileName;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        fileName = result.files.single.name;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> _submitForm() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    int? userID = int.parse(preferences.getString('userID').toString());
    print('uniq id/usid:${uniqueID}'+'${userID}');
    if (_formKey.currentState!.validate()) {

      final response = await http.post(
        Uri.parse(AppUrl.add_chemist),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'created_by': userID,
          'building_name': _pharmacynameController.text,
          'mobile': _mobileController.text,
          'email': _emailController.text,
          'lisence_no': _licencenumberController.text,
          'address': _addressController.text,
          'date_of_birth': _dateOfBirthController.text,
          'uniqueId': uniqueID, // Update this as needed
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chemist added successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add chemist')));
      }
    }
  }

  String? _validatePharmacyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pharmacy name is required';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  String? _validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }
    if (!RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(value)) {
      return 'Enter a valid date (dd-mm-yyyy)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back_ios_rounded, color: AppColors.primaryColor),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text('Add Chemist', style: text40016black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text('Basic Information', style: text50014black),
                SizedBox(height: 10),
                _buildTextField(
                  _pharmacynameController,
                  'Pharmacy Name',
                  'Pharmacy Name',
                  validator: _validatePharmacyName,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  _mobileController,
                  'Mobile Number',
                  'Mobile Number',
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: _validateMobile,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  _emailController,
                  'Email',
                  'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  _licencenumberController,
                  'License Number',
                  'License Number',
                  validator: _validateLicenseNumber,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  _addressController,
                  'Address',
                  'Address',
                  maxLines: 3,
                  validator: _validateAddress,
                ),
                SizedBox(height: 10),
                _buildTextField(
                  _dateOfBirthController,
                  'Date of Birth',
                  'Date of Birth',
                  validator: _validateDateOfBirth,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: pickFile,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      decoration: BoxDecoration(
                        color: AppColors.textfiedlColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_present),
                            SizedBox(width: 10),
                            Text('Add documents', style: text50012black),
                            SizedBox(width: 10),
                            fileName != null ? Icon(Icons.verified, color: AppColors.primaryColor) : Icon(Icons.verified, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildButton('Submit', AppColors.primaryColor, AppColors.whiteColor, _submitForm),
                    _buildButton('Cancel', AppColors.whiteColor, AppColors.primaryColor, () {
                      Navigator.pop(context);
                    }, border: Border.all(width: 1, color: AppColors.primaryColor)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, String hintText, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: text50012black),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textfiedlColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(left: 10),
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: text50010tcolor2,
              counterText: '',
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, Color bgColor, Color textColor, VoidCallback onPressed, {Border? border}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.5,
      child: InkWell(
        onTap: onPressed,
        child: Defaultbutton(
          text: text,
          bgColor: bgColor,
          bordervalues: border,
          textstyle: TextStyle(
            color: textColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
