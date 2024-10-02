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
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/constants/styles.dart';

import '../../../../../Util/Utils.dart';
import '../../../../../app_colors.dart';
import '../../../../../res/app_url.dart';


class TravelPlanPages2 extends StatefulWidget {
  final int tpid;
  final String monthandyear;
  final String tp_status;

  TravelPlanPages2({
    required this.tpid,
    required this.monthandyear,
    required this.tp_status,
    Key? key,
  }) : super(key: key);

  @override
  State<TravelPlanPages2> createState() => _TravelPlanPages2State();
}

class _TravelPlanPages2State extends State<TravelPlanPages2> {
  Map<DateTime, List<Map<String, dynamic>>> events = {};
  bool isLoading = true;
  String selectedSubHeadquarter = "";
  List<String> subHeadquarters = [];
  DateTime? selectedDate;
  List<Map<String, dynamic>> doctorsForSelectedDate = []; // Initialize as an empty list
  bool isViewCalendar = true;



  @override
  void initState() {
    super.initState();
    _fetchTravelPlanData();
  }

  Future<void> _fetchTravelPlanData() async {
    final String apiUrl = AppUrl.getCreatedTP; // Replace with your API URL
    final Map<String, dynamic> body = {
      "travelPlanId": widget.tpid,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          Map<DateTime, List<Map<String, dynamic>>> fetchedEvents = {};

          for (var item in data['data']) {
            String dateString = item['date'];
            List<String> parts = dateString.split('-');
            int day = int.parse(parts[0]);
            int month = int.parse(parts[1]);
            int year = int.parse(parts[2]);

            DateTime date = DateTime(year, month, day);
            List<Map<String, dynamic>> doctors = List<Map<String, dynamic>>.from(item['drDetails']);

            // Add the doctors to the correct date
            if (fetchedEvents.containsKey(date)) {
              fetchedEvents[date]!.addAll(doctors); // Append doctors if date already exists
            } else {
              fetchedEvents[date] = doctors; // Create a new entry if date does not exist
            }
          }

          setState(() {
            events = fetchedEvents;
            _updateSubHeadquarters(); // Update sub-headquarters on load
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

  void _updateSubHeadquarters() {
    final List<String> uniqueSubHeadquarters = [];
    if (selectedDate != null && events.containsKey(selectedDate)) {
      events[selectedDate]!.forEach((doctor) {
        final subHeadquarter = doctor['addresses'][0]['address']['subHeadQuarter'];
        if (!uniqueSubHeadquarters.contains(subHeadquarter)) {
          uniqueSubHeadquarters.add(subHeadquarter);
        }
      });
    }

    setState(() {
      subHeadquarters = uniqueSubHeadquarters;
      selectedSubHeadquarter = ''; // Reset selected chip when day changes
    });
  }

  void _onChipSelected(String subHeadquarter) {
    setState(() {
      selectedSubHeadquarter = subHeadquarter; // Update the selected sub-headquarter

      // Filter doctors based on selected sub-headquarter
      if (selectedDate != null && events.containsKey(selectedDate)) {
        doctorsForSelectedDate = events[selectedDate]!.where((doctor) {
          return doctor['addresses'][0]['address']['subHeadQuarter'] == selectedSubHeadquarter;
        }).toList();
      } else {
        doctorsForSelectedDate = []; // Reset if no date is selected
      }
    });
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
      appBar: AppBar(
        title: const Text('View TP'),
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
        actions: [
          if (widget.tp_status != "Submitted" && widget.tp_status != 'Approved')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
              onPressed: () {},
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          const SizedBox(width: 10),
          if (widget.tp_status != "Submitted" && widget.tp_status != 'Approved')
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
              onPressed: () {},
              child: const Text('Edit', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Add table header with month and year
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0), // Add padding for better spacing
              child: Text(
                widget.monthandyear, // Use monthandyear property
                style: const TextStyle(
                  fontSize: 18, // Size of the text
                  fontWeight: FontWeight.bold, // Make it bold
                ),
              ),
            ),
           isViewCalendar? SizedBox(height: 350,
             child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 children: [
                   // Row for days of the week
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: const [
                       Text("Sun", style: TextStyle(fontWeight: FontWeight.bold)),
                       Text("Mon", style: TextStyle(fontWeight: FontWeight.bold)),
                       Text("Tue", style: TextStyle(fontWeight: FontWeight.bold)),
                       Text("Wed", style: TextStyle(fontWeight: FontWeight.bold)),
                       Text("Thu", style: TextStyle(fontWeight: FontWeight.bold)),
                       Text("Fri", style: TextStyle(fontWeight: FontWeight.bold)),
                       Text("Sat", style: TextStyle(fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 10), // Add some space between the week row and calendar grid
             
                   // Calendar grid
                   Expanded(
                     child: Container(
                       child: GridView.builder(
                         shrinkWrap: true,
                         physics: const NeverScrollableScrollPhysics(),
                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                           crossAxisCount: 7, // Adjust to 7 for 7 days of the week
                           childAspectRatio: 1.0,
                         ),
                         itemCount: _getDaysInMonth(DateTime.now().month, DateTime.now().year),
                         itemBuilder: (context, index) {
                           final DateTime date = DateTime(DateTime.now().year, DateTime.now().month, index + 1);
                           final doctors = events[date] ?? [];
                           final bool isToday = date.day == DateTime.now().day &&
                               date.month == DateTime.now().month &&
                               date.year == DateTime.now().year;
             
                           return GestureDetector(
                             onTap: () {
                               setState(() {
                                 selectedDate = date;
                                 doctorsForSelectedDate = List<Map<String, dynamic>>.from(doctors);
                                 _updateSubHeadquarters();
                               });
                             },
                             child: Container(
                               margin: const EdgeInsets.all(4.0),
                               decoration: BoxDecoration(
                                 color: isToday
                                     ? Colors.orange
                                     : (doctors.isNotEmpty ? AppColors.primaryColor : AppColors.textfiedlColor),
                                 borderRadius: BorderRadius.circular(50),
                               ),
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Text(
                                     '${date.day}',
                                     style: TextStyle(
                                       fontWeight: FontWeight.bold,
                                       color: doctors.isNotEmpty ? Colors.white : Colors.black,
                                     ),
                                   ),
                                   if (doctors.isNotEmpty)
                                     CircleAvatar(
                                       radius: 3,
                                       backgroundColor: AppColors.whiteColor,
                                     ),
                                 ],
                               ),
                             ),
                           );
                         },
                       ),
                     ),
                   ),
                 ],
               ),
             ),
           )
               :Container(),
            const SizedBox(height: 10),
            InkWell(
              onTap: (){
                setState(() {
                  isViewCalendar = !isViewCalendar;
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
                      child: Text(
                        'Doctors for ${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,color: AppColors.whiteColor),
                      ),
                    ),
                    Icon(isViewCalendar?Icons.arrow_drop_up:Icons.arrow_drop_down,color: AppColors.whiteColor,)
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if(doctorsForSelectedDate.isEmpty) ...[
              Center(child: Text('No Doctors Assigned !',style: text70014black,),)
            ],
            if (doctorsForSelectedDate.isNotEmpty) ...[
              Wrap(
                spacing: 8.0,
                children: subHeadquarters.map((subHQ) {
                  final count = doctorsForSelectedDate.where((doctor) {
                    return doctor['addresses'][0]['address']['subHeadQuarter'] == subHQ;
                  }).length;

                  return ChoiceChip(
                    selectedColor: selectedSubHeadquarter == subHQ ? AppColors.primaryColor:AppColors.textfiedlColor,
                    backgroundColor: selectedSubHeadquarter == subHQ ? AppColors.primaryColor : AppColors.textfiedlColor,
                    label: Text('$subHQ ($count)',style: TextStyle(
                      color: selectedSubHeadquarter == subHQ ? AppColors.whiteColor : AppColors.primaryColor
                    ),),
                    selected: selectedSubHeadquarter == subHQ,
                    onSelected: (isSelected) {
                      _onChipSelected(isSelected ? subHQ : '');
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctorsForSelectedDate.length,
                itemBuilder: (context, index) {
                  final doctor = doctorsForSelectedDate[index];
                  final address = doctor['addresses'][0]['address'];
                  final schedule = address['schedule'] as List;

                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(width: 1,
                        color:doctor['visit_type'] == 'core'
                            ? AppColors.tilecolor2
                            : doctor['visit_type'] == 'supercore'
                            ? AppColors.tilecolor1
                            : AppColors.tilecolor3, ),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: doctor['visit_type'] == 'core'
                              ? AppColors.tilecolor2
                              : doctor['visit_type'] == 'supercore'
                              ? AppColors.tilecolor1
                              : AppColors.tilecolor3,
                          child: Text('${doctor['firstName'][0]}'), // Updated to show first character
                        ),
                        title: Text('${doctor['firstName']} ${doctor['lastName']}',style: text50014black,),
                        children: [
                          Stack(
                            children: [
                              ListTile(
                                title: Text(' ${address['address']}',style: text50014black,),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Scheduled Times:\n' +
                                        schedule.map((s) => '${s['day']}: ${s['start_time']} - ${s['end_time']}').join('\n'),style: text50012black,),
                                  ],
                                ),
                              ),
                              Positioned(
                                top:10,right: 10,
                                  child: InkWell(
                                    onTap: (){
                                      Utils.openMap(address['latitude'],address['longitude']);
                                    },
                                      child: Icon(Icons.location_pin,color: AppColors.primaryColor,))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }



  int _getDaysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }
}
