import 'package:flutter/cupertino.dart';

class HttpBaseResult {
  //@SerializedName(value = "code")
  int code;

  //@SerializedName(value = "message")
  String msg;

  var data;

   void fromJson(Map<String, dynamic> map) {
    code = map["code"];
    msg = map["message"];
    var val = map["data"];
    if(val is String){
      data = val;
    }
  }
}

abstract class DataRes {
  void fromJson(Map<String, dynamic> map);
}

class HttpResult<T extends DataRes> extends HttpBaseResult {
  final T data;

  HttpResult(this.data);

  @override
  void fromJson(Map<String, dynamic> map) {
    super.fromJson(map);
    Map<String, dynamic> map2 = map["data"];
    data.fromJson(map2);
  }
}
