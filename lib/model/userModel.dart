class User {
  final bool error;
  final bool success;
  final String message;
  final List<UserData>? data;

  const User({
    required this.error,
    required this.success,
    required this.message,
    this.data,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      error: json['error'] as bool,
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? (json['data'] as List).map((e) => UserData.fromJson(e)).toList() : null,
    );
  }
}

class UserData {
  final int id;
  final String uniqueId;
  final String repName;
  final String gender;
  final String dateOfBirth;
  final String nationality;
  final String mobile;
  final String email;
  final String designation;
  final String qualification;
  final String? address;
  final int reportingOfficer;
  final int createdBy;
  final String createdDate;
  final String type;
  final String password;

  const UserData({
    required this.id,
    required this.uniqueId,
    required this.repName,
    required this.gender,
    required this.dateOfBirth,
    required this.nationality,
    required this.mobile,
    required this.email,
    required this.designation,
    required this.qualification,
    this.address,
    required this.reportingOfficer,
    required this.createdBy,
    required this.createdDate,
    required this.type,
    required this.password,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int,
      uniqueId: json['unique_id'] as String,
      repName: json['rep_name'] as String,
      gender: json['gender'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      nationality: json['Nationality'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String,
      designation: json['designation'] as String,
      qualification: json['qualification'] as String,
      address: json['address'] as String?,
      reportingOfficer: json['reporting_officer'] as int,
      createdBy: json['created_by'] as int,
      createdDate: json['created_date'] as String,
      type: json['type'] as String,
      password: json['password'] as String,
    );
  }
}
