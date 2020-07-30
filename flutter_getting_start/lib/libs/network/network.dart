import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_getting_start/libs/network/HttpResult.dart';
import 'package:flutter_getting_start/libs/server_config.dart';

import '../Config.dart';

class ResultData {
  var data;
  int code;
  var headers;

  ResultData(this.data, this.code, {this.headers});

  bool isSuccess() => code == Code.SUCCESS;
  String getErrorMsg() => data;
  String getCodeString() => Code.code2Str(code);
}

///网络请求错误编码
class Code {
  static const NETWORK_ERROR = -1;
  static const NETWORK_TIMEOUT = -2;
  static const INVALID_TOKEN  = -3;
  static const UNKNOWN_CODE  = -4;
  static const EXCEPTION  = -5;
  static const UNKNOWN_RESPONSE  = -6;

  static const SUCCESS = 200;

  static String code2Str(int code){
    switch(code){
      case NETWORK_ERROR:
        return "NETWORK_ERROR";
      case NETWORK_TIMEOUT:
        return "NETWORK_TIMEOUT";
      case INVALID_TOKEN:
        return "INVALID_TOKEN";
      case UNKNOWN_CODE:
        return "UNKNOWN_CODE";
      case EXCEPTION:
        return "EXCEPTION";
      case UNKNOWN_RESPONSE:
        return "UNKNOWN_RESPONSE";
      case SUCCESS:
        return "SUCCESS";

      default:
        return "Unknown-Code($code)";
    }
  }
}

class NetworkComponent{

  static Options _options;
  static Dio _dio;

  static Dio get dio => _dio ??= new Dio();
  static Options get options =>
      _options ??= new Options(
        baseUrl: ServerConfig.BASE_URL,
        //headers: Config.common_headers,
        connectTimeout: 40000,
        receiveTimeout: 40000,
        followRedirects: true,);

  ///the data from json.
  dynamic data;

  NetworkComponent({data}){
    this.data = data;
  }

  Future<ResultData> get(String path, Map<String, dynamic> params, {Map<String, dynamic> extraHeaders}) async {
    Options ops = options.merge(method: "GET");
    return _request(path, params, ops,
        extraHeaders: extraHeaders
    );
  }
  Future<ResultData> post(String path, Map<String, dynamic> params, {Map<String, dynamic> extraHeaders}) async {
    Options ops = options.merge(method: "POST", contentType: ContentType.text);
    return _request(path, _param2String(params), ops,
        extraHeaders: extraHeaders
    );
  }

  Future<ResultData> postBody(String path, Map<String, dynamic> params, {Map<String, dynamic> extraHeaders}) async {
  //  "Content-Type: application/json", "Accept: application/json"
    Options ops = options.merge(method: "POST", contentType: ContentType.json);
    return _request(path, params, ops,
        extraHeaders: extraHeaders); //jsonEncode(params)
  }

  Future<ResultData> delete(url, Map<String, dynamic> params, {Map<String, dynamic> extraHeaders}) async{
    return _request(url, params, new Options(method: 'DELETE'),
        extraHeaders: extraHeaders);
  }

  Future<ResultData> put(url, Map<String, dynamic> params, {Map<String, dynamic> extraHeaders}) async{
    return _request(url, params, new Options(method: "PUT", contentType: ContentType.text),
      extraHeaders: extraHeaders);
  }

  String _param2String(Map<String, dynamic> params){
    StringBuffer sb = StringBuffer();
    if(params != null){
      bool first = true;
      params.forEach((key, value) {
        if(!first){
          sb.write("&");
        }else{
          first = false;
        }
        sb.write(key);
        sb.write("=");
        sb.write(value);
      });
    }
    return sb.toString();
  }

  ///发起网络请求
  ///[ url] 请求url
  ///[ params] 请求参数
  ///[ header] 外加头
  ///[ option] 配置
  Future<ResultData> _request(String url, dynamic params, Options option, {Map<String, dynamic> extraHeaders}) async {

    //没有网络
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return new ResultData(null, Code.NETWORK_ERROR);
    }
    option.headers = await Config.commonHeaders;
    if(extraHeaders != null){
      option.headers.addAll(extraHeaders);
    }

    // interceptor
    if (Config.DEBUG) {
      print("\n================== 请求数据 ==========================");
      print("req url = $url");
      print("req headers = ${option.headers}");
      print("req params = ${params??params.toString()??""}");

      dio.interceptor.response.onSuccess = (Response e){
        print("\n================== 响应数据 ==========================");
        print("res code = ${e.statusCode}");
        print("res data = ${e.data}");
        print("\n");
        return e;
      };
      dio.interceptor.response.onError = (DioError e){
        print("\n================== 错误响应数据 ======================");
        print("error type = ${e.type}");
        print("error message = ${e.message}");
        print("error stackTrace = ${e.stackTrace}");
        print("\n");
        return e;
      };
      //for dio.interceptor.request.onSend return value should be Future<Response> here we should not intercept it.
      /*dio.interceptor.request.onSend = (Options options){
        print("\n================== 请求数据 ==========================");
        print("req url = ${options.path}");
        print("req headers = ${options.headers}");
        print("req params = ${options.data}");
        return options;
      };*/
    }
    Response response;
    try {
      response = await dio.request(url, data: params, options: option);
    } on DioError catch (e) {
      int code = e.type == DioErrorType.CONNECT_TIMEOUT ? Code.NETWORK_TIMEOUT : Code.EXCEPTION;
      if (Config.DEBUG) {
        print('请求异常: ' + e.toString());
        print('请求异常 url: ' + url);
      }
      return new ResultData(e.toString(), code);
    }

    try {
      if (option.contentType != null && option.contentType.primaryType == "text") {
        return _processSuccess(response);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _processSuccess(response);
      }
    } catch (e) {
      print(e.toString() + url);
      return new ResultData(response.data, Code.EXCEPTION, headers: response.headers);
    }
    print("unknown: response.stateCode = ${response.statusCode}");
    return new ResultData(null, Code.UNKNOWN_RESPONSE, headers: response.headers);
  }

  ResultData _processSuccess(Response res){
    if(data != null){
      HttpBaseResult result =  HttpBaseResult();
      result.fromJson(res.data);
      if(ServerConfig.SUCCESS_CODES.contains(result.code)){
        //string -> direct return
        if(data is String){
           return new ResultData(result.data, Code.SUCCESS);
        }
        HttpResult hr = HttpResult(data);
        hr.fromJson(res.data);
        return new ResultData(hr.data, Code.SUCCESS);
      }else if(ServerConfig.INVALID_TOKEN_CODES.contains(result.code)){
        return new ResultData(result.msg, Code.INVALID_TOKEN);
      }else{
        print("unknown: code = ${result.code}");
        return new ResultData(result.msg, Code.UNKNOWN_CODE);
      }
    }
    return new ResultData(res.data, Code.SUCCESS, headers: res.headers);
  }
}

