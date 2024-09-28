import 'dart:async';
import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/Manual/provider/eventProvider.dart';
import 'package:rx_route_new/Util/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../app_colors.dart';
import '../../../../../res/app_url.dart';
class Manualtp extends StatefulWidget {
  const Manualtp({super.key});

  @override
  State<Manualtp> createState() => _ManualtpState();
}

class _ManualtpState extends State<Manualtp> {

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now(); // Ensure this is updated when a day is selected

  final Map<DateTime, List> _holidays = {
    DateTime(2024, 1, 1): ['New Year\'s Day'],
    DateTime(2024, 12, 25): ['Christmas Day'],
    // Add more holidays here
  };

// Map to store selected doctors for each day
  Map<String, String> _selectedHeadQuartersPerDay = {};
  Map<String, String> _selectedSubQuartersPerDay = {};
  Map<String, List<int>> _selectedDoctorsPerDay = {};

  Set<String> selectedItems = {};
  String? selectedDistrict;

  List<HeadQuart> _headQuarters = [];
  bool _isLoading = true;

  bool iscalenderVisible = true;

  Future<List<HeadQuart>> fetchHeadQuarts() async {
    final response = await http.get(Uri.parse(AppUrl.list_headqrts));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => HeadQuart.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load headquarters');
    }
  }

  Future<void> _loadHeadQuarters() async {
    try {
      List<HeadQuart> headQuarters = await fetchHeadQuarts();
      setState(() {
        _headQuarters = headQuarters;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching headquarters: $e');
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadHeadQuarters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Day'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            onPressed: () async {
               SharedPreferences prefrences = await SharedPreferences.getInstance();
               int userId = int.parse(prefrences.getString('userID').toString());
              // Show the loading dialog
              // _showLoadingDialog(context);

              // Filter out any dates with empty doctor lists
              var filteredPlan = _selectedDoctorsPerDay.entries
                  .where((entry) => entry.value.isNotEmpty) // Keep only entries with non-empty doctor lists
                  .map((entry) {
                return {
                  "date": entry.key, // Date as the key
                  "doctors": entry.value // List of selected doctor IDs
                };
              }).toList();

              // Prepare the final data to be sent to the backend
              var data = {
                "user_id": userId,
                "plan": filteredPlan,
              };

              print('Created TP is: $data');

              try {
                var response = await context.read<EventProvider>().submitPlan(data);
                Navigator.of(context).pop(); // Close the loading dialog

                // Check if the response indicates success
                if (response['success'] == true) {
                  // Show the response data in the dialog
                  _showResponseDialog(context, response['combinedVisitReport'],response['data']['id']);
                } else {
                  // Handle submission failure
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Submission failed: ${response['message']}')),
                  );
                }
              } catch (e) {
                Navigator.of(context).pop(); // Close the loading dialog

                // Handle any errors
                print('Error submitting plan: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },

            child: Text(
              'Generate',
              style: TextStyle(color: AppColors.whiteColor),
            ),
          ),
          SizedBox(width: 10,)
        ],
      ),
      body: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: selectedItems.map((item) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDistrict = item; // Set the selected district
                        });
                      },
                      child: Chip(
                        label: Text(item),
                        onDeleted: () {
                          setState(() {
                            selectedItems.remove(item);
                            if (selectedDistrict == item) {
                              selectedDistrict = null;
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.0),
              // if (selectedDistrict != null)
              //   Container(
              //     padding: const EdgeInsets.all(8.0),
              //     decoration: BoxDecoration(
              //       color: Colors.blueAccent,
              //       borderRadius: BorderRadius.circular(8.0),
              //     ),
              //     child: Text(
              //       'Selected District: $selectedDistrict',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   ),
            ],
          ),
          iscalenderVisible ? TableCalendar
            (
            focusedDay: _focusedDay,
            firstDay: DateTime(DateTime.now().year, DateTime.now().month, 1), // Start from the first day of the current month
            lastDay: DateTime.utc(2050, 3, 14),
            eventLoader: (day){
              return _holidays['day'] ?? [];
            },

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if(selectedItems.isEmpty){
                Utils.flushBarErrorMessage('Please select area first', context);
              }
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Update the focused day
              });

              // Convert selected day to string formats
              String dayString = DateFormat('EEEE').format(selectedDay); // Day as Sunday, Monday, etc.
              String dateString = DateFormat('dd-MM-yyyy').format(selectedDay); // Date in dd-MM-yyyy format

              // Fetch doctors for the selected day (by weekday name)
              context.read<EventProvider>().fetchDoctorsForDay(dayString,selectedItems);

              // Ensure the map entry for the selected day exists
              if (!_selectedDoctorsPerDay.containsKey(dateString)) {
                _selectedDoctorsPerDay[dateString] = [];
              }
            },
            calendarBuilders: CalendarBuilders(
                holidayBuilder: (context, day, _focusedDay){
                  return Center(
                    child: Text('${day.day}',style: TextStyle().copyWith(color: Colors.red),),
                  );
                }
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: CalendarStyle(
              holidayTextStyle: TextStyle(color: Colors.red),
              // holidayDecoration: BoxDecoration(
              //   color: Colors.redAccent,
              //   shape:BoxShape.circle,
              // ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue, // Set the selected day's background color
                shape: BoxShape.circle, // Set the selected day's shape
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange, // Set the current day's background color
                shape: BoxShape.circle,
              ),
            ),
          ) :Text(''),
          InkWell(
            onTap: (){
              setState(() {
                iscalenderVisible = !iscalenderVisible;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          _selectedDay != null
                              ? DateFormat('dd/MM/yyyy').format(_selectedDay)
                              : '',
                          style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.bold),
                        ),
                        iscalenderVisible ? Icon(Icons.keyboard_arrow_up,color: AppColors.whiteColor,):Icon(Icons.keyboard_arrow_down,color: AppColors.whiteColor,)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10.0,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textfiedlColor,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: TextFormField(
                    onTap: () => _showSelectionPopup(context), // Open the selection popup
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: selectedItems.isNotEmpty
                          ? selectedItems.join(', ') // Display selected items as a comma-separated string
                          : 'Select Sub Quarter',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [

                Expanded(
                  child: Consumer<EventProvider>(
                    builder: (context, eventProvider, child) {
                      var dayString = DateFormat('EEEE').format(_selectedDay);
                      var dateString = DateFormat('dd-MM-yyyy').format(_selectedDay);
                      var eventsForSelectedDay = eventProvider.getEventsForDay(dayString);
                      var selectedDoctorsForDay = _selectedDoctorsPerDay[dateString] ?? [];

                      return eventsForSelectedDay.isNotEmpty
                          ? ListView.builder(
                        itemCount: (eventsForSelectedDay.length + 1) ~/ 2, // Calculate the number of rows needed
                        itemBuilder: (context, index) {
                          // Determine the indices for the two items in this row
                          int firstIndex = index * 2;
                          int secondIndex = firstIndex + 1;

                          final firstDoctor = eventsForSelectedDay[firstIndex];
                          final firstDoctorSelected = selectedDoctorsForDay.contains(firstDoctor.id);

                          // Check if the second item exists
                          bool hasSecondDoctor = secondIndex < eventsForSelectedDay.length;
                          final secondDoctor = hasSecondDoctor ? eventsForSelectedDay[secondIndex] : null;
                          final secondDoctorSelected = hasSecondDoctor ? selectedDoctorsForDay.contains(secondDoctor!.id) : false;

                          return Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                            child: Row(
                              children: [
                                // First item
                                Expanded(
                                  child: GestureDetector(
                                    onTap:() => handleTileTap(firstDoctor.id),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:firstDoctorSelected ? firstDoctor.visitType == 'core'
                                            ? AppColors.tilecolor2
                                            : firstDoctor.visitType == 'supercore'
                                            ? AppColors.tilecolor1
                                            : AppColors.tilecolor3 : null,
                                        borderRadius: BorderRadius.all(Radius.circular(9)),
                                        border: Border.all(
                                          width: 1,
                                          color: firstDoctor.visitType == 'core'
                                              ? AppColors.tilecolor2
                                              : firstDoctor.visitType == 'supercore'
                                              ? AppColors.tilecolor1
                                              : AppColors.tilecolor3,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap:() => handleTileTap(firstDoctor.id),
                                            child: Container(
                                              width: 30,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: firstDoctor.visitType == 'core'
                                                    ? AppColors.tilecolor2
                                                    : firstDoctor.visitType == 'supercore'
                                                    ? AppColors.tilecolor1
                                                    : AppColors.tilecolor3,
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft: Radius.circular(8)),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${firstDoctor.firstName} ${firstDoctor.lastName}'),
                                              // Text('Visit Type: ${firstDoctor.visitType}'),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10), // Spacing between two items
                                // Second item
                                if (hasSecondDoctor)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:() => handleTileTap(secondDoctor!.id),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:secondDoctorSelected ? secondDoctor!.visitType == 'core'
                                              ? AppColors.tilecolor2
                                              : secondDoctor.visitType == 'supercore'
                                              ? AppColors.tilecolor1
                                              : AppColors.tilecolor3 : null,
                                          borderRadius: BorderRadius.all(Radius.circular(9)),
                                          border: Border.all(
                                            width: 1,
                                            color: secondDoctor!.visitType == 'core'
                                                ? AppColors.tilecolor2
                                                : secondDoctor.visitType == 'supercore'
                                                ? AppColors.tilecolor1
                                                : AppColors.tilecolor3,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap:() => handleTileTap(secondDoctor!.id),
                                              child: Container(
                                                width: 30,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: secondDoctor.visitType == 'core'
                                                      ? AppColors.tilecolor2
                                                      : secondDoctor.visitType == 'supercore'
                                                      ? AppColors.tilecolor1
                                                      : AppColors.tilecolor3,
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(8),
                                                      bottomLeft: Radius.circular(8)),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('${secondDoctor.firstName} ${secondDoctor.lastName}'),
                                                // Text('Visit Type: ${secondDoctor.visitType}'),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      )
                          : Center(
                        child: Text('No Doctors for the selected day'),
                      );
                    },
                  ),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void _showResponseDialog(BuildContext context, List<dynamic> combinedVisitReport, int tpid) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Combined Visit Report'),
          content: SizedBox(
            height: 300, // Set a fixed height for the content to ensure scrolling
            width: double.maxFinite, // Make sure the width is as wide as the dialog
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: combinedVisitReport.map((report) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: AppColors.primaryColor),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(9),
                              bottomRight: Radius.circular(9),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 100,
                                width: 10,
                                decoration: BoxDecoration(color: AppColors.primaryColor),
                              ),
                              SizedBox(width: 10),
                              CircleAvatar(
                                radius: 32,
                                child: Text('${report['doctorName'][3]}'),
                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report['doctorName'],
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Planned Visits: ${report['plannedVisits']}'),
                                  Text('Recorded Visits: ${report['recordedVisits']}'),
                                  Text(
                                    'Missed Visits: ${report['missedVisits']}',
                                    style: report['missedVisits'] == 0
                                        ? TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
                                        : TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Handle "Continue" action
                _onContinue(context, tpid);
              },
              child: Text('Continue'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Handle "Edit" action
                _onEdit(context);
              },
              child: Text('Edit'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                print('tp id from cancel button: $tpid');
                try {
                  var response = await context.read<EventProvider>().cancelTP(tpid);
                  if (!mounted) return; // Check if widget is still mounted

                  if (response['success'] == true) {
                    // Handle success
                  } else {
                    // Handle submission failure
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cancel failed: ${response['message']}')),
                    );
                  }
                } catch (e) {
                  if (!mounted) return; // Check if widget is still mounted
                  // Handle any errors
                  print('Error submitting plan: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }



  void _onContinue(BuildContext context, int tpid) async {
    // Show loader while task is in progress
    showDialog(
      context: context,
      barrierDismissible: false, // Disable dismissing while loading
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Set a timeout for the task (e.g., 5 seconds)
      var response = await Future.any([
        context.read<EventProvider>().confirmTP(tpid),
        Future.delayed(Duration(seconds: 5), () => throw TimeoutException('Request timed out')),
      ]);

      // Check if the widget is still mounted before proceeding
      if (!mounted) return;

      // Dismiss the loading dialog after receiving the response
      Navigator.of(context).pop();

      // Check if the response indicates success
      if (response['success'] == true) {
        print("Success...");
        // Navigate to TravelPlanMainPage if successful
        Navigator.pop(context);
        Utils.flushBarErrorMessage('Travel Plan Generated Successfully', context);
      } else {
        // Handle submission failure
        Flushbar(
          message: 'Confirm failed: ${response['message']}',
          duration: Duration(seconds: 3),
        )..show(context);
      }
    } catch (e) {
      // Check if the widget is still mounted before proceeding
      if (!mounted) return;

      // Dismiss the loading dialog if an error occurs
      Navigator.of(context).pop();

      // Show Flushbar for errors, then navigate to the main page
      Flushbar(
        message: 'Error: $e',
        duration: Duration(seconds: 3),
        onStatusChanged: (status) {
          if (status == FlushbarStatus.DISMISSED) {
            // Navigate to the main page after the Flushbar is dismissed
            Navigator.pop(context);
          }
        },
      )..show(context);
    }
  }



  void _onEdit(BuildContext context) {
    // Implement the action for "Edit"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing the plan...')),
    );
    // Add your logic here
  }


  void _showSelectionPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Sub Quarter'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Replace these options with your actual sub-quarter options from the API
                    for (var subHeadquarter in _headQuarters)
                      CheckboxListTile(
                        title: Text(subHeadquarter.subHeadquarter),
                        value: selectedItems.contains(subHeadquarter.subHeadquarter),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedItems.add(subHeadquarter.subHeadquarter);
                            } else {
                              selectedItems.remove(subHeadquarter.subHeadquarter);
                            }
                          });
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Done'),
              onPressed: () {
                setState(() {}); // Update the main UI with the selected items

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void handleTileTap(int doctorId) {
    String dateString = DateFormat('dd-MM-yyyy').format(_selectedDay);
    setState(() {
      if (_selectedDoctorsPerDay[dateString]!.contains(doctorId)) {
        _selectedDoctorsPerDay[dateString]!.remove(doctorId);
      } else {
        _selectedDoctorsPerDay[dateString]!.add(doctorId);
      }
    });
  }
}

class HeadQuart {
  final int id;
  final String headquarterName;
  final String subHeadquarter;

  HeadQuart({
    required this.id,
    required this.headquarterName,
    required this.subHeadquarter,
  });

  factory HeadQuart.fromJson(Map<String, dynamic> json) {
    return HeadQuart(
      id: json['id'],
      headquarterName: json['headquarter_name'].trim(),
      subHeadquarter: json['sub_headquarter'].trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headquarter_name': headquarterName,
      'sub_headquarter': subHeadquarter,
    };
  }
}


//head quart picking old
// Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         decoration: BoxDecoration(
//             color: AppColors.textfiedlColor,
//             borderRadius: BorderRadius.circular(9)
//         ),
//         child: TextFormField(
//           onTap: () => _showSelectionPopup(context),
//           readOnly: true,
//           decoration: InputDecoration(
//               hintText: _selectedSubQuartersPerDay[_selectedDay] != null && _selectedSubQuartersPerDay[_selectedDay]!.isNotEmpty
//                   ? _selectedSubQuartersPerDay[_selectedDay]!
//                   : 'Select Sub Quarter',
//               border: InputBorder.none,
//               contentPadding: EdgeInsets.only(left: 10)
//           ),
//         ),
//       ),
//     ),
//     Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Wrap(
//         spacing: 8.0,
//         runSpacing: 4.0,
//         children: selectedItems.map((item) {
//           return GestureDetector(
//             onTap: (){
//               setState(() {
//                 selectedDistrict = item; // Set the selected district
//               });
//             },
//             child: Chip(
//               label: Text(item),
//               onDeleted: () {
//                 setState(() {
//                   selectedItems.remove(item);
//                   if(selectedDistrict == item){
//                     selectedDistrict = null;
//                   }
//                 });
//               },
//             ),
//           );
//         }).toList(),
//       ),
//     ),
//     SizedBox(height: 16.0),
//     if (selectedDistrict != null)
//       Container(
//         padding: const EdgeInsets.all(8.0),
//         decoration: BoxDecoration(
//           color: Colors.blueAccent,
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         child: Text(
//           'Selected District: $selectedDistrict',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//   ],
// ),

// old
// void _showSelectionPopup(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Select Sub Quarter'),
//         content: StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return SingleChildScrollView(
//               child: Column(
//                 children: [
//                   for (String option in ['Vellayil', 'Nadakkavu', 'Manajira', 'Est Nadakkavu'])
//                     CheckboxListTile(
//                       title: Text(option),
//                       value: selectedItems.contains(option),
//                       onChanged: (bool? value) {
//                         setState(() {
//                           if (value == true) {
//                             selectedItems.add(option);
//                           } else {
//                             selectedItems.remove(option);
//                           }
//                         });
//                       },
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//         actions: [
//           TextButton(
//             child: Text('Done'),
//             onPressed: () {
//               setState(() {}); // Update the main UI with the selected items
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }