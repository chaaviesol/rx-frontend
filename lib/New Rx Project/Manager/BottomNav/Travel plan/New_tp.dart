// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:table_calendar/table_calendar.dart';
//
// import 'My_TP.dart'; // Ensure this import is correct and matches your project structure
//
// class NewTravelPlan extends StatefulWidget {
//   const NewTravelPlan({Key? key}) : super(key: key);
//
//   @override
//   State<NewTravelPlan> createState() => _NewTravelPlanState();
// }
//
// class _NewTravelPlanState extends State<NewTravelPlan> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _firstDay;
//   DateTime? _lastDay;
//   String? _selectedArea;
//   List<Map<String, String>> _areas = [];
//   List<Map<String, dynamic>> _doctors = [];
//   List<int> _selectedDoctors = [];
//   List<DateTime> _selectedDays = [];
//   Map<DateTime, List<int>> _dateToDoctorsMap = {};
//
//   String? _errorMessage;
//   bool _isSubmitting = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeDates();
//     _loadAreas();
//   }
//
//   void _initializeDates() {
//     _firstDay = DateTime.utc(DateTime.now().year - 1, 1, 1);
//     _lastDay = DateTime.utc(DateTime.now().year + 1, 12, 31);
//   }
//
//   Future<void> _loadAreas() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     int? userId = int.parse(preferences.getString('userId').toString());
//     try {
//       final response = await http.post(
//         Uri.parse('http://52.66.145.37:3004/user/listArea'),
//         body: json.encode({"userId":userId }),
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success']) {
//           final areas = data['Area'] as List<dynamic>;
//           final List<Map<String, String>> areaList = [];
//
//           for (var area in areas) {
//             for (var item in area) {
//               areaList.add({
//                 'id': item['id'].toString(),
//                 'sub_headquarter': item['sub_headquarter'].trim(),
//               });
//             }
//           }
//
//           setState(() {
//             _areas = areaList;
//           });
//         } else {
//           _setError('Failed to load areas');
//         }
//       } else {
//         _setError('Failed to load areas');
//       }
//     } catch (e) {
//       _setError('Error fetching areas: $e');
//     }
//   }
//
//   Future<void> _loadDoctors(String area) async {
//     final url = 'http://52.66.145.37:3004/user/listDoctors';
//     final body = json.encode({"area": area});
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: body,
//         headers: {"Content-Type": "application/json"},
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as Map<String, dynamic>;
//         if (data['success']) {
//           setState(() {
//             _doctors = (data['data'] as List<dynamic>).map((doctor) {
//               return doctor as Map<String, dynamic>;
//             }).toList();
//             _errorMessage = null;
//           });
//         } else {
//           _setError('API responded with success=false: ${data['message']}');
//         }
//       } else {
//         _setError('HTTP error: ${response.statusCode} - ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       _setError('Error fetching doctors: $e');
//     }
//   }
//
//   void _setError(String message) {
//     setState(() {
//       _errorMessage = message;
//     });
//     print(message);
//   }
//
//   Future<void> _submitTravelPlan() async {
//     if (_selectedArea == null || _selectedDoctors.isEmpty || _selectedDays.isEmpty) {
//       _setError('Please select all fields.');
//       return;
//     }
//
//     setState(() {
//       _isSubmitting = true;
//     });
//
//     final url = 'http://52.66.145.37:3004/rep/createTravelplan';
//     final plans = _selectedDays.map((date) {
//       return {
//         "date": "${date.day}-${date.month}-${date.year}",
//         "doctors": _selectedDoctors,
//       };
//     }).toList();
//
//     final body = json.encode({
//       "user_id": 2,
//       "plan": plans,
//     });
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: body,
//         headers: {"Content-Type": "application/json"},
//       );
//
//       final data = json.decode(response.body);
//
//       if (response.statusCode == 200 && data['success']) {
//         _showDialog('Success', 'Travel plan created successfully!');
//       } else {
//         _setError('Failed to create travel plan: ${response.body}');
//       }
//     } catch (e) {
//       _setError('Error submitting travel plan: $e');
//     } finally {
//       setState(() {
//         _isSubmitting = false;
//         // Clear selections for the next input
//         _selectedArea = null;
//         _selectedDoctors.clear();
//         _selectedDays.clear();
//         _focusedDay = DateTime.now(); // Reset the calendar to the current date
//         _doctors.clear(); // Clear the doctors list so a new area can be selected
//         _dateToDoctorsMap.clear(); // Clear the map of selected dates and doctors
//       });
//     }
//   }
//
//   void _showDialog(String title, String content) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(content),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               if (title == 'Success') {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => Mngr_T_P()),
//                 );
//               }
//             },
//             child: Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Travel Plan'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildDatePicker(),
//               SizedBox(height: 10),
//               _buildAreaDropdown(),
//               SizedBox(height: 10),
//               _buildDoctorList(),
//               SizedBox(height: 10),
//               if (_errorMessage != null) _buildErrorMessage(),
//               SizedBox(height: 20),
//               _buildSubmitButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDatePicker() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 10),
//         TableCalendar(
//           focusedDay: _focusedDay,
//           firstDay: _firstDay!,
//           lastDay: _lastDay!,
//           calendarFormat: CalendarFormat.month,
//           headerStyle: HeaderStyle(formatButtonVisible: false),
//           calendarStyle: CalendarStyle(
//             selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
//             selectedTextStyle: TextStyle(color: Colors.white),
//             todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
//             defaultDecoration: BoxDecoration(shape: BoxShape.circle),
//             todayTextStyle: TextStyle(color: Colors.white),
//           ),
//           onDaySelected: (selectedDay, focusedDay) {
//             setState(() {
//               _focusedDay = focusedDay;
//
//               if (_selectedDays.contains(selectedDay)) {
//                 // If the day is already selected, show the associated doctors
//                 _selectedDoctors = _dateToDoctorsMap[selectedDay] ?? [];
//               } else {
//                 _selectedDays.clear();
//                 _selectedDays.add(selectedDay);
//                 _selectedArea = null; // Reset area selection
//                 _selectedDoctors.clear(); // Reset doctor selection
//                 _doctors.clear(); // Clear doctors list for new selection
//                 _dateToDoctorsMap[selectedDay] = _selectedDoctors;
//               }
//               print('Selected Date: $_selectedDays');
//               print('Doctors for Selected Date: ${_dateToDoctorsMap[selectedDay]}');
//             });
//           },
//           selectedDayPredicate: (day) => _selectedDays.any((selectedDay) => isSameDay(day, selectedDay)),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAreaDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Select Area', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
//         SizedBox(height: 10),
//         Container(
//           width: double.infinity,
//           height: 39,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: Colors.grey[200],
//           ),
//           child: DropdownButton<String>(
//             value: _selectedArea,
//             hint: Text('Select an area'),
//             items: _areas.isEmpty
//                 ? []
//                 : _areas.map((area) {
//               return DropdownMenuItem<String>(
//                 value: area['sub_headquarter'],
//                 child: Text('${area['sub_headquarter']}'),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedArea = newValue;
//               });
//               if (newValue != null) {
//                 _loadDoctors(newValue);
//               }
//             },
//             isExpanded: true,
//             underline: Container(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDoctorList() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Select Doctors', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
//         SizedBox(height: 10),
//         Container(
//           height: 100,
//           child: ListView.builder(
//             itemCount: _doctors.length,
//             itemBuilder: (context, index) {
//               final doctor = _doctors[index];
//               final doctorId = doctor['id'];
//               return CheckboxListTile(
//                 title: Text(doctor['firstName'] ?? 'No Name'),
//                 subtitle: Text(doctor['specialization'] ?? 'No Specialization'),
//                 value: _selectedDoctors.contains(doctorId),
//                 onChanged: (bool? selected) {
//                   setState(() {
//                     if (selected == true) {
//                       if (!_selectedDoctors.contains(doctorId)) {
//                         _selectedDoctors.add(doctorId);
//                       }
//                     } else {
//                       _selectedDoctors.remove(doctorId);
//                     }
//                     // Update the map with selected doctors for the current date
//                     if (_selectedDays.isNotEmpty) {
//                       final selectedDate = _selectedDays.first;
//                       _dateToDoctorsMap[selectedDate] = _selectedDoctors;
//                       print('Updated Doctors Map for ${selectedDate}: ${_dateToDoctorsMap[selectedDate]}');
//                     }
//                   });
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildErrorMessage() {
//     return Text(
//       _errorMessage!,
//       style: TextStyle(color: Colors.red, fontSize: 14),
//     );
//   }
//
//   Widget _buildSubmitButton() {
//     return Center(
//       child: ElevatedButton(
//         onPressed: _isSubmitting ? null : _submitTravelPlan,
//         child: _isSubmitting ? CircularProgressIndicator() : Text('Submit Travel Plan'),
//       ),
//     );
//   }
// }
//
//
// Positioned(
// bottom: 20,
// right: 0,
// child: ClipPath(
// clipper: MyCustomClipper(),
// child: Container(
// width: 150,
// color: Colors.white30,
// child: Padding(
// padding: const EdgeInsets.all(8.0),
// child: Center(
// child: Text('${_doctorDetails?['visit_type'].toString().toUpperCase()}',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 12
// ),),
// ),
// ),
// ),
// ),
// ),