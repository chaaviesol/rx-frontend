import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:http/http.dart' as http;

import '../../../View/homeView/Doctor/add_doctor.dart';
import '../../../constants/styles.dart';
import '../../../defaultButton.dart';
import '../../../res/app_url.dart';
import '../../../widgets/customDropDown.dart';

class Add_doctor_mngr extends StatefulWidget {
  const Add_doctor_mngr({Key? key}) : super(key: key);

  @override
  State<Add_doctor_mngr> createState() => _Add_doctor_mngrState();
}

class _Add_doctor_mngrState extends State<Add_doctor_mngr> {
  @override
  String _gender = '';
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialistaionController = TextEditingController();
  final TextEditingController _headQuaters = TextEditingController();
  final TextEditingController _exstation = TextEditingController();


  late Future<ProductResponse> _futureProducts;
  TextEditingController _textProductController = TextEditingController();
  List<ProductData> _selectedProducts = [];
  String _selectedProductsText = '';


  Future<ProductResponse> _fetchProducts() async {
    String url = AppUrl.list_products;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return ProductResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load data: $e');
    }
  }



  final TextEditingController _weddingDateController = TextEditingController();

  // final TextEditingController _confirmPasswordController = TextEditingController();

  int? _selectedVisits;
  final TextEditingController _visitsController = TextEditingController();
  String? fileName;

  void _setSelectedVisits(int value) {
    setState(() {
      _selectedVisits = value;
      _visitsController.text = value.toString();
    });
  }
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }


  List<Map<String, dynamic>> _headquartersData = [];
  Map<String, List<String>> _headquartersMap = {};
  String? _selectedHeadquarters;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHeadquarters();
  }

  Future<void> _fetchHeadquarters() async {
    final response = await http.get(Uri.parse('http://52.66.145.37:3004/rep/get_headquarters'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          _headquartersData = List<Map<String, dynamic>>.from(data['data']);
          _headquartersMap = {
            for (var item in _headquartersData)
              item['headquarter_name']: (item['sub_headquarter'] as String).split('\n').where((sub) => sub.isNotEmpty).toList(),
          };
          _isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load headquarters');
    }
  }

  List<String> _areasList = ['palakkad'];



  void _addArea() {
    setState(() {
      _areasList.add('');
    });
  }



  void _removeArea(int index) {
    setState(() {
      _areasList.removeAt(index);
    });
  }




  Future<void> _getCurrentLocation() async {
    try {
      // Request location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Handle location services disabled
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          // Handle permissions denied
          return;
        }
      }

      // Fetch current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Update the TextEditingControllers with the current location
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();

        print('latitude is :${_latitudeController.text}');
        print('longitude is :${_longitudeController.text}');
      });
    } catch (e) {
      // Handle errors (e.g., location services disabled or permissions denied)
      print(e);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(
        icon: CircleAvatar(backgroundColor: Colors.white,child: Icon(Icons.arrow_back_ios_rounded,color: AppColors.primaryColor,)), // Replace with your desired icon
        onPressed: () {
          // Handle the button press
          Navigator.pop(context);
        },
      ),centerTitle: true,title: Text('Add Doctor',style: text40016black,),),

      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10,),
              Text('Basic Information ',style: text50014black,),
              SizedBox(height: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name',style: text50012black,),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.textfiedlColor,
                        borderRadius: BorderRadius.circular(6)
                    ),
                    child: TextFormField(
                      controller: _nameController,

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 10),
                          hintText: 'Name',
                          hintStyle: text50010tcolor2,
                          counterText: ''
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mobile',style: text50012black,),
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                maxLength: 10,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    border: InputBorder.none,
                                    hintText: 'Mobile Number',
                                    hintStyle: text50010tcolor2,
                                    counterText: ''
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gender',style: text50012black,),
                            SizedBox(height: 10,),
                            Container(
                                decoration: BoxDecoration(
                                    color: AppColors.textfiedlColor,
                                    borderRadius: BorderRadius.circular(6)
                                ),
                                child: CustomDropdown(
                                  options: ['Male','Female','Other'],
                                  onChanged: (value) {
                                    _gender = value.toString();
                                  },
                                )
                            ),

                          ],
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 10,),

                  Text('Specialistaion',style: text50012black,),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.textfiedlColor,
                        borderRadius: BorderRadius.circular(6)
                    ),
                    child: TextFormField(
                       controller: _specialistaionController,

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 10),
                          hintText: 'Specialistaion',
                          hintStyle: text50010tcolor2,
                          counterText: ''
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Qualification',style: text50012black,),
                  SizedBox(height: 10,),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.textfiedlColor,
                        borderRadius: BorderRadius.circular(6)
                    ),
                    child: TextFormField(
                      controller: _qualificationController,

                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 10),
                          hintText: 'Qualification',
                          hintStyle: text50010tcolor2,
                          counterText: ''
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Work information ',style: text50014black,),
                  SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Visit Type', style: text50012black),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildVisitBox(label: 'Important', value: 4, color: Colors.yellow),
                          _buildVisitBox(label: 'Core', value: 8, color: Colors.green),
                          _buildVisitBox(label: 'Super Core', value: 12, color: Colors.red),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),


                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date of birth',style: text50012black,),
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: TextFormField(
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                controller: _dobController,
                                decoration: InputDecoration(
                                  hintText: 'Birth day',
                                  hintStyle: text50010tcolor2,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.cake_outlined,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  DateTime currentDate = DateTime.now();
                                  DateTime firstDate = DateTime(1900);
                                  DateTime initialDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day - 1);
                                  DateTime lastDate = currentDate; // Last day of the next month

                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: firstDate,
                                    initialDate: currentDate,
                                    lastDate: lastDate,
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: AppColors.primaryColor,
                                          hintColor: AppColors.primaryColor,
                                          colorScheme: const ColorScheme.light(primary: AppColors.primaryColor),
                                          buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedDate != null) {
                                    // Change the format of the date here
                                    String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                    setState(() {
                                      _dobController.text = formattedDate;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if(value! == null && value.isEmpty){
                                    // Utils.flushBarErrorMessage('Select date first', context, lightColor);
                                  }
                                  return null;
                                },
                                // validator: (value) => value!.isEmpty ? 'Select Date' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Wedding Date',style: text50012black,),
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: TextFormField(
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                                controller: _weddingDateController,
                                decoration: InputDecoration(
                                  hintText: 'Wedding date',
                                  hintStyle: text50010tcolor2,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.event,
                                    size: 25,
                                    color: Colors.black,
                                  ),
                                ),
                                readOnly: true,
                                onTap: () async {
                                  DateTime currentDate = DateTime.now();
                                  DateTime firstDate = DateTime(1500);
                                  DateTime initialDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day - 1);
                                  DateTime lastDate = currentDate; // Last day of the next month

                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: firstDate,
                                    initialDate: currentDate,
                                    lastDate: lastDate,
                                    builder: (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: AppColors.primaryColor,
                                          hintColor: AppColors.primaryColor,
                                          colorScheme: const ColorScheme.light(primary: AppColors.primaryColor),
                                          buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedDate != null) {
                                    // Change the format of the date here
                                    String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                                    setState(() {
                                      _weddingDateController.text = formattedDate;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if(value! == null && value.isEmpty){
                                    // Utils.flushBarErrorMessage('Select date first', context, lightColor);
                                  }
                                  return null;
                                },
                                // validator: (value) => value!.isEmpty ? 'Select Date' : null,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Schedule',style: text50014black,),
                      SizedBox(height: 10,),
                      Text('HeadQuaters',style: text50012black,),
                      SizedBox(height: 10,),


             _isLoading
            ? Center(child: CircularProgressIndicator())
          : Container(
    decoration: BoxDecoration(
    color: AppColors.textfiedlColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
    children: [
    Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: DropdownButton<String>(
    hint: Text("Select Headquarters"),
    value: _selectedHeadquarters,
    items: _headquartersData
        .map((item) => DropdownMenuItem<String>(
    value: item['sub_headquarter'],
    child: Text(item['sub_headquarter']),
    ))
        .toList(),
    onChanged: (value) {
    setState(() {
    _selectedHeadquarters = value;
    });
    },
    ),
    ),
    if (_selectedHeadquarters != null)
    Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: DropdownButton<String>(
    hint: Text("Select Sub-Headquarters"),
    items: _headquartersMap[_selectedHeadquarters]
        ?.map((sub) => DropdownMenuItem(
    value: sub,
    child: Text(sub),
    ))
        .toList(),
    onChanged: (value) {
    // Handle sub-headquarters selection
    },
    ),
    ),
    ],
    ),
    ),

                      SizedBox(height: 10),
                      Text('Areas', style: text50012black),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.textfiedlColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < _areasList.length; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        initialValue: _areasList[i],
                                        decoration: InputDecoration(
                                          hintText: 'Area',
                                          hintStyle: text50010tcolor2,
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) {
                                          _areasList[i] = value;
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _removeArea(i),
                                    ),
                                  ],
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                        hintText: 'Add new area',
                                        hintStyle: text50010tcolor2,
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        if (_areasList.isEmpty || _areasList.last.isNotEmpty) {
                                          _addArea();
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.green),
                                    onPressed: _addArea,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text('Address',style: text50012black,),
                      SizedBox(height: 10,),
                      Container(
                        decoration: BoxDecoration(
                            color: AppColors.textfiedlColor,
                            borderRadius: BorderRadius.circular(6)
                        ),
                        child: TextFormField(
                          controller: _addressController,

                          decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 10),
                              hintText: 'Address',
                              hintStyle: text50010tcolor2,
                              counterText: ''
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start, // Align all children to the start
                        crossAxisAlignment: CrossAxisAlignment.center, // Align children in the center vertically
                        children: [
                          // Button on the left side
                          SizedBox(
                            height: 50, // Set the height of the button
                            width: 50,  // Set the width of the button
                            child: ElevatedButton(

                              onPressed:  _getCurrentLocation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textfiedlColor, // Button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6), // Adjust button corner radius
                                ),
                                padding: EdgeInsets.zero, // Remove default padding
                              ),
                              child: Icon(
                                CupertinoIcons.location_solid,
                                color: AppColors.primaryColor,
                                size: 24, // Adjust icon size
                              ),
                            ),
                          ),
                          SizedBox(width: 20), // Space between the button and the fields
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Latitude', style: text50012black),
                                SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.textfiedlColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: TextFormField(
                                    controller: _latitudeController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(left: 10),
                                      hintText: 'Latitude',
                                      hintStyle: text50010tcolor2,
                                      counterText: '',
                                    ), readOnly: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 20), // Space between the latitude and longitude fields
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Longitude', style: text50012black),
                                SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.textfiedlColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: TextFormField(
                                    controller: _longitudeController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(left: 10),
                                      hintText: 'Longitude',
                                      hintStyle: text50010tcolor2,
                                      counterText: '',
                                    ),
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10,),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //     const SnackBar(content: Text('Processing Data'))
                                  // );
                                  // adddoctors();
                                }
                              },
                              child: Defaultbutton(
                                text: 'Submit',
                                bgColor: AppColors.primaryColor,
                                textstyle: const TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2.5,
                              child: Defaultbutton(
                                text: 'Cancel',
                                bgColor: AppColors.whiteColor,
                                bordervalues: Border.all(width: 1, color: AppColors.primaryColor),
                                textstyle: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),

                ],
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildVisitBox({required String label, required int value, required Color color}) {
    return GestureDetector(
      onTap: () => _setSelectedVisits(value),
      child: Container(

        height: 50,
        width: MediaQuery.of(context).size.width/3.5,
        decoration: BoxDecoration(
          color: AppColors.textfiedlColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _selectedVisits == value ? Colors.brown : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(radius: 5,backgroundColor: color,),
              Text(
                label,
                style: text50012black
              ),
            ],
          ),
        ),
      ),
    );
  }
}
