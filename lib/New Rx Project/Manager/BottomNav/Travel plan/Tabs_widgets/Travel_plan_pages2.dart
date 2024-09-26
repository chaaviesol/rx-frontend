// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:http/http.dart' as http;
//
// class TravelPlanPages2 extends StatefulWidget {
//   final int tpid; // Travel plan ID passed from another page
//   final String monthandyear; // Month and year passed as string in 'Month Year' format
//
//   TravelPlanPages2({required this.tpid, required this.monthandyear, super.key});
//
//   @override
//   State<TravelPlanPages2> createState() => _TravelPlanPages2State();
// }
//
// class _TravelPlanPages2State extends State<TravelPlanPages2> {
//   late Map<DateTime, List<dynamic>> _events;
//   List<dynamic> _selectedEvents = [];
//   DateTime _selectedDay = DateTime.now();
//   DateTime _focusedDay = DateTime.now();
//   bool isCalandershow = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _events = {};
//
//     // Parse the passed month and year
//     final dateParts = widget.monthandyear.split(' ');
//     final month = _getMonthNumber(dateParts[0]);
//     final year = int.parse(dateParts[1]);
//
//     // Set the focused day to the passed month and year
//     _focusedDay = DateTime(year, month);
//
//     // Fetch the travel plan data using tpid
//     _fetchData();
//   }
//
//   // Helper function to get month number from month name
//   int _getMonthNumber(String monthName) {
//     switch (monthName.toLowerCase()) {
//       case 'january':
//         return 1;
//       case 'february':
//         return 2;
//       case 'march':
//         return 3;
//       case 'april':
//         return 4;
//       case 'may':
//         return 5;
//       case 'june':
//         return 6;
//       case 'july':
//         return 7;
//       case 'august':
//         return 8;
//       case 'september':
//         return 9;
//       case 'october':
//         return 10;
//       case 'november':
//         return 11;
//       case 'december':
//         return 12;
//       default:
//         return DateTime.now().month;
//     }
//   }
//
//   // Fetch travel plan data from the API
//   Future<void> _fetchData() async {
//     try {
//       final response = await fetchTravelPlan(widget.tpid);
//       setState(() {
//         _parseEvents(response['data']);
//       });
//     } catch (e) {
//       print('Error fetching data: $e');
//     }
//   }
//
//   // Fetch travel plan from API
//   Future<Map<String, dynamic>> fetchTravelPlan(int travelPlanId) async {
//     final Uri url = Uri.parse('http://52.66.145.37:3004/rep/getTravelPlan');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'travelPlanId': travelPlanId}),
//     );
//
//     if (response.statusCode == 200) {
//       var responseData = jsonDecode(response.body);
//       print('response: $responseData');
//       return responseData;
//     } else {
//       throw Exception('Failed to load travel plan');
//     }
//   }
//
//   // Parse events into a map with DateTime as keys
//   void _parseEvents(List<dynamic> data) {
//     final Map<DateTime, List<dynamic>> events = {};
//     for (var item in data) {
//       final dateStr = item['date']; // The 'date' field from the response
//       final date = DateFormat('dd-MM-yyyy').parse(dateStr);
//
//       if (!events.containsKey(date)) {
//         events[date] = [];
//       }
//
//       // Add doctor details (drDetails) as events
//       events[date]!.addAll(item['drDetails']);
//     }
//
//     setState(() {
//       _events = events;
//       print('Parsed events: $_events');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('View TP')),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Calendar widget
//             isCalandershow
//                 ? TableCalendar(
//               firstDay: DateTime.utc(2020, 1, 1),
//               lastDay: DateTime.utc(2030, 12, 31),
//               focusedDay: _focusedDay,
//               selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
//               // When a date is selected on the calendar
//               onDaySelected: (selectedDay, focusedDay) {
//                 setState(() {
//                   print('_events: $_events');
//
//                   // Format the selectedDay to match the date format in response ('dd-MM-yyyy')
//                   String formattedDate = DateFormat('dd-MM-yyyy').format(selectedDay);
//
//                   // Now use the formatted date to access _events
//                   _selectedDay = selectedDay;
//                   _focusedDay = focusedDay;
//                   _selectedEvents = _events[selectedDay] ?? [];
//
//                   print('Selected Day: $formattedDate, Events: $_selectedEvents');
//                 });
//               },
//
//               // Load events for the day
//               eventLoader: (day) {
//                 return _events[day] ?? [];
//               },
//
//               // Calendar builders for customizing the appearance of days
//               calendarBuilders: CalendarBuilders(
//                 defaultBuilder: (context, day, focusedDay) {
//                   final hasEvents = _events.containsKey(day);
//
//                   // Highlight days with events in green
//                   return Container(
//                     margin: const EdgeInsets.all(4.0),
//                     decoration: BoxDecoration(
//                       color: hasEvents ? Colors.green : Colors.transparent,
//                       borderRadius: BorderRadius.circular(8.0),
//                     ),
//                     child: Center(child: Text('${day.day}')),
//                   );
//                 },
//               ),
//             )
//                 : const Text(''),
//
//             // Toggle button to show/hide calendar
//             InkWell(
//               onTap: () {
//                 setState(() {
//                   isCalandershow = !isCalandershow;
//                 });
//               },
//               child: Container(
//                 decoration: const BoxDecoration(color: Colors.blue),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Row(
//                         children: [
//                           Text(
//                             '${DateFormat('dd-MM-yyyy').format(_selectedDay)}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           isCalandershow
//                               ? const Icon(Icons.arrow_drop_up, color: Colors.white)
//                               : const Icon(Icons.arrow_drop_down, color: Colors.white)
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ),
//             // Display selected events (doctors)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _selectedEvents.length,
//                 itemBuilder: (context, index) {
//                   final doctor = _selectedEvents[index]; // Each event is a doctor
//
//                   return ListTile(
//                     title: Text('${doctor['firstName']} ${doctor['lastName']}'),
//                     trailing: const Icon(Icons.medical_services),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert'; // For decoding JSON response
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For API requests
import 'package:intl/intl.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../app_colors.dart';
import '../../My lists/Doctor_details/doctor_detials.dart';

class TravelPlanPages2 extends StatefulWidget {
  int tpid;
  String monthandyear;
  String tp_status;
  TravelPlanPages2({required this.tpid,required this.monthandyear,required this.tp_status,Key? key}) : super(key: key);

  @override
  State<TravelPlanPages2> createState() => _TravelPlanPages2State();
}

class _TravelPlanPages2State extends State<TravelPlanPages2> {
  Map<DateTime, List<Map<String, dynamic>>> events = {};
  DateTime? selectedDate;
  List<Map<String, dynamic>> selectedDoctors = [];
  bool isLoading = true;
  bool isVisibleCalendar = true;

  @override
  void initState() {
    super.initState();
    _fetchTravelPlanData();
  }


  Future<void> _fetchTravelPlanData() async {
    final String apiUrl = AppUrl.getCreatedTP;
    final Map<String, dynamic> body = {
      // "travelPlanId": int.parse(widget.tpid.toString()),
      "travelPlanId":widget.tpid,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      print('passed body:${body}');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          Map<DateTime, List<Map<String, dynamic>>> fetchedEvents = {};

          for (var item in data['data']) {
            // Manually parse the date in DD-MM-YYYY format
            String dateString = item['date'];
            List<String> parts = dateString.split('-');
            int day = int.parse(parts[0]);
            int month = int.parse(parts[1]);
            int year = int.parse(parts[2]);

            // Create a DateTime object with the parsed day, month, and year
            DateTime date = DateTime(year, month, day);

            // Extract doctor details
            List<Map<String, dynamic>> doctors =
            List<Map<String, dynamic>>.from(item['drDetails']);

            // Add the doctors to the corresponding date
            if (fetchedEvents[date] != null) {
              fetchedEvents[date]!.addAll(doctors);
            } else {
              fetchedEvents[date] = doctors;
            }
          }

          setState(() {
            events = fetchedEvents;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog('Failed to fetch data: ${data['message']}');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Exception: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('View Travel Plan'),
        actions: [
         widget.tp_status=="Submitted" || widget.tp_status == 'Approved'?Text(''): ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
              onPressed: (){}, child: Text('Save',style: TextStyle(color: Colors.white),)),
          SizedBox(width: 10,),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner while fetching data
          : Column(
        children: [
        isVisibleCalendar
            ? TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),

          // Parse the `monthandyear` into a DateTime
          focusedDay: selectedDate ?? DateFormat('MMMM yyyy').parse(widget.monthandyear), // Open the month and year from `widget.monthandyear`

          selectedDayPredicate: (day) {
            return isSameDay(selectedDate, day);
          },

          eventLoader: (day) {
            return events[day] ?? [];
          },

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              selectedDate = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              selectedDoctors = events[selectedDate] ?? [];
            });
          },

          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              bool hasDoctor = events.containsKey(day) && events[day]!.isNotEmpty;
              bool isSunday = day.weekday == DateTime.sunday;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isSunday ? Colors.red : (hasDoctor ? Colors.green : Colors.black), // Text color: red for Sundays, green for events, black otherwise
                      fontWeight: hasDoctor ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (hasDoctor) // Show dot if there is a doctor
                    Positioned(
                      bottom: 4,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green, // Dot color for events
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          headerStyle: HeaderStyle(
            formatButtonVisible: false, // Hides the "2 weeks" format button
            titleCentered: true, // Centers the month title
            formatButtonShowsNext: false,
          ),
        )
            : Container(),
          const SizedBox(height: 16),
          InkWell(
            onTap: (){
              setState(() {
                isVisibleCalendar = !isVisibleCalendar;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${DateFormat('dd-MM-yyyy').format(selectedDate ?? DateTime.now())}', style: TextStyle(color: AppColors.whiteColor,fontWeight: FontWeight.bold)),
                    isVisibleCalendar?Icon(Icons.arrow_drop_up,color: AppColors.whiteColor,):Icon(Icons.arrow_drop_down,color: AppColors.whiteColor,)
                  ],
                ),
              ),
            ),
          ),
          if (selectedDoctors.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: selectedDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = selectedDoctors[index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorDetailsPage(tpid: widget.tpid,doctorId: doctor['id']),));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                // color: Colors.white,border: Border.all(color: Colors.orange),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color:doctor['visit_type'] == 'core'
                                        ? AppColors.tilecolor2
                                        : doctor['visit_type'] == 'supercore'
                                        ? AppColors.tilecolor1
                                        : AppColors.tilecolor3,
                                    border: Border.all(color: Colors.white),),

                                ),
                                Expanded(
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(9),
                                            border: Border.all(
                                              width: 1,
                                              color: doctor['visit_type'] == 'core'
                                                  ? AppColors.tilecolor2
                                                  : doctor['visit_type'] == 'supercore'
                                                  ? AppColors.tilecolor1
                                                  : AppColors.tilecolor3,
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: doctor['visit_type'] == 'core'
                                                  ? AppColors.tilecolor2
                                                  : doctor['visit_type'] == 'supercore'
                                                  ? AppColors.tilecolor1
                                                  : AppColors.tilecolor3,
                                              child: Text(doctor['firstName'][3]),
                                            ),
                                            title: Text('${doctor['firstName']} ${doctor['lastName']}'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  );
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text('No doctors available for the selected date'),
              ),
            ),
        ],
      ),
    );
  }
}