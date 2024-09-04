import 'package:flutter/material.dart';


class EmpDetailsWidgets{

  static Widget BasicInfo(List<dynamic> doctordetails) {
    return  Padding(
      padding: EdgeInsets.all(25.0),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     Text('Basic Information'),
      //     SizedBox(height: 10,),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text('Name',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
      //               Text('${doctordetails[0]['name']}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
      //             ],
      //           ),
      //           Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text('Qualification',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
      //               Text('${doctordetails[0]['qualification'] ?? 'N/A'}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
      //             ],
      //           ),
      //
      //         ],
      //       ),
      //       Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text('Gender',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
      //               Text('${doctordetails[0]['gender'] ?? 'N/A'}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
      //             ],
      //           ),
      //           Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               Text('Date of birth',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
      //               Text('${doctordetails[0]['date_of_birth'] ?? 'N/A'}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
      //             ],
      //           ),
      //         ],
      //       ),
      //         SizedBox(width: 10,),
      //     ],),
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text('Phone number',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
      //             Text('${doctordetails[0]['mobile'] ?? 'N/A'}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
      //           ],
      //         ),
      //         // Column(
      //         //   crossAxisAlignment: CrossAxisAlignment.start,
      //         //   children: [
      //         //     Text('Designation',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12)),
      //         //     Text('${doctordetails[0]['designation']}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
      //         //   ],
      //         // ),
      //       ],
      //     ),
      //     Text('Email',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12),),
      //     Text('${doctordetails[0]['email'] ?? "N/A"}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
      //     Text('Nationality',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12)),
      //     Text('${doctordetails[0]['nationality'] ?? 'N/A'}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
      //     Text('Address',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12)),
      //     ListView.builder(
      //       shrinkWrap: true,
      //       itemCount: doctordetails[0]['addressDetail'].length,
      //       itemBuilder: (context,index) {
      //         return Text('${doctordetails[0]['addressDetail'][index][0]['address']['address'] ?? 'N/A'}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16));
      //       }
      //     ),
      //     Text('Unique ID',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12)),
      //     Text('${doctordetails[0]['unique_id'] ?? 'N/A'}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
      //     Text('Password',style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12)),
      //     Text('${doctordetails[0]['password'] ?? 'N/A'}',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16)),
      //   ],
      // ),
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