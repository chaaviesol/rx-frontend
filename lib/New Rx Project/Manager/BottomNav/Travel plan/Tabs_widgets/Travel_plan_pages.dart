import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rx_route_new/New%20Rx%20Project/Manager/BottomNav/Travel%20plan/New_tp.dart';
import '../../../../../app_colors.dart';
import '../../../../../constants/styles.dart';

class TravelPlanmainpage extends StatefulWidget {
  const TravelPlanmainpage({Key? key}) : super(key: key);

  @override
  State<TravelPlanmainpage> createState() => _TravelPlanmainpageState();
}

class _TravelPlanmainpageState extends State<TravelPlanmainpage> {
  List<Map<String, dynamic>> _travelPlans = [];

  @override
  void initState() {
    super.initState();
    _fetchTravelPlans();
  }

  Future<void> _fetchTravelPlans() async {
    final url = Uri.parse('http://52.66.145.37:3004/rep/getTravelPlan');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"travelPlanId": 41}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          _travelPlans = List<Map<String, dynamic>>.from(data['data']);
        });
      } else {
        // Handle error
        print('Error: ${data['message']}');
      }
    } else {
      // Handle HTTP error
      print('HTTP Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewTravelPlan(),
                      ),
                    );
                  },
                  child: Text('Add Travel Plan', style: text60012),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    // Navigation logic for adding events can be implemented here
                  },
                  child: Text('Add Events', style: text60012),
                ),
              ],
            ),
            SizedBox(height: 20),
            _travelPlans.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Container(
              height: MediaQuery.of(context).size.height * 0.8,
              child: ListView.builder(
                itemCount: _travelPlans.length,
                itemBuilder: (context, index) {
                  final travelPlan = _travelPlans[index];
                  final firstName = travelPlan['drDetails'][0]['firstName'] ?? 'N/A';
                  final date = travelPlan['date'];
                  final status = travelPlan['status'];

                  return Card(
                    child: ListTile(onTap: (){},
                      title: Text('Name: $firstName'),
                      subtitle: Text('Date: $date\nStatus: $status'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
