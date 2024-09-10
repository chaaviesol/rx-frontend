import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Autotp extends StatefulWidget {
  final dynamic data; // The data containing doctors by date
  const Autotp({required this.data, super.key});

  @override
  State<Autotp> createState() => _AutotpState();
}

class _AutotpState extends State<Autotp> {
  DateTime _selectedDate = DateTime.now(); // Store the selected date
  List<dynamic> _selectedDoctors = []; // List of doctors for the selected day
  Map<DateTime, List<dynamic>> _events = {}; // Events mapped by date

  @override
  void initState() {
    super.initState();
    _populateEvents(); // Populate events on calendar
    _updateSelectedDoctors(_selectedDate); // Initialize with current date's doctors
  }

  // Convert the data from the backend to events for the calendar
  void _populateEvents() {
    widget.data["data"]["data"].forEach((dateString, doctorsList) {
      DateTime date = DateTime.parse(dateString.split('-').reversed.join('-'));
      _events[date] = doctorsList;
    });
  }

  // Update the list of doctors for the selected date
  void _updateSelectedDoctors(DateTime date) {
    setState(() {
      _selectedDoctors = _events[date] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Generated TP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () {
              // Add functionality to import events
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // TableCalendar widget
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            eventLoader: (day) => _events[day] ?? [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
              _updateSelectedDoctors(selectedDay);
            },
            calendarFormat: CalendarFormat.month,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 16),
          // Display list of doctors for the selected date
          Expanded(
            child: _selectedDoctors.isNotEmpty
                ? ListView.builder(
              itemCount: _selectedDoctors.length,
              itemBuilder: (context, index) {
                return Text('${_selectedDoctors}');
                // var doctor = _selectedDoctors[index];
                // return Card(
                //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                //   child: ListTile(
                //     leading: CircleAvatar(
                //       backgroundColor: Colors.blue,
                //       child: Text(doctor['doctor'][0]), // First letter of doctor name
                //     ),
                //     title: Text(doctor['doctor']),
                //     subtitle: Text(doctor['address']['address']),
                //     trailing: Text(doctor['category']),
                //   ),
                // );
              },
            )
                : const Center(child: Text('No doctors for the selected date')),
          ),
        ],
      ),
    );
  }
}
