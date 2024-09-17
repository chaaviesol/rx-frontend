class ScheduleNew {
  String? selectedSubHeadquarter;
  List<TimeSlot> timeSlots = [
    TimeSlot(day: 'Mon'),
  ];
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}

class TimeSlot {
  String day;
  String? startTime;
  String? endTime;

  TimeSlot({required this.day, this.startTime = '', this.endTime = ''});
}