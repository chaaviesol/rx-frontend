import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Util/Routes/routes_name.dart';
import '../../../Util/Utils.dart';
import '../../../app_colors.dart';
import '../../../constants/styles.dart';
import '../../../res/app_url.dart';
import '../home_view_rep.dart';

class ExpenseRequestPage extends StatefulWidget {
  const ExpenseRequestPage({super.key});

  @override
  State<ExpenseRequestPage> createState() => _ExpenseRequestPageState();
}

class _ExpenseRequestPageState extends State<ExpenseRequestPage> {
  final _myformKey = GlobalKey<FormState>();

  List<String> listofdoctors = [];
  String? selectdDoctor;

  TextEditingController reasonController = TextEditingController();
  TextEditingController dateInput = TextEditingController();
  TextEditingController amount = TextEditingController();

  String? _filePath;

  Future<void> _pickExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    } else {
      // User canceled the picker
    }
  }

  Map<String, int> doctorMap = {};
  String? selectedDoctor;
  int? selectedDoctorId;
  late Future<Map<String, int>> _doctorsFuture;

  List<DateTime> _dates = [];
  DateTime? _selectedDate;
  late Future<List<DateTime>> _datesFuture;

  Future<Map<String, int>> getDoctors() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueId = preferences.getString('uniqueID');
    String url = AppUrl.getdoctors;
    Map<String, dynamic> data = {"rep_UniqueId": uniqueId};
print('id is ${uniqueId}');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        Map<String, int> doctorsMap = {};
        for (var doctor in responseData['data']) {
          doctorsMap[doctor['firstName']] = doctor['id'];
        }
        return doctorsMap;
      } else {
        var responseData = jsonDecode(response.body);
        // Handle the error
        throw Exception('Failed to load data: ${responseData['message']}');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<List<DateTime>> fetchAvailableDates() async {
    if(selectedDoctorId == null){
      Utils.flushBarErrorMessage('Please pick a doctor first', context);
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueId = preferences.getString('uniqueID');
    var data = {
      "requesterUniqueId":1,
      "docId":selectedDoctorId
    };
    String url = AppUrl.getvisitedDates; // Replace with your API URL
    final response = await http.post(Uri.parse(url),
    body: jsonEncode(data),
      headers: {
        'Content-Type': 'application/json',
      }, );

    if (response.statusCode == 200) {
      print('dates getting success....');
      var responseData = jsonDecode(response.body);
      List<dynamic> datesJson = responseData['data'];
      _dates = datesJson.map((dateJson) {
        return DateTime.parse(dateJson['datetime']);
      }).toList();
      return _dates;
    } else {
      throw Exception('Failed to load dates');
    }
  }

  @override
  void initState() {
    _doctorsFuture = getDoctors();
    super.initState();
  }

  List<dynamic> leavedata = [];

  // Future<void> leaveBalance() async {
  //   Map<String, dynamic> mydata = {
  //     "staff_id": Utils.empId,
  //   };
  //   try {
  //     print('tried');
  //     print(jsonEncode(mydata));
  //     final response = await http.post(
  //       Uri.parse(AppUrls.leaveTotal),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(mydata),
  //     );
  //
  //
  //     print(response.statusCode);
  //     if (response.statusCode == 200) {
  //       var responses = jsonDecode(response.body);
  //       print('Aaaaaa${responses}');
  //       //  If the server returns a 200 OK response, parse the JSON
  //       final data = json.decode(response.body);
  //
  //       setState(() {
  //         leavedata.clear();
  //         leavedata = data['data'];
  //       });
  //
  //     } else {
  //       var responses = jsonDecode(response.body);
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //
  //     print('Error: $e');
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: const Text(
      //     'Expense request',
      //     style: TextStyle(),
      //   ),
      //   centerTitle: true,
      //   leading: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Container(
      //       decoration: BoxDecoration(
      //         color: AppColors.primaryColor, // Replace with your desired color
      //         borderRadius: BorderRadius.circular(6),
      //       ),
      //       child: InkWell(
      //           onTap: () {
      //             Navigator.pop(context);
      //           },
      //           child: const Icon(Icons.arrow_back,
      //               color: Colors.white)), // Adjust icon color
      //     ),
      //   ),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.only(right: 20.0),
      //       child: ProfileIconWidget(userName: Utils.userName![0].toString().toUpperCase() ?? 'N?A',),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _myformKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'Expense Request',
                        style: text40016black,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Select Doctor',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FutureBuilder<Map<String, int>>(
                                  future: _doctorsFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Some error occurred!');
                                    } else if (snapshot.hasData) {
                                      doctorMap = snapshot.data!;

                                      return Autocomplete<String>(
                                        optionsBuilder: (TextEditingValue
                                            textEditingValue) {
                                          final query = textEditingValue.text;
                                          if (query.isEmpty) {
                                            return Iterable<String>.empty();
                                          }
                                          return doctorMap.keys
                                              .where((doctorName) {
                                            return doctorName
                                                .toLowerCase()
                                                .contains(query.toLowerCase());
                                          });
                                        },
                                        onSelected: (String selected) {
                                          setState(() {
                                            selectedDoctor = selected;
                                            selectedDoctorId =
                                                doctorMap[selected];
                                            print('select doctor id:$selectedDoctorId');
                                          });
                                        },
                                        fieldViewBuilder: (BuildContext context,
                                            TextEditingController
                                                textEditingController,
                                            FocusNode focusNode,
                                            VoidCallback onFieldSubmitted) {
                                          return TextField(
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            decoration: InputDecoration(
                                              hintText: 'Select a doctor',
                                              filled: true,
                                              fillColor:
                                                  AppColors.textfiedlColor,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                          );
                                        },
                                        optionsViewBuilder:
                                            (BuildContext context,
                                                AutocompleteOnSelected<String>
                                                    onSelected,
                                                Iterable<String> options) {
                                          return Material(
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: options.length,
                                              itemBuilder: (context, index) {
                                                final option =
                                                    options.elementAt(index);
                                                return ListTile(
                                                  title: Text(option),
                                                  onTap: () {
                                                    onSelected(option);
                                                  },
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    }
                                    return Text(
                                        "Please restart your application.");
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Trip Date', style: TextStyle(color:Colors.black, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      child: TextFormField(
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                        controller: dateInput,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
                                          filled: true,
                                          fillColor: Colors.grey.shade100,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                          suffixIcon: const Icon(
                                            Icons.arrow_drop_down,
                                            size: 25,
                                            color: Colors.black,
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () async {
                                          DateTime currentDate = DateTime.now();
                                          DateTime firstDate = DateTime(currentDate.year, currentDate.month - 1, 1);
                                          DateTime initialDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day - 1);
                                          DateTime lastDate = DateTime(currentDate.year, currentDate.month + 2, 0); // Last day of the next month

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
                                              dateInput.text = formattedDate;
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
                              // FutureBuilder<List<DateTime>>(
                              //   future: _datesFuture,
                              //   builder: (context, snapshot) {
                              //     if (snapshot.connectionState == ConnectionState.waiting) {
                              //       return CircularProgressIndicator();
                              //     } else if (snapshot.hasError) {
                              //       return Text('Error: ${snapshot.error}');
                              //     } else if (snapshot.hasData) {
                              //       _dates = snapshot.data!;
                              //
                              //       return Padding(
                              //         padding: const EdgeInsets.all(8.0),
                              //         child: Column(
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //           children: [
                              //             const Text('Trip Date',
                              //                 style: TextStyle(
                              //                     color: Colors.black, fontWeight: FontWeight.bold)),
                              //             const SizedBox(height: 5),
                              //             Container(
                              //               width: 150,
                              //               decoration: BoxDecoration(
                              //                 color: Colors.grey.shade100,
                              //                 borderRadius: BorderRadius.circular(10),
                              //                 border: Border.all(
                              //                   color: Colors.grey,
                              //                 ),
                              //               ),
                              //               child: DropdownButton<DateTime>(
                              //                 hint: Text('Select a date'),
                              //                 value: _selectedDate,
                              //                 isExpanded: true,
                              //                 items: _dates.map((DateTime date) {
                              //                   return DropdownMenuItem<DateTime>(
                              //                     value: date,
                              //                     child: Text(DateFormat('dd-MM-yyyy').format(date)),
                              //                   );
                              //                 }).toList(),
                              //                 onChanged: (DateTime? newDate) {
                              //                   setState(() {
                              //                     _selectedDate = newDate;
                              //                   });
                              //                 },
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       );
                              //     }
                              //     return Text('No dates available');
                              //   },
                              // ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const Text('Amount',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    child: TextFormField(
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                      ),
                                      controller: amount,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                        const EdgeInsets.fromLTRB(
                                            10, 10, 20, 0),
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.currency_rupee,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value! == null &&
                                            value.isEmpty) {
                                          // Utils.flushBarErrorMessage('Please pick date first', context, lightColor);
                                        }
                                        return null;
                                      },
                                      // validator: (value) => value!.isEmpty ? 'Select Date' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Reason',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Row(
                                children: [],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: MediaQuery.of(context).size.width / 3,
                                  width:
                                      MediaQuery.of(context).size.width / 1.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.textfiedlColor,
                                  ),
                                  child: TextFormField(
                                    maxLines: 15,
                                    controller: reasonController,
                                    keyboardType: TextInputType.text,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(100),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        // Utils.flushBarErrorMessage('Fill this field!', context, lightColor);
                                      }
                                      return null; // Add return statement to avoid errors
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: const BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      hintText: 'Write your reason here...',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      InkWell(
                                          onTap: _pickExcelFile,
                                          child: Container(
                                            // width: MediaQuery.of(context).size.width/3,
                                            decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: _filePath != null
                                                  ? const Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .cloud_upload_rounded,
                                                          color: AppColors
                                                              .whiteColor,
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'File Selected',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .whiteColor),
                                                        )
                                                      ],
                                                    )
                                                  : const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .cloud_upload_rounded,
                                                          color: AppColors
                                                              .whiteColor,
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          'Attachment',
                                                          style: TextStyle(
                                                              color: AppColors
                                                                  .whiteColor),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          )),
                                      const SizedBox(height: 20),
                                      // _filePath != null
                                      //     ? Text('File selected', textAlign: TextAlign.center)
                                      //     : Text('No file selected', textAlign: TextAlign.center),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: const BorderSide(
                                  color: AppColors
                                      .primaryColor), // Sets the border color
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              print('5555');
                              print('pressed');
                              if (_myformKey.currentState!.validate()) {
                                print('here ok');
                                print('${reasonController.text}');
                                // if (selectdDoctor != null &&
                                //     dateInput.text.isNotEmpty &&
                                //     amount.text.isNotEmpty &&
                                //     reasonController.text.isNotEmpty) {
                                //   print('all ok');
                                // Proceed with leave application
                                requestexpense(context);
                                // } else {
                                //   // Show an error message or alert indicating that all required fields must be filled.
                                //   Utils.flushBarErrorMessage('Please fill in all required fields', context,);
                                // }
                                // leaveApplication.leaveAppApi(jsonEncode(data), context);
                              }

                              // _showMaterialDialog();
                              // showAboutDialog(context: context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                maximumSize: const Size(100, 40),
                                minimumSize: const Size(100, 40),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            child: const Text(
                              'Submit',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.whiteColor),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //functions
  Future<void> requestexpense(BuildContext context) async {
    print('request expense called...');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userID = preferences.getString('userID');
    String? uniqueID = preferences.getString('uniqueID');
    print('userID${userID} uni id:${uniqueID}');
    Map<String, dynamic> mydata = {
      "amount": amount.text,
      "remarks": reasonController.text,
      "attachment":
          "https://edit.org/img/blog/7c0-free-dental-prescription-template-printable.webp",
      "trip_date": dateInput.text,
      "doct_id": int.parse(selectedDoctorId.toString()),
      "requesterId": int.parse(userID.toString()),
      "uniqueRequesterId": uniqueID
    };

    print('mydata$mydata');
    try {
      print('api run success....');
      final response = await http.post(
        Uri.parse(AppUrl.expense_request),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(mydata),
      );
      print(jsonEncode(mydata));
      print('88888${response.statusCode}');
      if (response.statusCode == 200) {
        var responses = jsonDecode(response.body);
        print('Success....${response.body}');
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesName.successsplash,
          (route) => false,
        );
        Utils.flushBarErrorMessage(responses['message'], context);
        // If the server returns a 200 OK response, parse the JSON
        final data = json.decode(response.body);
        // Process the data here, e.g., update your view model or state.
        print(data);
      } else {
        var responses = jsonDecode(response.body);
        Utils.flushBarErrorMessage(responses['message'], context);
        // If the server did not return a 200 OK response,
        // throw an exception or handle the error as needed.
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Handle exceptions, e.g., network errors or timeouts.
      print('Error: $e');
    }
  }
}
