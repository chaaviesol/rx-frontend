import 'package:flutter/material.dart';

class DynamicFormProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _headquartersList = [];
  List<Map<String, dynamic>> get headquartersList => _headquartersList;

  String _selectedHeadquarter = '';
  String _selectedSubHeadquarter = '';
  List<String> _subHeadquartersList = [];

  List<Map<String, dynamic>> forms = [];
  List<WorkHour> workHours = [];

  // Method to update the headquarters list
  void setHeadquartersList(List<Map<String, dynamic>> newHeadquartersList) {
    _headquartersList = newHeadquartersList;
    notifyListeners();
  }

  void updateSelectedHeadquarter(String headquarter) {
    _selectedHeadquarter = headquarter;
    // You may also want to fetch sub-headquarters based on the selected headquarter
    notifyListeners();
  }

  void updateSelectedSubHeadquarter(String subHeadquarter) {
    _selectedSubHeadquarter = subHeadquarter;
    notifyListeners();
  }

  List<String> get subHeadquartersList => _subHeadquartersList;

  void addForm() {
    forms.add({
      'headquarters': '',
      'area': '',
      'address': '',
      'latitude': '',
      'longitude': '',
      'workHours': [],
    });
    notifyListeners();
  }

  void updateForm(int formIndex, Map<String, dynamic> form) {
    forms[formIndex] = form;
    notifyListeners();
  }


  void addWorkHour(int formIndex) {
    forms[formIndex]['workHours'].add(WorkHour(day: '', startTime: '', endTime: ''));
    notifyListeners();
  }


  void updateWorkHour(int formIndex, int workHourIndex, WorkHour workHour) {
    forms[formIndex]['workHours'][workHourIndex] = workHour;
    notifyListeners();
  }


  void removeWorkHour(int formIndex, int workHourIndex) {
    forms[formIndex]['workHours'].removeAt(workHourIndex);
    notifyListeners();
  }

}

class WorkHour {
  String day;
  String startTime;
  String endTime;

  WorkHour({required this.day, required this.startTime, required this.endTime});
}
