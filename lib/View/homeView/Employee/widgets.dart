import 'package:flutter/material.dart';

class EmpDetailsWidgets{

  static Widget BasicInfo(Map<String, dynamic> empDetails) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text(
                  '${empDetails['name']}',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  softWrap: true, // Allow wrapping at word boundaries
                  overflow: TextOverflow.visible, // Ensure no text is hidden
                ),
                SizedBox(height: 10),
                Text('Qualification', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text('${empDetails['qualification'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 10),
                Text('Gender', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text('${empDetails['gender'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 10),
                Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text('${empDetails['date_of_birth'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text('${empDetails['mobile'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 10),
                Text('Email', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text('${empDetails['email'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 10),
                Text('Address', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text('${empDetails['address'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 10),
                Text('Unique ID', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text('${empDetails['uniqueId'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 10),
                Text('Nationality', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text('${empDetails['nationality'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 10),
                Text('Password', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12)),
                Text('${empDetails['password'] ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 40,),
              ],
            ),
          ],
        ),
      ),
    );
  }


  static Widget Documents(List<dynamic> doctordetails) {
    return  Padding(
      padding: EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Documents'),
          SizedBox(height: 10,),
        ],
      ),
    );
  }

  static Widget Notes(List<dynamic> doctordetails) {
    return  Padding(
      padding: EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes'),
          SizedBox(height: 10,),
        ],
      ),
    );
  }


}