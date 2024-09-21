import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rx_route_new/Util/Utils.dart';
import 'package:rx_route_new/app_colors.dart';
import 'package:rx_route_new/res/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';

class Autotp extends StatefulWidget   {
  final Map<String, dynamic> data; // List of dynamic data

  Autotp({required this.data, super.key});

  @override
  State<Autotp> createState() => _AutotpState();
}

class _AutotpState extends State<Autotp> {
  // bool _loading = true; // Loading state variable
  String selectedDate = '';
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();


  // Convert the data from the backend to events for the calendar
  // void _populateEvents() {
  //   print('populate called..');
  //   final DateFormat formatter = DateFormat('dd-MM-yyyy'); // Define the date format
  //
  //   if (widget.data != null && widget.data.isNotEmpty) {
  //     for (var item in widget.data) {
  //       try {
  //         // Ensure item is a map and has the necessary fields
  //         if (item is Map && item.containsKey('date') && item.containsKey('doctors')) {
  //           String dateString = item['date'];
  //           List<dynamic> doctorsList = item['doctors'];
  //
  //           DateTime date = formatter.parse(dateString); // Parse the date
  //
  //           // Ensure the date is added to the events map correctly
  //           if (_events[date] == null) {
  //             _events[date] = [];
  //           }
  //
  //           // Add the list of doctors to the date's events
  //           _events[date]!.addAll(doctorsList);
  //         } else {
  //           print('Error: Unexpected item format. Item: $item');
  //         }
  //       } catch (e) {
  //         print('Error parsing date or handling doctors list: $e');
  //       }
  //     }
  //   } else {
  //     print('Error: widget.data is null or not a valid structure');
  //   }
  // }



  // Update the list of doctors for the selected date
  // void _updateSelectedDoctors(DateTime date) {
  //   setState(() {
  //     _selectedDoctors = _events[date] ?? [];
  //   });
  // }

  // Submit AutoTP to backend
  Future<void> submitAutoTp() async {
    print('auto submit ');
    // setState(() {
    //   _loading = true; // Show loader when submitting
    // });

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
      print('${response.statusCode}');
      print('${response.body}');

      if(response.statusCode == 200){
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage('${responseData['message']}', context);
      }else{
        Utils.flushBarErrorMessage('error aan mone', context);
      }

    } catch (e) {
      print('Error: $e');
      Utils.flushBarErrorMessage('Failed to submit AutoTP', context);
    } finally {
      // setState(() {
      //   _loading = false; // Stop loading after submission
      // });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    print('widget data :${widget.data}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Schedule'),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            onPressed: () {
              submitAutoTp();
            },
            child: Text('Continue', style: TextStyle(color: AppColors.whiteColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor),
            onPressed: () {},
            child: Text('Cancel', style: TextStyle(color: AppColors.whiteColor)),
          )
        ],
      ),
      body:
      // _loading ? Center(child: CircularProgressIndicator(),):
      Column(
        children: [
          // Dropdown for selecting date
          // Calendar view
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // Update `_focusedDay` to reflect the current view
              });
            },
            calendarFormat: CalendarFormat.month,
            // Customizing the calendar style
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
          ),
          // Display doctors' details
          Expanded(
            child: ListView.builder(
              itemCount: widget.data[formatDate(_selectedDay)]?.length ?? 0,
              itemBuilder: (context, index) {
                final doctor = widget.data[formatDate(_selectedDay)]![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        width: 1,color:doctor['visit_type'] == 'core'
                          ? AppColors.tilecolor2
                          : doctor['visit_type'] == 'supercore'
                          ? AppColors.tilecolor1
                          : AppColors.tilecolor3, )
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${doctor['doctor'][3]}',style: TextStyle(color: AppColors.whiteColor),),
                        backgroundColor:  doctor['visit_type'] == 'core'
                            ? AppColors.tilecolor2
                            : doctor['visit_type'] == 'supercore'
                            ? AppColors.tilecolor1
                            : AppColors.tilecolor3,
                      ),
                      title: Text(doctor['doctor']),
                      // subtitle: Text('${doctor['category']} - ${doctor['day']}'),
                      trailing: Text(doctor['address']['address']),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    // Format date as "dd-MM-yyyy" for matching with keys in your data
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }


}
class DoctorSchedulePage extends StatefulWidget {
  @override
  State<DoctorSchedulePage> createState() => _DoctorSchedulePageState();
}

class _DoctorSchedulePageState extends State<DoctorSchedulePage> {
  // Sample data from your JSON
  final Map<String, List<Map<String, dynamic>>> data = {
    "01-10-2024": [
      {
        "doctor": "Dr.Sathyan",
        "category": "supercore",
        "day": "Tuesday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Suman",
        "category": "supercore",
        "day": "Tuesday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Abhishekha",
        "category": "important",
        "day": "Tuesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      }
    ],
    "02-10-2024": [
      {
        "doctor": "Dr.Anusree",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2732268",
          "longitude": "75.7720265"
        }
      },
      {
        "doctor": "Dr.Arpitha",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      },
      {
        "doctor": "Dr.Arya",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      },
      {
        "doctor": "Dr.Aswin",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      },
      {
        "doctor": "Dr.Santi",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Akhil",
        "category": "important",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2732268",
          "longitude": "75.7720265"
        }
      }
    ],
    "04-10-2024": [
      {
        "doctor": "Dr.Musthafa",
        "category": "supercore",
        "day": "Friday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      }
    ],
    "05-10-2024": [
      {
        "doctor": "Dr.Sathyan",
        "category": "supercore",
        "day": "Saturday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Suman",
        "category": "supercore",
        "day": "Saturday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Gikhin",
        "category": "important",
        "day": "Saturday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      }
    ],
    "09-10-2024": [
      {
        "doctor": "Dr.Anusree",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2732268",
          "longitude": "75.7720265"
        }
      },
      {
        "doctor": "Dr.Arpitha",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      },
      {
        "doctor": "Dr.Arya",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      },
      {
        "doctor": "Dr.Aswin",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      },
      {
        "doctor": "Dr.Santi",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode"
        }
      }
    ],
    "11-10-2024": [
      {
        "doctor": "Dr.Sathyan",
        "category": "supercore",
        "day": "Friday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Suman",
        "category": "supercore",
        "day": "Friday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Musthafa",
        "category": "supercore",
        "day": "Friday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      }
    ],
    "12-10-2024": [
      {
        "doctor": "Dr.Abhishekha",
        "category": "important",
        "day": "Saturday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      }
    ],
    "15-10-2024": [
      {
        "doctor": "Dr.Sathyan",
        "category": "supercore",
        "day": "Tuesday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Suman",
        "category": "supercore",
        "day": "Tuesday",
        "address": {
          "address": "ashok house kozhikode"
        }
      }
    ],
    "16-10-2024": [
      {
        "doctor": "Dr.Anusree",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2732268",
          "longitude": "75.7720265"
        }
      },
      {
        "doctor": "Dr.Arpitha",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      },
      {
        "doctor": "Dr.Arya",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      },
      {
        "doctor": "Dr.Aswin",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      },
      {
        "doctor": "Dr.Santi",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Akhil",
        "category": "important",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2732268",
          "longitude": "75.7720265"
        }
      }
    ],
    "18-10-2024": [
      {
        "doctor": "Dr.Musthafa",
        "category": "supercore",
        "day": "Friday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      }
    ],
    "19-10-2024": [
      {
        "doctor": "Dr.Sathyan",
        "category": "supercore",
        "day": "Saturday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Suman",
        "category": "supercore",
        "day": "Saturday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Gikhin",
        "category": "important",
        "day": "Saturday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      }
    ],
    "23-10-2024": [
      {
        "doctor": "Dr.Anusree",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2732268",
          "longitude": "75.7720265"
        }
      },
      {
        "doctor": "Dr.Arpitha",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      },
      {
        "doctor": "Dr.Arya",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      },
      {
        "doctor": "Dr.Aswin",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      },
      {
        "doctor": "Dr.Santi",
        "category": "core",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode"
        }
      }
    ],
    "25-10-2024": [
      {
        "doctor": "Dr.Sathyan",
        "category": "supercore",
        "day": "Friday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Suman",
        "category": "supercore",
        "day": "Friday",
        "address": {
          "address": "ashok house kozhikode"
        }
      },
      {
        "doctor": "Dr.Musthafa",
        "category": "supercore",
        "day": "Friday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2757286",
          "longitude": "75.7779643"
        }
      }
    ],
    "30-10-2024": [
      {
        "doctor": "Dr.Anusree",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2732268",
          "longitude": "75.7720265"
        }
      },
      {
        "doctor": "Dr.Arpitha",
        "category": "supercore",
        "day": "Wednesday",
        "address": {
          "address": "ashok house kozhikode",
          "latitude": "11.2600489",
          "longitude": "75.7900391"
        }
      }
    ]
  };

  String selectedDate = "01-10-2024";

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('Doctor Schedule'),
    ),
    body: Column(
      children: [
        // Dropdown for selecting date
        // Calendar view
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay; // Update `_focusedDay` to reflect the current view
            });
          },
          calendarFormat: CalendarFormat.month,
          // Customizing the calendar style
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
        ),
        // Display doctors' details
        Expanded(
          child: ListView.builder(
            itemCount: data[formatDate(_selectedDay)]?.length ?? 0,
            itemBuilder: (context, index) {
              final doctor = data[formatDate(_selectedDay)]![index];
              return ListTile(
                title: Text(doctor['doctor']),
                subtitle: Text('${doctor['category']} - ${doctor['day']}'),
                trailing: Text(doctor['address']['address']),
              );
            },
          ),
        ),
      ],
    ),
    );
  }

  String formatDate(DateTime date) {
    // Format date as "dd-MM-yyyy" for matching with keys in your data
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }
}
