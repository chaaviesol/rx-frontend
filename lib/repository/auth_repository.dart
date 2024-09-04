

import '../data/network/base_api_services.dart';
import '../data/network/network_api_service.dart';
import '../res/app_url.dart';

class AuthRepository{
  BaseApiServices apiServices = NetworkApiServices();

  Future<dynamic>loginApi(dynamic data)async{
    try{
      dynamic response = await apiServices.postAPiResponse(AppUrl.login, data);
      return response;

    }catch(e){
      throw e;
    }
  }
}