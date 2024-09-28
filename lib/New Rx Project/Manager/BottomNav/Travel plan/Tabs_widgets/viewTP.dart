// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:table_calendar/table_calendar.dart'; // Import the TableCalendar package
// import '../../../../../app_colors.dart';
// import '../../../../../res/app_url.dart';
//
// class Viewtp extends StatefulWidget {
//   final int tpid;
//   final String monthandyear;
//   final String tp_status;
//
//   Viewtp({required this.tpid, required this.monthandyear, required this.tp_status, super.key});
//
//   @override
//   State<Viewtp> createState() => _ViewtpState();
// }
//
// class _ViewtpState extends State<Viewtp> {
//   Map<DateTime, List<Map<String, dynamic>>> events = {};
//   DateTime? _focusedDay;
//   DateTime? _selectedDay;
//   bool isLoading = true;
//
//   Future<void> _fetchTravelPlanData() async {
//     final String apiUrl = AppUrl.getCreatedTP;
//     final Map<String, dynamic> body = {
//       "travelPlanId": widget.tpid,
//       "month": DateTime.now().month,
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(body),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           print('Fetched data: $data');
//           Map<DateTime, List<Map<String, dynamic>>> fetchedEvents = {};
//
//           for (var item in data['data']) {
//             String dateString = item['date']; // e.g., "2024-10-03 00:00:00.000Z"
//             print('Parsing date string: $dateString');
//
//             // Format the date string to "dd-MM-yyyy"
//             String formattedDate = formatDateString(dateString);
//
//             // Convert the formatted date back to DateTime
//             List<String> parts = formattedDate.split('-');
//             int day = int.parse(parts[0]);
//             int month = int.parse(parts[1]);
//             int year = int.parse(parts[2]);
//
//             DateTime date = DateTime(year, month, day);
//
//             if (item['drDetails'] != null) {
//               List<Map<String, dynamic>> doctors = List<Map<String, dynamic>>.from(item['drDetails']);
//               fetchedEvents[date] = doctors; // Add doctors data to the corresponding date
//             }
//           }
//
//           print('Fetched Events: $fetchedEvents'); // Debugging line
//
//           setState(() {
//             events = fetchedEvents; // Update events with fetched data
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           _showErrorDialog('Failed to fetch data: ${data['message']}');
//         }
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         _showErrorDialog('Error: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       _showErrorDialog('Exception: $e');
//     }
//   }
//
//
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Error'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String formatDateString(String originalDateString) {
//     // Parse the original date string
//     DateTime dateTime = DateTime.parse(originalDateString);
//
//     // Format the date to the desired format "dd-MM-yyyy"
//     return DateFormat('dd-MM-yyyy').format(dateTime);
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     // Set the focused day to the current date
//     _focusedDay = DateTime.now();
//     _selectedDay = _focusedDay; // Set the selected day as well
//     // Fetch travel plan data
//     _fetchTravelPlanData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('View Travel Plan'),
//         actions: [
//           widget.tp_status == "Submitted" || widget.tp_status == 'Approved'
//               ? const SizedBox.shrink()
//               : ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryColor,
//             ),
//             onPressed: () {},
//             child: const Text('Save', style: TextStyle(color: Colors.white)),
//           ),
//           const SizedBox(width: 10),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator()) // Show loading indicator
//           : Column(
//         children: [
//           TableCalendar(
//             firstDay: DateTime.utc(2020, 1, 1),
//             lastDay: DateTime.utc(2030, 12, 31),
//             focusedDay: _focusedDay!,
//             selectedDayPredicate: (day) {
//               return isSameDay(_selectedDay, day);
//             },
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//                 _focusedDay = focusedDay;
//               });
//               print('focday:$focusedDay');
//             },
//             onPageChanged: (focusedDay) {
//               setState(() {
//                 _focusedDay = focusedDay;
//
//               });
//             },
//             calendarBuilders: CalendarBuilders(
//               markerBuilder: (context, date, events) {
//                 print('date of calander is :$date');
//                 // If there are doctors available on the date, show a green dot
//                 if (this.events.containsKey(date)) {
//                   return Positioned(
//                     right: 1,
//                     bottom: 1,
//                     child: Container(
//                       width: 8.0,
//                       height: 8.0,
//                       decoration: const BoxDecoration(
//                         color: Colors.green,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                   );
//                 }
//                 return null; // No marker for dates without events
//               },
//               todayBuilder: (context, day, focusedDay) {
//                 return Container(
//                   margin: const EdgeInsets.all(6.0),
//                   alignment: Alignment.center,
//                   decoration: const BoxDecoration(
//                     color: Colors.blue,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Text(
//                     '${day.day}',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 );
//               },
//             ),
//             headerStyle: const HeaderStyle(
//               formatButtonVisible: false,
//               titleCentered: true,
//               titleTextStyle: TextStyle(
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.bold,
//               ),
//               leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
//               rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
//             ),
//             calendarFormat: CalendarFormat.month,
//           ),
//           const SizedBox(height: 20),
//           if (_selectedDay != null) ...[
//             Text(
//               'Selected Date: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             if (events[_selectedDay!] != null && events[_selectedDay!]!.isNotEmpty) ...[
//               const Text(
//                 'Available Doctors:',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               Wrap(
//                 children: events[_selectedDay!]!.map<Widget>((doctor) {
//                   List addresses = doctor['addresses'];
//
//                   return Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: Card(
//                       elevation: 4,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Dr. ${doctor['firstName']} ${doctor['lastName']}',
//                               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                             Text('Visit Type: ${doctor['visit_type']}'),
//                             Text('Number of Visits: ${doctor['no_of_visits']}'),
//                             const SizedBox(height: 10),
//                             ...addresses.map((address) {
//                               var schedule = address['address']['schedule'];
//                               return Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Address: ${address['address']['address']}',
//                                     style: const TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(
//                                     'Sub-Headquarter: ${address['address']['subHeadQuarter']}',
//                                   ),
//                                   const SizedBox(height: 5),
//                                   Text(
//                                     'Coordinates: ${address['address']['latitude']}, ${address['address']['longitude']}',
//                                   ),
//                                   const SizedBox(height: 5),
//                                   const Text('Schedule:'),
//                                   ...schedule.map<Widget>((daySchedule) {
//                                     return Text(
//                                       '${daySchedule['day']}: ${daySchedule['start_time']} - ${daySchedule['end_time']}',
//                                     );
//                                   }).toList(),
//                                 ],
//                               );
//                             }).toList(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ] else ...[
//               const SizedBox(height: 20),
//               const Text(
//                 'No Doctors Available for the Selected Date',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ],
//         ],
//       ),
//     );
//   }
// }
