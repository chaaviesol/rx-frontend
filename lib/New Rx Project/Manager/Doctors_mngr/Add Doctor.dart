import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/Doctors_mngr/Add_chemist.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/model/scheduleModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Util/Routes/routes_name.dart';
import '../../../Util/Utils.dart';
import '../../../View/homeView/Doctor/add_doctor.dart';
import '../../../constants/styles.dart';
import '../../../defaultButton.dart';
import '../../../model/doctorModel.dart';
import '../../../res/app_url.dart';
import '../../../widgets/customDropDown.dart';

class Add_doctor_mngr extends StatefulWidget {
  const Add_doctor_mngr({Key? key}) : super(key: key);

  @override
  State<Add_doctor_mngr> createState() => _Add_doctor_mngrState();
}

class _Add_doctor_mngrState extends State<Add_doctor_mngr> {
  @override
  //schedule section
  List<ScheduleNew> schedules = [ScheduleNew()];
  String _gender = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _specialistaionController =
      TextEditingController();
  final TextEditingController _headQuaters = TextEditingController();
  final TextEditingController _exstation = TextEditingController();

  bool basicInfo = true;
  bool workInfo = true;

  late Future<ProductResponse> _futureProducts;
  TextEditingController _textProductController = TextEditingController();
  List<ProductData> _selectedProducts = [];
  String _selectedProductsText = '';

  TextEditingController _textChemistController = TextEditingController();
  List<Chemist> _selectedChemists = [];
  String _selectedChemistsText = '';

  // Mapping of abbreviated day names to full day names
  String getFullDayName(String abbreviatedDay) {
    Map<String, String> dayMap = {
      'Mon': 'Monday',
      'Tue': 'Tuesday',
      'Wed': 'Wednesday',
      'Thu': 'Thursday',
      'Fri': 'Friday',
      'Sat': 'Saturday',
      'Sun': 'Sunday',
    };
    return dayMap[abbreviatedDay] ?? abbreviatedDay; // Return the full name or the abbreviated one if not found
  }

  Future<ProductResponse> _fetchProducts() async {
    String url = AppUrl.list_products;
    try {
      final response
      = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return ProductResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching products: $e');
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<Chemist>> fetchChemists() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = await preferences.getString('uniqueID');
    print('called fetch chemist');
    String url = AppUrl.get_chemists; // Replace with your actual API URL

    // // Example headers and body parameters
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      // Add other headers if needed
    };
    //
    Map<String, dynamic> body = {
      // Add any necessary body parameters here
      "uniqueId":uniqueID
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    print('${response.statusCode}');
    print('resp:${jsonDecode(response.body)}');

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var chemistsJson = data['data'] as List;
      List<Chemist> chemists = chemistsJson.map((chemist) => Chemist.fromJson(chemist)).toList();
      return chemists;
    } else {
      throw Exception('Failed to load chemists');
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
  List<Map<String,dynamic>> _subHeadquartersData = [];
  Map<String, List<String>> _headquartersMap = {};
  int? _selectedHeadquarters;
  bool _isLoading = false;
  List<String> _specializations = [];

  Future<dynamic> fetchSpecializations(String query) async {
    if (query.isEmpty) return;
    setState(() {
      _isLoading = true;
    });
    String? url = AppUrl.specialisation;
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        setState(() {
          _specializations =
              data.map((item) => item['department'] as String).toList();
        });
      } else {
        setState(() {
          _specializations = [];
        });
      }
    } catch (e) {
      setState(() {
        _specializations.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<dynamic> adddoctors() async {
    print('add doc called...');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');

    String url = AppUrl.add_doctor_rep;

    // Collect addresses
    List<Map<String, dynamic>> addresses = schedules.map((schedule) {
      int minLength = schedule.days.length < schedule.timeSlots.length
          ? schedule.days.length
          : schedule.timeSlots.length;  // Find the minimum length

      // Combine days and time slots into one set, including startTime and endTime
      List<Map<String, dynamic>> scheduleSets = List.generate(minLength, (index) {
        return {
          "day": getFullDayName(schedule.days[index]),
            "start_time": schedule.timeSlots[index].startTime,
            "end_time": schedule.timeSlots[index].endTime,
          // "time": {
          //   "startTime": schedule.timeSlots[index].startTime,
          //   "endTime": schedule.timeSlots[index].endTime,
          // }
        };
      });

      // Return the map for this schedule
      return {
        "address": schedule.address.text,
        "latitude": schedule.latitude.text,
        "longitude": schedule.longitude.text,
        "subHeadQuarter": schedule.selectedSubHeadquarter,
        "schedule": scheduleSets,  // Add the combined day/time sets here
      };
    }).toList();

    // Format selected products
    List<Map<String, dynamic>> formattedProducts = _selectedProducts.map((product) {
      return {
        "id": product.id,
        "product": product.productName.first.name,
      };
    }).toList();

    // Format selected chemists
    List<Map<String, dynamic>> formattedChemists = _selectedChemists.map((chemist) {
      return {
        "id": chemist.id,
        "buildingName": chemist.buildingName,
        // Add other necessary fields here
      };
    }).toList();

    // Prepare the schedule sets (extract from addresses)
    List<List<Map<String, dynamic>>> scheduleSetsList = addresses.map((addr) {
      return addr['schedule'] as List<Map<String, dynamic>>;
    }).toList();

    // Flatten the schedule sets (optional: based on whether you want a single list or nested lists)
    List<Map<String, dynamic>> flattenedScheduleSets = scheduleSetsList.expand((i) => i).toList();

    // Final data to send to the backend
    Map<String, dynamic> data = {
      "firstName": 'Dr.${_firstnameController.text}',
      "lastName": _lastnameController.text,
      "qualification": _qualificationController.text,
      "gender": _gender,
      "specialization": _specialistaionController.text,
      "mobile": _mobileController.text,
      "visits": int.parse(_visitsController.text),
      "dob": _dobController.text,
      "wedding_date": _weddingDateController.text,
      "created_UniqueId": uniqueID,
      'address': addresses,  // Addresses with schedule sets
      "chemist": formattedChemists,
      "product": formattedProducts,
      "schedule": flattenedScheduleSets,  // Include the flattened schedule sets here
    };

    print('add doctor data is :$data');

    try {
      print('in try');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print('st code :${response.statusCode}');
      print('${jsonEncode(data)}');
      print('${response.body}');
      print('body:$data');

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        Navigator.pushNamedAndRemoveUntil(context, RoutesName.successsplash, (route) => false);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
        return responseData;
      } else {
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage('${e.toString()}', context);
      throw Exception('Failed to load data: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    _fetchHeadquarters();
    fetchChemists();
    _futureProducts = _fetchProducts();
  }

  Future<void> _fetchHeadquarters() async {
    setState(() {
      _isLoading = true; // Start loader before the fetch
    });

    try {
      final response = await http.get(Uri.parse(AppUrl.list_headqrts));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          setState(() {
            // Map each headquarter's name and id
            _headquartersData = List<Map<String, dynamic>>.from(data['data']);

            // Create map to store headquarters (without sub-headquarters for now)
            _headquartersMap = {
              for (var item in _headquartersData)
                item['headquarter_name'].trim(): [] // Empty list as there's no sub-headquarter in response
            };

            _isLoading = false; // Stop loader after data is loaded
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          throw Exception('Data fetch unsuccessful');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to load headquarters');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> _fetchSubHeadquarters(int headquarterId) async {
    try {
      // Prepare the request body
      final body = json.encode({
        'headquarterId': headquarterId,
      });

      final response = await http.post(
        Uri.parse(AppUrl.list_subqrts),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          setState(() {
            // Parse the sub-headquarters list from the response
            _subHeadquartersData = List<Map<String, dynamic>>.from(data['data']);
          });
        } else {
          throw Exception('Failed to load sub-headquarters');
        }
      } else {
        throw Exception('Failed to load sub-headquarters');
      }
    } catch (e) {
      print('Error fetching sub-headquarters: $e');
    }
  }




  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied.');
      } else if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Future<void> _getCurrentLocation() async {
  //   try {
  //     // Request location permission
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       // Handle location services disabled
  //       return;
  //     }
  //
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission != LocationPermission.whileInUse &&
  //           permission != LocationPermission.always) {
  //         // Handle permissions denied
  //         return;
  //       }
  //     }
  //
  //     // Fetch current location
  //     Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     // Update the TextEditingControllers with the current location
  //     setState(() {
  //       _latitudeController.text = position.latitude.toString();
  //       _longitudeController.text = position.longitude.toString();
  //
  //       print('latitude is :${_latitudeController.text}');
  //       print('longitude is :${_longitudeController.text}');
  //     });
  //   } catch (e) {
  //     // Handle errors (e.g., location services disabled or permissions denied)
  //     print(e);
  //   }
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: AppColors.primaryColor,
              )), // Replace with your desired icon
          onPressed: () {
            // Handle the button press
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Add Doctor',
          style: text40016black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    basicInfo = !basicInfo;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Basic Information ',
                      style: text50014black,
                    ),
                    basicInfo
                        ? Icon(Icons.arrow_drop_up)
                        : Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  basicInfo
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'First Name',
                                        style: text50012black,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.textfiedlColor,
                                            borderRadius: BorderRadius.circular(6)),
                                        child: TextFormField(
                                          controller: _firstnameController,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(left: 10),
                                              hintText: 'First Name',
                                              hintStyle: text50010tcolor2,
                                              counterText: ''),
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
                                      Text(
                                        'Last Name',
                                        style: text50012black,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.textfiedlColor,
                                            borderRadius: BorderRadius.circular(6)),
                                        child: TextFormField(
                                          controller: _lastnameController,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.only(left: 10),
                                              hintText: 'Last Name',
                                              hintStyle: text50010tcolor2,
                                              counterText: ''),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Mobile',
                                        style: text50012black,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.textfiedlColor,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        child: TextFormField(
                                          controller: _mobileController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.only(left: 10),
                                              border: InputBorder.none,
                                              hintText: 'Mobile Number',
                                              hintStyle: text50010tcolor2,
                                              counterText: ''),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gender',
                                        style: text50012black,
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                          decoration: BoxDecoration(
                                              color: AppColors.textfiedlColor,
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: CustomDropdown(
                                            options: [
                                              'Male',
                                              'Female',
                                              'Other'
                                            ],
                                            onChanged: (value) {
                                              _gender = value.toString();
                                            },
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Specialisation', style: text50012black),
                                SizedBox(height: 10),
                                Autocomplete<String>(
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<String>.empty();
                                    } else {
                                      fetchSpecializations(
                                          textEditingValue.text);
                                      return _specializations.where((option) {
                                        return option.toLowerCase().contains(
                                            textEditingValue.text
                                                .toLowerCase());
                                      });
                                    }
                                  },
                                  onSelected: (String selection) {
                                    _specialistaionController.text = selection;
                                  },
                                  fieldViewBuilder: (context, controller,
                                      focusNode, onEditingComplete) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.textfiedlColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: TextFormField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              EdgeInsets.only(left: 10),
                                          hintText: 'Specialisation',
                                          hintStyle: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600]),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a specialization';
                                          }
                                          return null;
                                        },
                                      ),
                                    );
                                  },
                                ),
                                if (_isLoading)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Qualification',
                              style: text50012black,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)),
                              child: TextFormField(
                                controller: _qualificationController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 10),
                                    hintText: 'Qualification',
                                    hintStyle: text50010tcolor2,
                                    counterText: ''),
                              ),
                            ),
                          ],
                        )
                      : Text(''),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Work information ',
                    style: text50014black,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //visittype
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Visit Type', style: text50012black),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _buildVisitBox(
                                label: 'Important',
                                value: 2,
                                color: AppColors.tilecolor3),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: _buildVisitBox(
                                label: 'Core',
                                value: 4,
                                color: AppColors.tilecolor2),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: _buildVisitBox(
                                label: 'Super Core',
                                value: 6,
                                color: AppColors.tilecolor1),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date of birth',
                              style: text50012black,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)),
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
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 10, 20, 0),
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
                                  DateTime initialDate = DateTime(
                                      currentDate.year,
                                      currentDate.month - 1,
                                      currentDate.day - 1);
                                  DateTime lastDate =
                                      currentDate; // Last day of the next month

                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: firstDate,
                                    initialDate: currentDate,
                                    lastDate: lastDate,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: AppColors.primaryColor,
                                          hintColor: AppColors.primaryColor,
                                          colorScheme: const ColorScheme.light(
                                              primary: AppColors.primaryColor),
                                          buttonTheme: const ButtonThemeData(
                                              textTheme:
                                                  ButtonTextTheme.primary),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedDate != null) {
                                    // Change the format of the date here
                                    String formattedDate =
                                        DateFormat('dd-MM-yyyy')
                                            .format(pickedDate);
                                    setState(() {
                                      _dobController.text = formattedDate;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value! == null && value.isEmpty) {
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
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wedding Date',
                              style: text50012black,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)),
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
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(10, 10, 20, 0),
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
                                  DateTime initialDate = DateTime(
                                      currentDate.year,
                                      currentDate.month - 1,
                                      currentDate.day - 1);
                                  DateTime lastDate =
                                      currentDate; // Last day of the next month

                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    firstDate: firstDate,
                                    initialDate: currentDate,
                                    lastDate: lastDate,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Theme(
                                        data: ThemeData.light().copyWith(
                                          primaryColor: AppColors.primaryColor,
                                          hintColor: AppColors.primaryColor,
                                          colorScheme: const ColorScheme.light(
                                              primary: AppColors.primaryColor),
                                          buttonTheme: const ButtonThemeData(
                                              textTheme:
                                                  ButtonTextTheme.primary),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );

                                  if (pickedDate != null) {
                                    // Change the format of the date here
                                    String formattedDate =
                                        DateFormat('dd-MM-yyyy')
                                            .format(pickedDate);
                                    setState(() {
                                      _weddingDateController.text =
                                          formattedDate;
                                    });
                                  }
                                },
                                validator: (value) {
                                  if (value! == null && value.isEmpty) {
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
                  SizedBox(
                    height: 10,
                  ),
                  //products
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Products',
                        style: text50012black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      productwidget1(context),
                    ],
                  ),
                  SizedBox(height: 10,),
                  //chemist
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chemists',style: text50012black,),
                      SizedBox(height: 10,),
                      chemistwidget1(context),
                    ],
                  ),
                  SizedBox(height: 10),
                  //headquarters
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HeadQuaters',
                        style: text50012black,
                      ),
                      SizedBox(
                        height: 10,
                      ),

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
                              child: DropdownButton<int>(
                                hint: Text("Select Headquarters"),
                                value: _selectedHeadquarters, // This holds the selected headquarter ID
                                items: _headquartersData.map((item) {
                                  return DropdownMenuItem<int>(
                                    value: item['id'], // Use the ID of the headquarters as the value
                                    child: Text(item['headquarter_name'].trim()), // Display the name of the headquarters
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedHeadquarters = value; // Update the selected headquarter ID
                                    _fetchSubHeadquarters(_selectedHeadquarters!);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            ...schedules.asMap().entries.map((entry) {
                              int index = entry.key;
                              ScheduleNew schedulenew = entry.value;
                              return Container(
                                margin: EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                    // border: Border.all()
                                    ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(height: 1,color: AppColors.blackColor,),
                                    SizedBox(height: 20,),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Create Schedule',
                                            style: text50012black),
                                        if (schedules.length > 1)
                                          CircleAvatar(
                                            child: IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.black),
                                              onPressed: () {
                                                setState(() {
                                                  schedules.removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                        CircleAvatar(
                                          child: IconButton(
                                            icon: Icon(Icons.add,
                                                color: Colors.black),
                                            onPressed: () {
                                              setState(() {
                                                schedules.add(ScheduleNew());
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text('SubHeadQuarters',
                                        style: text50012black),
                                    SizedBox(height: 10),
                                    _isLoading
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.textfiedlColor,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                DropdownButton<String>(
                                                  value: schedulenew
                                                      .selectedSubHeadquarter,
                                                  hint: Text(
                                                      'Select a sub-headquarter'),
                                                  items: _subHeadquartersData
                                                      .expand((item) {
                                                    return (item['subheadquarter'] as String)
                                                        .split('\n')
                                                        .where((sub) =>
                                                            sub.isNotEmpty)
                                                        .map((sub) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: sub,
                                                        child: Text(sub),
                                                      );
                                                    }).toList();
                                                  }).toList(),
                                                  onChanged:
                                                      (selectedSubHeadquarter) {
                                                    setState(() {
                                                      schedulenew
                                                              .selectedSubHeadquarter =
                                                          selectedSubHeadquarter;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                    SizedBox(height: 20),
                                    dayTimeSelector(schedulenew),
                                    Text(
                                      'Address',
                                      style: text50012black,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.textfiedlColor,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      child: TextFormField(
                                        controller: schedulenew.address,
                                        // _addressController,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.only(left: 10),
                                            hintText: 'Address',
                                            hintStyle: text50010tcolor2,
                                            counterText: ''),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .start, // Align all children to the start
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center, // Align children in the center vertically
                                      children: [
                                        // Button on the left side
                                        Column(
                                          children: [
                                            SizedBox(height: 25,),
                                            SizedBox(
                                              height:
                                                  50, // Set the height of the button
                                              width:
                                                  50, // Set the width of the button
                                              child: ElevatedButton(
                                                onPressed:()async{
                                                  try {
                                                    Position position = await _getCurrentLocation();
                                                    setState(() {
                                                      schedulenew.latitude.text = position.latitude.toString();
                                                      schedulenew.longitude.text = position.longitude.toString();
                                                    });
                                                    print('Latitude: ${schedulenew.latitude}, Longitude: ${schedulenew.longitude}');
                                                  } catch (e) {
                                                    print('Error fetching location: $e');
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor: AppColors
                                                      .textfiedlColor, // Button color
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6), // Adjust button corner radius
                                                  ),
                                                  padding: EdgeInsets
                                                      .zero, // Remove default padding
                                                ),
                                                child: Icon(
                                                  CupertinoIcons.location_solid,
                                                  color: AppColors.primaryColor,
                                                  size: 24, // Adjust icon size
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                            width:
                                                20), // Space between the button and the fields
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Latitude',
                                                  style: text50012black),
                                              SizedBox(height: 10),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.textfiedlColor,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: TextFormField(
                                                  controller:
                                                      schedulenew.latitude,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 10),
                                                    hintText: 'Latitude',
                                                    hintStyle: text50010tcolor2,
                                                    counterText: '',
                                                  ),
                                                  readOnly: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            width:
                                                20), // Space between the latitude and longitude fields
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Longitude',
                                                  style: text50012black),
                                              SizedBox(height: 10),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.textfiedlColor,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: TextFormField(
                                                  controller:
                                                      schedulenew.longitude,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            left: 10),
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
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),

                      // Text('Areas', style: text50012black),
                      // SizedBox(height: 10),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: AppColors.textfiedlColor,
                      //     borderRadius: BorderRadius.circular(6),
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       for (int i = 0; i < _areasList.length; i++)
                      //         Padding(
                      //           padding: const EdgeInsets.symmetric(
                      //               vertical: 8.0, horizontal: 16.0),
                      //           child: Row(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceBetween,
                      //             children: [
                      //               Expanded(
                      //                 child: TextFormField(
                      //                   initialValue: _areasList[i],
                      //                   decoration: InputDecoration(
                      //                     hintText: 'Area',
                      //                     hintStyle: text50010tcolor2,
                      //                     border: InputBorder.none,
                      //                   ),
                      //                   onChanged: (value) {
                      //                     _areasList[i] = value;
                      //                   },
                      //                 ),
                      //               ),
                      //               IconButton(
                      //                 icon:
                      //                     Icon(Icons.delete, color: Colors.red),
                      //                 onPressed: () => _removeArea(i),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //             vertical: 8.0, horizontal: 16.0),
                      //         child: Row(
                      //           children: [
                      //             Expanded(
                      //               child: TextFormField(
                      //                 decoration: InputDecoration(
                      //                   hintText: 'Add new area',
                      //                   hintStyle: text50010tcolor2,
                      //                   border: InputBorder.none,
                      //                 ),
                      //                 onChanged: (value) {
                      //                   if (_areasList.isEmpty ||
                      //                       _areasList.last.isNotEmpty) {
                      //                     _addArea();
                      //                   }
                      //                 },
                      //               ),
                      //             ),
                      //             IconButton(
                      //               icon: Icon(Icons.add, color: Colors.green),
                      //               onPressed: _addArea,
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Text(
                      //   'Address',
                      //   style: text50012black,
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Container(
                      //   decoration: BoxDecoration(
                      //       color: AppColors.textfiedlColor,
                      //       borderRadius: BorderRadius.circular(6)),
                      //   child: TextFormField(
                      //     controller: _addressController,
                      //     decoration: InputDecoration(
                      //         border: InputBorder.none,
                      //         contentPadding: EdgeInsets.only(left: 10),
                      //         hintText: 'Address',
                      //         hintStyle: text50010tcolor2,
                      //         counterText: ''),
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 10,
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment
                      //       .start, // Align all children to the start
                      //   crossAxisAlignment: CrossAxisAlignment
                      //       .center, // Align children in the center vertically
                      //   children: [
                      //     // Button on the left side
                      //     Padding(
                      //       padding: const EdgeInsets.only(top: 25.0),
                      //       child: SizedBox(
                      //         height: 50, // Set the height of the button
                      //         width: 50, // Set the width of the button
                      //         child: ElevatedButton(
                      //           onPressed: _getCurrentLocation,
                      //           style: ElevatedButton.styleFrom(
                      //             backgroundColor:
                      //                 AppColors.textfiedlColor, // Button color
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(
                      //                   6), // Adjust button corner radius
                      //             ),
                      //             padding:
                      //                 EdgeInsets.zero, // Remove default padding
                      //           ),
                      //           child: Icon(
                      //             CupertinoIcons.location_solid,
                      //             color: AppColors.primaryColor,
                      //             size: 24, // Adjust icon size
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(
                      //         width:
                      //             20), // Space between the button and the fields
                      //     Expanded(
                      //       flex: 2,
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text('Latitude', style: text50012black),
                      //           SizedBox(height: 10),
                      //           Container(
                      //             decoration: BoxDecoration(
                      //               color: AppColors.textfiedlColor,
                      //               borderRadius: BorderRadius.circular(6),
                      //             ),
                      //             child: TextFormField(
                      //               controller: _latitudeController,
                      //               decoration: InputDecoration(
                      //                 border: InputBorder.none,
                      //                 contentPadding: EdgeInsets.only(left: 10),
                      //                 hintText: 'Latitude',
                      //                 hintStyle: text50010tcolor2,
                      //                 counterText: '',
                      //               ),
                      //               readOnly: true,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //     SizedBox(
                      //         width:
                      //             20), // Space between the latitude and longitude fields
                      //     Expanded(
                      //       flex: 2,
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           Text('Longitude', style: text50012black),
                      //           SizedBox(height: 10),
                      //           Container(
                      //             decoration: BoxDecoration(
                      //               color: AppColors.textfiedlColor,
                      //               borderRadius: BorderRadius.circular(6),
                      //             ),
                      //             child: TextFormField(
                      //               controller: _longitudeController,
                      //               decoration: InputDecoration(
                      //                 border: InputBorder.none,
                      //                 contentPadding: EdgeInsets.only(left: 10),
                      //                 hintText: 'Longitude',
                      //                 hintStyle: text50010tcolor2,
                      //                 counterText: '',
                      //               ),
                      //               readOnly: true,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ],
                      // ),





                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 110,
                            child: InkWell(
                              onTap: () {
                                print('schedule:${schedules}');
                                // if (_formKey.currentState!.validate()) {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //     const SnackBar(content: Text('Processing Data'))
                                  // );
                                  adddoctors();
                                // }

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
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width: 110,
                              child: Defaultbutton(
                                text: 'Cancel',
                                bgColor: AppColors.whiteColor,
                                bordervalues: Border.all(
                                    width: 1, color: AppColors.primaryColor),
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
              SizedBox(
                height: 10,
              ),
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
        width: MediaQuery.of(context).size.width / 3.5,
        decoration: BoxDecoration(
          color: AppColors.textfiedlColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _selectedVisits == value ? Colors.brown : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                width: 20,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        bottomLeft: Radius.circular(6))),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Text(label, style: text50012black),
          ],
        ),
      ),
    );
  }

  @override
  Widget productwidget1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            _showProductSelectionDialog(context);
          },
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textfiedlColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Select Products',
                  hintStyle: text50010tcolor2,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                controller: _textProductController,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          children: _selectedProducts.map((product) {
            return Chip(
              label: Text(product.productName.first.name),
              onDeleted: () {
                setState(() {
                  _selectedProducts.remove(product);
                  _updateSelectedProductsText();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showProductSelectionDialog(BuildContext context) async {
    ProductResponse productResponse = await _futureProducts;

    List<ProductData> result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Select Products'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: productResponse.data.map((product) {
                    final isSelected = _selectedProducts.contains(product);
                    return ListTile(
                      title: Text(product.productName.first.name),
                      leading: isSelected
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.circle_outlined, color: Colors.grey),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedProducts.remove(product);
                          } else {
                            _selectedProducts.add(product);
                          }
                          _updateSelectedProductsText();
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedProducts);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedProducts = result;
        _updateSelectedProductsText();
      });
    }
  }

  void _updateSelectedProductsText() {
    setState(() {
      _selectedProductsText =
          _selectedProducts.map((c) => c.productName.first.name).join(', ');
      _textProductController.text = _selectedProductsText;
    });
    // This function is kept empty as we are not using the text directly.
  }

  void _showChemistSelectionDialog(BuildContext context) async {
    List<Chemist> chemistResponse = await fetchChemists();

    List<Chemist> result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Select Chemists'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    ...chemistResponse.map((chemist) {
                      final isSelected = _selectedChemists.contains(chemist);
                      return ListTile(
                        title: Text(chemist.buildingName),
                        leading: isSelected
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.circle_outlined, color: Colors.grey),
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedChemists.remove(chemist);
                            } else {
                              _selectedChemists.add(chemist);
                            }
                            _updateSelectedChemistsText();
                          });
                        },
                      );
                    }).toList(),
                    ListTile(
                      title: Text('Add New Chemist'),
                      leading: Icon(Icons.add, color: Colors.blue),
                      onTap: () async {
                        Chemist newChemist = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Adding_chemistmngr(),
                          ),
                        );
                        if (newChemist != null) {
                          setState(() {
                            chemistResponse.add(newChemist);
                            _selectedChemists.add(newChemist);
                            _updateSelectedChemistsText();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedChemists);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedChemists = result;
        _updateSelectedChemistsText();
      });
    }
  }

  void _updateSelectedChemistsText() {
    setState(() {
      _selectedChemistsText = _selectedChemists.map((c) => c.buildingName).join(', ');
      _textChemistController.text = _selectedChemistsText;
    });
  }


  @override
  Widget chemistwidget1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            _showChemistSelectionDialog(context);
          },
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textfiedlColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Select Chemists',
                  hintStyle: text50010tcolor2,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                controller: _textChemistController,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          children: _selectedChemists.map((chemist) {
            return Chip(
              label: Text(chemist.buildingName),
              onDeleted: () {
                setState(() {
                  _selectedChemists.remove(chemist);
                  _updateSelectedChemistsText();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  //schedule widgets
  Widget dayTimeSelector(ScheduleNew schedulenew) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...schedulenew.timeSlots.expand((slot) {
          return [
            Row(
              children: [
                Expanded(
                  child: dayDropdown(slot, schedulenew),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    child: timeField(
                      context,
                      slot.startTime ?? '00:00',
                      (selectedTime) {
                        setState(() {
                          slot.startTime = selectedTime;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: timeField(
                    context,
                    slot.endTime ?? '00:00',
                    (selectedTime) {
                      setState(() {
                        slot.endTime = selectedTime;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  child: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        schedulenew.timeSlots.add(TimeSlot(
                            day: 'Mon')); // Default day for new TimeSlot
                      });
                    },
                  ),
                ),
                if (schedulenew.timeSlots.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        if (schedulenew.timeSlots.length > 1) {
                          schedulenew.timeSlots.remove(slot);
                        }
                      });
                    },
                  ),
              ],
            ),
            SizedBox(height: 10,)
          ];
        }).toList(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget dayDropdown(TimeSlot slot, ScheduleNew schedulenew) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textfiedlColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: DropdownButton<String>(
          value: slot.day, // Use the day of the current slot
          items: schedulenew.days.map((String day) {
            return DropdownMenuItem<String>(
              value: day,
              child: Text(day),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              slot.day = newValue!; // Update the day for this specific slot
            });
          },
        ),
      ),
    );
  }

  Widget timeField(
      BuildContext context, String time, Function(String) onTimeSelected) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (selectedTime != null) {
          final formattedTime = selectedTime.format(context);
          onTimeSelected(formattedTime);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.textfiedlColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(time.isNotEmpty ? time : '00:00',
            style: TextStyle(fontSize: 12)),
      ),
    );
  }
}


class SubHeadquarter {
  int id;
  int headquarterId;
  String subheadquarter;

  SubHeadquarter({
    required this.id,
    required this.headquarterId,
    required this.subheadquarter,
  });

  // Factory constructor to create an instance from JSON
  factory SubHeadquarter.fromJson(Map<String, dynamic> json) {
    return SubHeadquarter(
      id: json['id'],
      headquarterId: json['headquarterId'],
      subheadquarter: json['subheadquarter'],
    );
  }

  // Method to convert an instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headquarterId': headquarterId,
      'subheadquarter': subheadquarter,
    };
  }
}

class SubHeadquarterResponse {
  bool error;
  bool success;
  String message;
  List<SubHeadquarter> data;

  SubHeadquarterResponse({
    required this.error,
    required this.success,
    required this.message,
    required this.data,
  });

  // Factory constructor to parse the API response and create an instance
  factory SubHeadquarterResponse.fromJson(Map<String, dynamic> json) {
    return SubHeadquarterResponse(
      error: json['error'],
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List<dynamic>)
          .map((item) => SubHeadquarter.fromJson(item))
          .toList(),
    );
  }

  // Method to convert the entire response back to JSON
  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
