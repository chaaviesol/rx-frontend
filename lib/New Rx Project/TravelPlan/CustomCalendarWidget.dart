import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<DateTime, List<Map<String, dynamic>>> events;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const CustomCalendar({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.events,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      calendarFormat: CalendarFormat.month,
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        todayDecoration: const BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
        outsideDaysVisible: false,
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, _) {
          if (events.containsKey(date)) {
            return Positioned(
              bottom: 4.0,
              child: Container(
                width: 5.0,
                height: 5.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green, // Marker color
                ),
              ),
            );
          }
          return const SizedBox();
        },
        defaultBuilder: (context, day, focusedDay) {
          final isSunday = day.weekday == DateTime.sunday;
          return Container(
            alignment: Alignment.center,
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isSunday ? Colors.red : Colors.black,
                fontWeight: isSunday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
        selectedBuilder: (context, date, _) => Container(
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        todayBuilder: (context, date, _) => Container(
          decoration: const BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${date.day}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
