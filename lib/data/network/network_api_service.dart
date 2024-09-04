import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import '../app_exceptions.dart';
import 'base_api_services.dart';
import 'package:http/http.dart' as http;
class NetworkApiServices extends BaseApiServices {

@override
Future getAPiResponse(String url) async {

  dynamic responseJson;

  try{

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10)) ;
    responseJson = returnResponse(response);

  }on SocketDirection{
    throw FetchDataException('No internet connection');
  }

  return responseJson;
}


@override
Future postAPiResponse(String url,dynamic data)async {

  dynamic responseJson;

  try{
    Response response =await http.post(Uri.parse(url),body: data).timeout(const Duration(seconds: 10));

    responseJson=returnResponse(response);

  }on SocketException{
    throw FetchDataException('No internet connection');
  }
  return responseJson;
}



dynamic returnResponse(http.Response response){

  switch(response.statusCode){

    case 200:
      dynamic responseJson =jsonDecode(response.body);
      return responseJson;

    case 400:
      throw BadRequestException(response.body.toString());

    case 500:
    case 404:
      throw UnAuthorisedException(response.body.toString());

    default:
      throw FetchDataException('error accrued while communicating with server, statusCode:${response.statusCode}',
      );
  }
}}