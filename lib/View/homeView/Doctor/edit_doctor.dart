import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../Util/Routes/routes_name.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../constants/styles.dart';
import '../../../defaultButton.dart';
import '../../../res/app_url.dart';
import '../../../widgets/customDropDown.dart';
import '../Employee/add_rep.dart';
import '../home_view_rep.dart';

class EditDoctor extends StatefulWidget {
  String doctorID;

  EditDoctor({required this.doctorID,super.key});
  @override
  _EditDoctorState createState() => _EditDoctorState();
}

class _EditDoctorState extends State<EditDoctor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Define controllers for each form field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _visitsController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _weddingDateController = TextEditingController();
  // final TextEditingController _

  late Future<ProductResponse> _futureProducts;
  List<ProductData> _selectedProducts = [];
  String _selectedProductsText = '';

  List<dynamic> doctorDetails = [];




  // List<Chemist> chemists = [];
  // String selectedProductsText = '';
  // List<Chemist> selectedChemist = [];
  // String selectedChemistsText = '';

  TextEditingController _textChemistController = TextEditingController();
  List<Chemist> _selectedChemists = [];
  String _selectedChemistsText = '';

  @override
  void initState() {
    print('passed id:${widget.doctorID}');
    // TODO: implement initState
    _futureProducts = _fetchProducts();
    fetchChemists();
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
    _qualificationController.dispose();
    _genderController.dispose();
    _specializationController.dispose();
    _mobileController.dispose();
    _visitsController.dispose();
    _dobController.dispose();
    _weddingDateController.dispose();
    super.dispose();
  }

  Future<dynamic> single_doctordetails() async {
    print('called meee...');
    String url = AppUrl.single_doctor_details;
    print('url :${AppUrl.single_doctor_details}');
    Map<String,dynamic> docdata = {
      "dr_id":int.parse(widget.doctorID)
    };
    try {
      print('entered..here...');
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(docdata),
      );
      print('st code is :${response.statusCode}');
      if (response.statusCode == 200) {
        print('passed....');
        var responseData = jsonDecode(response.body);
        doctorDetails.clear();
        doctorDetails.addAll(responseData['data']);
        _nameController.text =responseData['data'][0]['doc_name'];
        _qualificationController.text = responseData['data'][0]['doc_qualification'];
        _genderController.text = responseData['data'][0]['gender'].toString();
        _specializationController.text = responseData['data'][0]['specialization'];
        _mobileController.text = responseData['data'][0]['mobile'];
        _visitsController.text = responseData['data'][0]['no_of_visits'].toString();
        _dobController.text = responseData['data'][0]['date_of_birth'];
        _weddingDateController.text = responseData['data'][0]['wedding_date'];

        // Populate the selected products
        _selectedProducts = (responseData['data'][0]['products'] as List).map((product) {
          return ProductData(
            id: product['id'],
            productName: [ProductName(name: product['product'])], createdBy: '', quantity: 0, status: '',
          );
        }).toList();

        // Populate the selected chemists
        _selectedChemists = (responseData['data'][0]['chemist'] as List).map((chemist) {
          return Chemist(
            // id: chemist['id'],
            id: 1,

            buildingName: chemist['address'], mobile: '0', email: 'a', licenseNumber: '123456', address: 'adsf', dateOfBirth: '12-05-2024', status: 'active',
            // Add other necessary fields here
          );
        }).toList();

        // Populate addresses
        // fields = (responseData['data'][0]['addressDetail'] as List).expand((addressGroup) {
        //   return addressGroup.map((address) {
        //     return FieldEntry(
        //       placeController: TextEditingController(text: address['address']['address']),
        //       latController: TextEditingController(), // Populate with latitude if available
        //       lonController: TextEditingController(), // Populate with longitude if available
        //     );
        //   }).toList();
        // }).toList() as List<FieldEntry>;

        print('ppp:${responseData['data'][0]['products']}');
        // _selectedChemists = responseData['data'][0]['chemist'];
        print('sp products:$_selectedProducts');
        print('sp chemists:$_selectedChemists');
        return responseData['data'];
      } else {
        print('its here.....');
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      }
    } catch (e) {
      Utils.flushBarErrorMessage('${e.toString()}', context);
      throw Exception('Failed to load data: $e');
    }
  }

  // Future<dynamic> single_doctordetails() async {
  //   print('called meee...');
  //   String url = AppUrl.single_doctor_details;
  //   print('url :${AppUrl.single_doctor_details}');
  //   Map<String, dynamic> docdata = {
  //     "dr_id": int.parse(widget.doctorID)
  //   };
  //   try {
  //     print('entered..here...');
  //     var response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(docdata),
  //     );
  //     print('st code is :${response.statusCode}');
  //     if (response.statusCode == 200) {
  //       print('passed....');
  //       var responseData = jsonDecode(response.body);
  //       var doctorData = responseData['data'][0];
  //
  //       doctorDetails.clear();
  //       doctorDetails.addAll(doctorData);
  //
  //       _nameController.text = doctorData['doc_name'];
  //       _qualificationController.text = doctorData['doc_qualification'];
  //       _genderController.text = doctorData['gender'].toString();
  //       _specializationController.text = doctorData['specialization'];
  //       _mobileController.text = doctorData['mobile'];
  //       _visitsController.text = doctorData['no_of_visits'].toString();
  //       _dobController.text = doctorData['date_of_birth'];
  //       _weddingDateController.text = doctorData['wedding_date'];
  //
  //       // Populate the selected products
  //       _selectedProducts = (doctorData['products'] as List).map((product) {
  //         return DoctorProduct(
  //           id: product['id'],
  //           productName: [DoctorProductName(name: product['product'])],
  //         );
  //       }).cast<ProductData>().toList();
  //
  //       // Populate the selected chemists
  //       _selectedChemists = (doctorData['chemist'] as List).map((chemist) {
  //         return DoctorChemist(
  //           id: chemist['id'],
  //           buildingName: chemist['address'],
  //           // Add other necessary fields here
  //         );
  //       }).cast<Chemist>().toList();
  //
  //       // Populate addresses
  //       fields = (doctorData['addressDetail'] as List).expand((addressGroup) {
  //         return addressGroup.map((address) {
  //           return NewFieldEntry(
  //             placeController: TextEditingController(text: address['address']['address']),
  //             latController: TextEditingController(), // Populate with latitude if available
  //             lonController: TextEditingController(), // Populate with longitude if available
  //           );
  //         }).toList();
  //       }).toList() as List<FieldEntry>;
  //
  //       print('sp products:$_selectedProducts');
  //       print('sp chemists:$_selectedChemists');
  //       return doctorData;
  //     } else {
  //       print('its here.....');
  //       var responseData = jsonDecode(response.body);
  //       Utils.flushBarErrorMessage('${responseData['message']}', context);
  //     }
  //   } catch (e) {
  //     Utils.flushBarErrorMessage('${e.toString()}', context);
  //     throw Exception('Failed to load data: $e');
  //   }
  // }




  Future<dynamic> editdoctors() async {
    print('add doc called...');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = preferences.getString('uniqueID');
    String? userID = preferences.getString('userID');

    String url = AppUrl.edit_doctor;



    // Collect addresses
    List<Map<String, String>> addresses = fields.map((field) {
      return {
        "address": field.placeController.text,
        "latitude": field.latController.text,
        "longitude": field.lonController.text,
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

    Map<String, dynamic> data = {
      "created_UserId":uniqueID,
      "dr_id":widget.doctorID,
      "dr_name": _nameController.text,
      "qualification": _qualificationController.text,
      "gender": _genderController.text,
      "specialization": _specializationController.text,
      "mobile": _mobileController.text,
      "visits": int.parse(_visitsController.text),
      "dob": _dobController.text,
      "wedding_date": _weddingDateController.text,
      "products": formattedProducts,
      "chemist": formattedChemists,
      // 'address':addresses,
      "modified_by":uniqueID
    };

    try {
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
        Navigator.pushNamedAndRemoveUntil(context, RoutesName.successsplash, (route) => false,);
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

  Future<List<Chemist>> fetchChemists() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueID = await preferences.getString('uniqueID');
    print('called fetch chemist');
    String url = AppUrl.get_chemists; // Replace with your actual API URL

    // // Example headers and body parameters
    // Map<String, String> headers = {
    //   'Content-Type': 'application/json',
    //   // Add other headers if needed
    // };
    //
    // Map<String, dynamic> body = {
    //   // Add any necessary body parameters here
    //   "uniqueId":uniqueID
    // };

    final response = await http.get(
      Uri.parse(url),
      // headers: headers,
      // body: jsonEncode(body),
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

  //address widgets
   List<FieldEntry> fields = [FieldEntry()];

  Future<void> fetchLatLon(String placeName, TextEditingController latController, TextEditingController lonController) async {
    try {
      final coordinates = await getLatLon(placeName);
      setState(() {
        latController.text = coordinates['lat']!;
        lonController.text = coordinates['lon']!;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, String>> getLatLon(String placeName) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$placeName&format=json&limit=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        final lat = data[0]['lat'];
        final lon = data[0]['lon'];
        return {'lat': lat, 'lon': lon};
      } else {
        throw Exception('Place not found');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<String>> fetchSuggestions(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<String>((item) => item['display_name']).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  void addField() {
    setState(() {
      fields.add(FieldEntry());
    });
  }

  void removeField(int index) {
    setState(() {
      fields.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.whiteColor),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
          ),
        ],
        centerTitle: true,
        title: const Text(
          'Edit Doctor',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: FutureBuilder(
        future: single_doctordetails(),
        builder: (context,snapshot) {
          print('snooop:${snapshot.data}');
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }else if(snapshot.hasError){
            return Center(child: Text('Some error occured !'),);
          }else if(snapshot.hasData){
            return SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
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
                                          // labelText: 'Name',
                                          hintText: 'Name',
                                          hintStyle: text50010tcolor2
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a name';
                                        }
                                        return null;
                                      },
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
                                          // labelText: 'Qualification',,
                                          hintText: 'Qualification',
                                          hintStyle: text50010tcolor2,
                                          contentPadding: EdgeInsets.only(left: 10)
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a qualification';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
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
                                  Text('Gender',style: text50012black,),
                                  SizedBox(height: 10,),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.textfiedlColor,
                                        borderRadius: BorderRadius.circular(6)
                                    ),
                                    child: CustomDropdown(
                                      hintText: _genderController.text,
                                      options: ['Male','Female','Other'],
                                      onChanged: (value){
                                        _genderController.text = value.toString();
                                      },
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
                                  Text('Mobile Number',style: text50012black,),
                                  SizedBox(height: 10,),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: AppColors.textfiedlColor,
                                        borderRadius: BorderRadius.circular(6)
                                    ),
                                    child: TextFormField(
                                      controller: _mobileController,
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(left: 10),
                                          // labelText: 'Mobile',
                                          hintStyle: text50010tcolor2,
                                          hintText: 'Mobile Number',
                                          counterText: ''
                                      ),
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a mobile number';
                                        }
                                        return null;
                                      },
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
                            Text('Specialisation',style: text50012black,),
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: TextFormField(
                                controller: _specializationController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 10),
                                    // labelText: 'Specialization',
                                    hintText: 'Specialisation',
                                    hintStyle: text50010tcolor2
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a specialization';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Number of visits',style: text50012black,),
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child:  TextFormField(
                                controller: _visitsController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(left: 10),
                                  // labelText: 'Specialization',
                                  hintText: 'No of visits',
                                  hintStyle: text50010tcolor2,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a specialization';
                                  }
                                  return null;
                                },
                              ),
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
                                        DateTime lastDate = DateTime(2500); // Last day of the next month

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
                                        DateTime lastDate = DateTime(2500); // Last day of the next month

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
                            Text('Products',style: text50012black,),
                            SizedBox(height: 10,),
                            productwidget1(context),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chemists',style: text50012black,),
                            SizedBox(height: 10,),
                            chemistwidget1(context),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Text('Addresses',style: text50012black,),
                        SizedBox(height: 10,),
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(width: 1,color: Colors.grey)
                            ),
                            height: 300,
                            child: addresswidget(context)),
                        // Container(
                        //   height: 300,
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(6),
                        //       border: Border.all(width: 1,color: Colors.grey)
                        //     ),
                        //     child: AddressAddingWidget()),
                        SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 3,
                              child: InkWell(
                                onTap: () {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Processing Data'))
                                    );
                                    editdoctors();
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
                                width: MediaQuery.of(context).size.width / 3,
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
                  ),
                ),
              ),
            );
          }
          return Center(child: Text('Some error occured !, Please restart your application.'),);
        }
      ),
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
    // This function is kept empty as we are not using the text directly.
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
                controller: TextEditingController(text: _selectedProductsText),
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
                  children: chemistResponse.map((chemist) {
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

  @override
  Widget addresswidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline_sharp,color: AppColors.primaryColor,),
                onPressed: addField,
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline,color: AppColors.primaryColor,),
                onPressed: fields.length > 1 ? () => removeField(fields.length - 1) : null,
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: fields.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: TypeAheadField(
                                controller: fields[index].placeController,
                                suggestionsCallback: (pattern) async {
                                  return await fetchSuggestions(pattern);
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion),
                                  );
                                },
                                onSelected: (String value) {
                                  fields[index].placeController.text = value;
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(Icons.location_on,color: AppColors.primaryColor,),
                            onPressed: () {
                              fetchLatLon(fields[index].placeController.text, fields[index].latController, fields[index].lonController);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: TextField(
                                controller: fields[index].latController,
                                decoration: InputDecoration(
                                    labelText: 'Latitude',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 10)
                                ),
                                readOnly: true,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppColors.textfiedlColor,
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              child: TextField(
                                controller: fields[index].lonController,
                                decoration: InputDecoration(
                                    labelText: 'Longitude',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.only(left: 10)
                                ),
                                readOnly: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class NewFieldEntry {
  final TextEditingController placeController;
  final TextEditingController latController;
  final TextEditingController lonController;

  NewFieldEntry({required this.placeController, required this.latController, required this.lonController});
}


class ProductResponse {
  bool error;
  bool success;
  String message;
  List<ProductData> data;

  ProductResponse({
    required this.error,
    required this.success,
    required this.message,
    required this.data,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<ProductData> products =
    dataList.map((data) => ProductData.fromJson(data)).toList();

    return ProductResponse(
      error: json['error'],
      success: json['success'],
      message: json['message'],
      data: products,
    );
  }
}

class ProductData {
  int id;
  String createdBy;
  List<ProductName> productName;
  int quantity;
  String status;

  ProductData({
    required this.id,
    required this.createdBy,
    required this.productName,
    required this.quantity,
    required this.status,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    var productNameList = json['product_name'] as List;
    List<ProductName> productNames =
    productNameList.map((name) => ProductName.fromJson(name)).toList();

    return ProductData(
      id: json['id'],
      createdBy: json['created_by'],
      productName: productNames,
      quantity: json['quantity'],
      status: json['status'] == "Inctive" ? "Inactive" : json['status'],
    );
  }
}

class ProductName {
  String name;

  ProductName({required this.name});

  factory ProductName.fromJson(Map<String, dynamic> json) {
    return ProductName(
      name: json['name'] is String ? json['name'] : json['name'].toString(),
    );
  }
}



class Chemist {
  final int id;
  final String buildingName;
  final String mobile;
  final String email;
  final String licenseNumber;
  final String address;
  final String dateOfBirth;
  final String status;

  Chemist({
    required this.id,
    required this.buildingName,
    required this.mobile,
    required this.email,
    required this.licenseNumber,
    required this.address,
    required this.dateOfBirth,
    required this.status,
  });

  factory Chemist.fromJson(Map<String, dynamic> json) {
    return Chemist(
      id: json['id'],
      buildingName: json['building_name'],
      mobile: json['mobile'],
      email: json['email'],
      licenseNumber: json['license_number'],
      address: json['address'],
      dateOfBirth: json['date_of_birth'],
      status: json['status'],
    );
  }
}

class DoctorProduct {
  final int id;
  final List<DoctorProductName> productName;

  DoctorProduct({required this.id, required this.productName});
}

class DoctorProductName {
  final String name;

  DoctorProductName({required this.name});
}

class DoctorChemist {
  final int id;
  final String buildingName;

  DoctorChemist({required this.id, required this.buildingName});
}

class DoctorAddressField {
  final TextEditingController placeController;
  final TextEditingController latController;
  final TextEditingController lonController;

  DoctorAddressField({required this.placeController, required this.latController, required this.lonController});
}

