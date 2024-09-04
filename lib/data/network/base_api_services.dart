
abstract class BaseApiServices{

  Future<dynamic> getAPiResponse(String url);

  Future<dynamic> postAPiResponse(String url, dynamic data);
}