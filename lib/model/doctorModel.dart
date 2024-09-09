class Doctor {
  final int id;
  final String firstName;
  final String lastName;
  final String visitType;
  final List<Schedule> schedule;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.visitType,
    required this.schedule,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      visitType: json['visitType'],
      schedule: (json['schedule'] as List)
          .map((sch) => Schedule.fromJson(sch))
          .toList(),
    );
  }
}

class Schedule {
  final int id;
  final int drId;
  final String userId;
  final ScheduleDetails scheduleDetails;
  final String? createdDate;

  Schedule({
    required this.id,
    required this.drId,
    required this.userId,
    required this.scheduleDetails,
    this.createdDate,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      drId: json['dr_id'],
      userId: json['user_id'],
      scheduleDetails: ScheduleDetails.fromJson(json['schedule']),
      createdDate: json['createdDate'],
    );
  }
}

class ScheduleDetails {
  final String day;
  final String startTime;
  final String endTime;

  ScheduleDetails({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleDetails.fromJson(Map<String, dynamic> json) {
    return ScheduleDetails(
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}
