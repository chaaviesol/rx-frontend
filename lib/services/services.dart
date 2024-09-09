import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../New Rx Project/Manager/BottomNav/Travel plan/Manual/provider/DynamicFormProvider.dart';
import '../model/doctorModel.dart';

class ApiService{
  final String baseUrl;

  ApiService({required  this.baseUrl});

  Future<List<Doctor>> getDoctorsForDay(String selectedDay,var area)async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? uniqueId = preferences.getString('uniqueID');
    print('area is that :${area}');
    final url = Uri.parse('$baseUrl/user/listDoctors');
    var data = {
      "areas" : area,
      "userId":uniqueId,
      "day":selectedDay.toLowerCase()
    };
    final  response = await http.post(
        url,
        headers: {
          'content-Type':'application/json',
        },
        body: jsonEncode(data)
    );
    print('sending:${data}');
    print('st code error from herer:${response.statusCode}');
    print('response:${jsonDecode(response.body)}');
    if(response.statusCode == 200){
      final Map<String,dynamic> jsonResponse = jsonDecode(response.body);
      if(jsonResponse['success']){
        List<Doctor> doctors = (jsonResponse['data'] as List).map((doc) => Doctor.fromJson(doc['doctor'])).toList();
        print('doctors in $selectedDay day:$doctors');
        return doctors;
      }else {
        throw Exception('Failed to load doctors');
      }
    }else{
      throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchHeadquarters(DynamicFormProvider provider) async {
    final response = await http.get(Uri.parse('${baseUrl}/rep/get_headquarters'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        provider.setHeadquartersList(List<Map<String, dynamic>>.from(data['data']));
      }
    }
  }
}