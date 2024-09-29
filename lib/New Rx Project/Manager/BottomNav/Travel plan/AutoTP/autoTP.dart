import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rx_route_new/Util/Routes/routes_name.dart';
import 'package:rx_route_new/Util/Utils.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
//
// class Autotp extends StatefulWidget   {
//   final Map<String, dynamic> data; // List of dynamic data
//
//   Autotp({required this.data, super.key});
//
//   @override
//   State<Autotp> createState() => _AutotpState();
// }
//
// class _AutotpState extends State<Autotp> {
//   // bool _loading = true; // Loading state variable
//   String selectedDate = '';
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now();
//
//   bool iscalenderVisible = false;
//
//
//   // Convert the data from the backend to events for the calendar
//   // void _populateEvents() {
//   //   print('populate called..');
//   //   final DateFormat formatter = DateFormat('dd-MM-yyyy'); // Define the date format
//   //
//   //   if (widget.data != null && widget.data.isNotEmpty) {
//   //     for (var item in widget.data) {
//   //       try {
//   //         // Ensure item is a map and has the necessary fields
//   //         if (item is Map && item.containsKey('date') && item.containsKey('doctors')) {
//   //           String dateString = item['date'];
//   //           List<dynamic> doctorsList = item['doctors'];
//   //
//   //           DateTime date = formatter.parse(dateString); // Parse the date
//   //
//   //           // Ensure the date is added to the events map correctly
//   //           if (_events[date] == null) {
//   //             _events[date] = [];
//   //           }
//   //
//   //           // Add the list of doctors to the date's events
//   //           _events[date]!.addAll(doctorsList);
//   //         } else {
//   //           print('Error: Unexpected item format. Item: $item');
//   //         }
//   //       } catch (e) {
//   //         print('Error parsing date or handling doctors list: $e');
//   //       }
//   //     }
//   //   } else {
//   //     print('Error: widget.data is null or not a valid structure');
//   //   }
//   // }
//
//
//
//   // Update the list of doctors for the selected date
//   // void _updateSelectedDoctors(DateTime date) {
//   //   setState(() {
//   //     _selectedDoctors = _events[date] ?? [];
//   //   });
//   // }
//
//   // Submit AutoTP to backend
//   Future<void> submitAutoTp() async {
//     print('auto submit ');
//     // setState(() {
//     //   _loading = true; // Show loader when submitting
//     // });
//
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     int? userID = int.parse(preferences.getString('userID').toString());
//     String url = AppUrl.submitAutoTP;
//     var data = {
//       "user_id": userID,
//       "data": [widget.data]
//     };
//
//     try {
//       var response = await http.post(
//         Uri.parse(url),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(data),
//       );
//       print('${response.statusCode}');
//       print('${response.body}');
//
//       if(response.statusCode == 200){
//         var responseData = jsonDecode(response.body);
//         Utils.flushBarErrorMessage('${responseData['message']}', context);
//       }else{
//         var responsedata = jsonDecode(response.body);
//         Utils.flushBarErrorMessage('${responsedata['message']}', context);
//       }
//
//     } catch (e) {
//       print('Error: $e');
//       Utils.flushBarErrorMessage2('Failed to submit AutoTP', context);
//     } finally {
//       // setState(() {
//       //   _loading = false; // Stop loading after submission
//       // });
//     }
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     print('widget data :${widget.data}');
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Automatic Schedule'),
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryColor),
//             onPressed: () {
//               submitAutoTp();
//             },
//             child: Text('Continue', style: TextStyle(color: AppColors.whiteColor)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryColor),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text('Cancel', style: TextStyle(color: AppColors.whiteColor)),
//           )
//         ],
//       ),
//       body:
//       // _loading ? Center(child: CircularProgressIndicator(),):
//       Column(
//         children: [
//           // Dropdown for selecting date
//           // Calendar view
//           !iscalenderVisible?TableCalendar(
//             firstDay: DateTime.utc(2020, 1, 1),
//             lastDay: DateTime.utc(2030, 12, 31),
//             focusedDay: _focusedDay,
//             selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//                 _focusedDay = focusedDay; // Update `_focusedDay` to reflect the current view
//               });
//             },
//             calendarFormat: CalendarFormat.month,
//             // Customizing the calendar style
//             calendarStyle: CalendarStyle(
//               selectedDecoration: BoxDecoration(
//                 color: Colors.blue,
//                 shape: BoxShape.circle,
//               ),
//               todayDecoration: BoxDecoration(
//                 color: Colors.orange,
//                 shape: BoxShape.circle,
//               ),
//               outsideDaysVisible: false,
//             ),
//             headerStyle: HeaderStyle(
//               formatButtonVisible: false,
//               titleCentered: true,
//             ),
//           ):Text(''),
//           InkWell(
//             onTap: (){
//               setState(() {
//                 iscalenderVisible = !iscalenderVisible;
//               });
//             },
//             child: Container(
//               decoration: BoxDecoration(
//                   color: AppColors.primaryColor
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       children: [
//                         Text(
//                           _selectedDay != null
//                               ? DateFormat('dd/MM/yyyy').format(_selectedDay)
//                               : '',
//                           style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.bold),
//                         ),
//                         iscalenderVisible ? Icon(Icons.keyboard_arrow_up,color: AppColors.whiteColor,):Icon(Icons.keyboard_arrow_down,color: AppColors.whiteColor,)
//                       ],
//                     ),
//                   )
//                 ],
//               ),
//             ),
//           ),
//           // Display doctors' details
//           Expanded(
//             child: ListView.builder(
//               itemCount: widget.data[formatDate(_selectedDay)]?.length ?? 0,
//               itemBuilder: (context, index) {
//                 final doctor = widget.data[formatDate(_selectedDay)]![index];
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Container(
//                     decoration: BoxDecoration(borderRadius: BorderRadius.circular(9),
//                       border: Border.all(
//                         width: 1,
//                         color:doctor['category'] == 'core'
//                           ? AppColors.tilecolor2
//                           : doctor['category'] == 'supercore'
//                           ? AppColors.tilecolor1
//                           : AppColors.tilecolor3, )
//                     ),
//                     child: ListTile(
//                       subtitle: Text('${doctor}'),
//                       leading: CircleAvatar(
//                         child: Text('${doctor['doctor'][3]}',style: TextStyle(color: AppColors.whiteColor),),
//                         backgroundColor:  doctor['category'] == 'core'
//                             ? AppColors.tilecolor2
//                             : doctor['category'] == 'supercore'
//                             ? AppColors.tilecolor1
//                             : AppColors.tilecolor3,
//                       ),
//                       title: Text(doctor['doctor']),
//                       // subtitle: Text('${doctor['category']} - ${doctor['day']}'),
//                       trailing: Text(doctor['address']['address']),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String formatDate(DateTime date) {
//     // Format date as "dd-MM-yyyy" for matching with keys in your data
//     return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//   }
//
//
// }
//this page for automatic generated tp viewing page
class Autotp extends StatefulWidget {
  String selectedMonth;
  final Map<String, dynamic> data;

  Autotp({required this.selectedMonth,required this.data, super.key});

  @override
  State<Autotp> createState() => _AutotpState();
}

class _AutotpState extends State<Autotp> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool isCalendarVisible = false;
  String? selectedSubHeadquarter; // Holds the selected sub-headquarter

  @override
  void initState() {
    super.initState();
    // Parse the month and year from widget.selectedMonth (format: "MM-yyyy")
    List<String> dateParts = widget.selectedMonth.split('-');
    int selectedMonth = int.parse(dateParts[0]);
    int selectedYear = int.parse(dateParts[1]);

    // Set the focused day and selected day to the first day of the selected month and year
    _focusedDay = DateTime(selectedYear, selectedMonth, 1);
    _selectedDay = DateTime(selectedYear, selectedMonth, 1);
    print('widget data :${widget.data}');
    print('widget data :${widget.selectedMonth}');
  }


  // Rename the function for better readability
  String formatDateToMonthYear(DateTime date) {
    // Return formatted month-year string
    return '${date.month}-${date.year}';
  }

  // Extract the unique sub-headquarters and their doctor count
  Map<String, int> getSubHeadquarterCounts() {
    Map<String, int> subHeadquarterCounts = {};

    widget.data[formatDate(_selectedDay)]?.forEach((doctor) {
      String subHeadquarter = doctor['address']['subHeadQuarter'] ?? 'Unknown';
      subHeadquarterCounts[subHeadquarter] =
          (subHeadquarterCounts[subHeadquarter] ?? 0) + 1;
    });

    return subHeadquarterCounts;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
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
        title: Text('Automatic Schedule'),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            onPressed: submitAutoTp,
            child: Text('Continue', style: TextStyle(color: AppColors.whiteColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: AppColors.whiteColor)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 70.0),
          child: Container(
            child: Column(
              children: [
                Text('${widget.data}'),
                // Calendar view
                !isCalendarVisible
                    ? TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),

                  // Use CalendarBuilders to add custom decorations
                  calendarBuilders: CalendarBuilders(
                    // Marker for doctors (green dot marker)
                    markerBuilder: (context, date, events) {
                      if (widget.data[formatDate(date)] != null && widget.data[formatDate(date)]!.isNotEmpty) {
                        return Positioned(
                          bottom: 4.0,
                          child: Container(
                            width: 5.0,
                            height: 5.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green, // Green dot for days with doctor events
                            ),
                          ),
                        );
                      }
                      return SizedBox(); // No marker if no doctors
                    },

                    // Custom builder for days to color Sundays in red
                    defaultBuilder: (context, day, focusedDay) {
                      final isSunday = day.weekday == DateTime.sunday;
                      return Container(
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isSunday ? Colors.red : Colors.black, // Red text for Sundays
                            fontWeight: isSunday ? FontWeight.bold : FontWeight.normal, // Bold text for Sundays
                          ),
                        ),
                      );
                    },

                    // Selected day and today's custom style
                    selectedBuilder: (context, date, focusedDay) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue, // Blue circle for selected day
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },

                    todayBuilder: (context, date, focusedDay) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.orange, // Orange circle for today's date
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : SizedBox(),
                SizedBox(height: 10,),
                // Toggle calendar visibility
                InkWell(
                  onTap: () {
                    setState(() {
                      isCalendarVisible = !isCalendarVisible;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.primaryColor),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                DateFormat('dd/MM/yyyy').format(_selectedDay),
                                style: TextStyle(
                                    color: AppColors.whiteColor, fontWeight: FontWeight.bold),
                              ),
                              isCalendarVisible
                                  ? Icon(Icons.keyboard_arrow_up, color: AppColors.whiteColor)
                                  : Icon(Icons.keyboard_arrow_down, color: AppColors.whiteColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sub-headquarters chips
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Horizontal scrolling
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: getSubHeadquarterCounts().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0), // Add spacing between chips
                          child: ChoiceChip(
                            backgroundColor: AppColors.textfiedlColor, // Unselected background color
                            selectedColor: AppColors.primaryColor,     // Selected background color
                            label: Text(
                              '${entry.key} (${entry.value})',
                              style: TextStyle(
                                color: selectedSubHeadquarter == entry.key
                                    ? AppColors.whiteColor // Text color when selected
                                    : AppColors.blackColor, // Text color when unselected
                                fontWeight: FontWeight.bold, // Add bold styling
                              ),
                            ),
                            selected: selectedSubHeadquarter == entry.key, // Chip selected state
                            onSelected: (selected) {
                              setState(() {
                                selectedSubHeadquarter = selected ? entry.key : null;
                              });
                            },
                            elevation: 4, // Adds a shadow effect
                            pressElevation: 8, // Elevation when pressed
                            shape: RoundedRectangleBorder( // Shape without a border
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Doctor list filtered by sub-headquarter
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.data[formatDate(_selectedDay)]?.length ?? 0,
                    itemBuilder: (context, index) {
                      final doctor = widget.data[formatDate(_selectedDay)]![index];

                      // Filter by selected sub-headquarter
                      if (selectedSubHeadquarter != null &&
                          doctor['address']['subHeadQuarter'] != selectedSubHeadquarter) {
                        return SizedBox.shrink(); // Skip this doctor if it doesn't match the selected sub-headquarter
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              width: 1,
                              color: doctor['category'] == 'core'
                                  ? AppColors.tilecolor2
                                  : doctor['category'] == 'supercore'
                                  ? AppColors.tilecolor1
                                  : AppColors.tilecolor3,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                '${doctor['doctor'][3]}',
                                style: TextStyle(color: AppColors.whiteColor),
                              ),
                              backgroundColor: doctor['category'] == 'core'
                                  ? AppColors.tilecolor2
                                  : doctor['category'] == 'supercore'
                                  ? AppColors.tilecolor1
                                  : AppColors.tilecolor3,
                            ),
                            title: Text(doctor['doctor']),
                            trailing: Text(doctor['address']['address']),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  Future<void> submitAutoTp() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? userID = int.parse(preferences.getString('userID').toString());
    String url = AppUrl.submitAutoTP;

    var data = {
      "user_id": userID,
      "data": [widget.data]
    };
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      print('resposne is :${jsonDecode(response.body)}');
      if(response.statusCode == 200){
        var responseData = jsonDecode(response.body);
      Utils.flushBarErrorMessage('${responseData['message']}', context);
      Navigator.pushNamedAndRemoveUntil(context, RoutesName.successsplash, (route) => false,);
      }
      else{
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage2(responseData['message'], context);
      }

    } catch (e) {
      print('Error: $e');
      Utils.flushBarErrorMessage2('Failed to submit AutoTP', context);
    }
  }
}




// class DoctorSchedulePage extends StatefulWidget {
//   @override
//   State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
// }
//
// class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
//   // Sample data from your JSON
//   final Map<String, List<Map<String, dynamic>>> data = {
//     "01-10-2024": [
//       {
//         "doctor": "Dr.Sathyan",
//         "category": "supercore",
//         "day": "Tuesday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Suman",
//         "category": "supercore",
//         "day": "Tuesday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Abhishekha",
//         "category": "important",
//         "day": "Tuesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       }
//     ],
//     "02-10-2024": [
//       {
//         "doctor": "Dr.Anusree",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2732268",
//           "longitude": "75.7720265"
//         }
//       },
//       {
//         "doctor": "Dr.Arpitha",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       },
//       {
//         "doctor": "Dr.Arya",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       },
//       {
//         "doctor": "Dr.Aswin",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       },
//       {
//         "doctor": "Dr.Santi",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Akhil",
//         "category": "important",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2732268",
//           "longitude": "75.7720265"
//         }
//       }
//     ],
//     "04-10-2024": [
//       {
//         "doctor": "Dr.Musthafa",
//         "category": "supercore",
//         "day": "Friday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       }
//     ],
//     "05-10-2024": [
//       {
//         "doctor": "Dr.Sathyan",
//         "category": "supercore",
//         "day": "Saturday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Suman",
//         "category": "supercore",
//         "day": "Saturday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Gikhin",
//         "category": "important",
//         "day": "Saturday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       }
//     ],
//     "09-10-2024": [
//       {
//         "doctor": "Dr.Anusree",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2732268",
//           "longitude": "75.7720265"
//         }
//       },
//       {
//         "doctor": "Dr.Arpitha",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       },
//       {
//         "doctor": "Dr.Arya",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       },
//       {
//         "doctor": "Dr.Aswin",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       },
//       {
//         "doctor": "Dr.Santi",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       }
//     ],
//     "11-10-2024": [
//       {
//         "doctor": "Dr.Sathyan",
//         "category": "supercore",
//         "day": "Friday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Suman",
//         "category": "supercore",
//         "day": "Friday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Musthafa",
//         "category": "supercore",
//         "day": "Friday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       }
//     ],
//     "12-10-2024": [
//       {
//         "doctor": "Dr.Abhishekha",
//         "category": "important",
//         "day": "Saturday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       }
//     ],
//     "15-10-2024": [
//       {
//         "doctor": "Dr.Sathyan",
//         "category": "supercore",
//         "day": "Tuesday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Suman",
//         "category": "supercore",
//         "day": "Tuesday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       }
//     ],
//     "16-10-2024": [
//       {
//         "doctor": "Dr.Anusree",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2732268",
//           "longitude": "75.7720265"
//         }
//       },
//       {
//         "doctor": "Dr.Arpitha",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       },
//       {
//         "doctor": "Dr.Arya",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       },
//       {
//         "doctor": "Dr.Aswin",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       },
//       {
//         "doctor": "Dr.Santi",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Akhil",
//         "category": "important",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2732268",
//           "longitude": "75.7720265"
//         }
//       }
//     ],
//     "18-10-2024": [
//       {
//         "doctor": "Dr.Musthafa",
//         "category": "supercore",
//         "day": "Friday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       }
//     ],
//     "19-10-2024": [
//       {
//         "doctor": "Dr.Sathyan",
//         "category": "supercore",
//         "day": "Saturday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Suman",
//         "category": "supercore",
//         "day": "Saturday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Gikhin",
//         "category": "important",
//         "day": "Saturday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       }
//     ],
//     "23-10-2024": [
//       {
//         "doctor": "Dr.Anusree",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2732268",
//           "longitude": "75.7720265"
//         }
//       },
//       {
//         "doctor": "Dr.Arpitha",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       },
//       {
//         "doctor": "Dr.Arya",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       },
//       {
//         "doctor": "Dr.Aswin",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       },
//       {
//         "doctor": "Dr.Santi",
//         "category": "core",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       }
//     ],
//     "25-10-2024": [
//       {
//         "doctor": "Dr.Sathyan",
//         "category": "supercore",
//         "day": "Friday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Suman",
//         "category": "supercore",
//         "day": "Friday",
//         "address": {
//           "address": "ashok house kozhikode"
//         }
//       },
//       {
//         "doctor": "Dr.Musthafa",
//         "category": "supercore",
//         "day": "Friday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2757286",
//           "longitude": "75.7779643"
//         }
//       }
//     ],
//     "30-10-2024": [
//       {
//         "doctor": "Dr.Anusree",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2732268",
//           "longitude": "75.7720265"
//         }
//       },
//       {
//         "doctor": "Dr.Arpitha",
//         "category": "supercore",
//         "day": "Wednesday",
//         "address": {
//           "address": "ashok house kozhikode",
//           "latitude": "11.2600489",
//           "longitude": "75.7900391"
//         }
//       }
//     ]
//   };
//
//   String selectedDate = "01-10-2024";
//
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//     appBar: AppBar(
//       title: Text('Doctor Schedule'),
//     ),
//     body: Column(
//       children: [
//         // Dropdown for selecting date
//         // Calendar view
//         TableCalendar(
//           firstDay: DateTime.utc(2020, 1, 1),
//           lastDay: DateTime.utc(2030, 12, 31),
//           focusedDay: _focusedDay,
//           selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//           onDaySelected: (selectedDay, focusedDay) {
//             setState(() {
//               _selectedDay = selectedDay;
//               _focusedDay = focusedDay; // Update `_focusedDay` to reflect the current view
//             });
//           },
//           calendarFormat: CalendarFormat.month,
//           // Customizing the calendar style
//           calendarStyle: CalendarStyle(
//             selectedDecoration: BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//             ),
//             todayDecoration: BoxDecoration(
//               color: Colors.orange,
//               shape: BoxShape.circle,
//             ),
//             outsideDaysVisible: false,
//           ),
//           headerStyle: HeaderStyle(
//             formatButtonVisible: false,
//             titleCentered: true,
//           ),
//         ),
//         // Display doctors' details
//         Expanded(
//           child: ListView.builder(
//             itemCount: data[formatDate(_selectedDay)]?.length ?? 0,
//             itemBuilder: (context, index) {
//               final doctor = data[formatDate(_selectedDay)]![index];
//               return ListTile(
//                 title: Text(doctor['doctor']),
//                 subtitle: Text('${doctor['category']} - ${doctor['day']}'),
//                 trailing: Text(doctor['address']['address']),
//               );
//             },
//           ),
//         ),
//       ],
//     ),
//     );
//   }
//
//   String formatDate(DateTime date) {
//     // Format date as "dd-MM-yyyy" for matching with keys in your data
//     return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
//   }
// }
