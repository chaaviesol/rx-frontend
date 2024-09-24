import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/res/app_url.dart';

import '../../../../../../model/doctorModel.dart';
import '../../../../../../services/services.dart';

class EventProvider with ChangeNotifier {
  final ApiService apiService;

  EventProvider({required this.apiService});

  Map<String, List<Doctor>> _doctorsPerDay = {};
  Map<String, List<Doctor>> get doctorsPerDay => _doctorsPerDay;

  Future<void> fetchDoctorsForDay(String day, var area) async {
    try {
      // Convert the area to a list if it's a Set
      List<dynamic> areaList;

      if (area is Set) {
        areaList = area.toList();  // Convert Set to List
        print('Converted Set to List: $areaList');
      } else if (area is Map) {
        areaList = area.values.toList().cast<String>();  // Extract values from Map and convert to List
        print('Converted Map to List: $areaList');
      } else if (area is! List) {
        areaList = [area];  // If it's not a list or map, wrap it in a list
        print('Wrapped area in List: $areaList');
      } else {
        areaList = area;  // If it's already a list, use it directly
        print('Area is already a List: $areaList');
      }

      // Call the API with the converted list of areas
      List<Doctor> doctors = await apiService.getDoctorsForDay(day, areaList);
      print('Doctors: $doctors');

      // Store the result for the day
      _doctorsPerDay[day] = doctors;
      notifyListeners();
    } catch (e) {
      print('Error fetching doctors: $e');
    }
  }


  Future<Map<String, dynamic>> submitPlan(Map<String, dynamic> planData) async {
    print('plandata from function:${jsonEncode(planData)}');
    try {
      final response = await http.post(
        Uri.parse(AppUrl.generateManulTP),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(planData),
      );
      print('resp st code:${response.statusCode}');
      print('resp body:${response.body}');

      if (response.statusCode == 200) {
        // Return the decoded response body as a Map
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // Handle non-200 responses
        print('Failed to submit plan. Status code: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to submit plan. Status code: ${response.statusCode}'
        };
      }
    } catch (error) {
      // Handle any exceptions
      print('Error submitting plan: $error');
      return {
        'success': false,
        'message': 'Error: $error'
      };
    }
  }

  Future cancelTP(tpid) async {
    var data ={
      'tripId':int.parse(tpid.toString())
    };

    try {
      final response = await http.post(
        Uri.parse(AppUrl.cancelTp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print('resp st code:${response.statusCode}');
      print('resp body:${response.body}');

      if (response.statusCode == 200) {
        // Return the decoded response body as a Map
        return jsonDecode(response.body);
      } else {
        // Handle non-200 responses
        print('Failed to submit plan. Status code: ${response.statusCode}');
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': ' ${responseData['message']}'
        };
      }
    } catch (error) {
      // Handle any exceptions
      print('Error submitting plan: $error');
      return {
        'success': false,
        'message': 'Error: $error'
      };
    }
  }

  Future confirmTP(tpid) async {
    var data ={
      'tripId':int.parse(tpid.toString())
    };

    try {
      final response = await http.post(
        Uri.parse(AppUrl.confirmTP),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      print('resp st code:${response.statusCode}');
      print('resp body:${response.body}');

      if (response.statusCode == 200) {
        // Return the decoded response body as a Map
        return jsonDecode(response.body);
      } else {
        // Handle non-200 responses
        print('Failed to submit plan. Status code: ${response.statusCode}');
        var responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': ' ${responseData['message']}'
        };
      }
    } catch (error) {
      // Handle any exceptions
      print('Error submitting plan: $error');
      return {
        'success': false,
        'message': 'Error: $error'
      };
    }
  }



  void addEventForDay(String day, Doctor doctor) {
    if (_doctorsPerDay.containsKey(day)) {
      _doctorsPerDay[day]!.add(doctor);
    } else {
      _doctorsPerDay[day] = [doctor];
    }
    notifyListeners();
  }

  List<Doctor> getEventsForDay(String day) {
    return _doctorsPerDay[day] ?? [];
  }
}
