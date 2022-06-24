import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/util/logger/service_error.dart';
import 'package:sleepaid/util/util.dart';

const MAX_RETRY_COUNT = 0;

abstract class BaseService<T> {
  int _retryCount = 0;
  String? _url;
  final bool withAccessToken;
  final bool jsonContentType;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'OS-Type': Platform.isIOS ? 'IOS' : 'ANDROID',
  };

  BaseService({this.withAccessToken = true, this.jsonContentType = true});

  dynamic setUrl();

  String? get url => _url;

  dynamic _contentTypes() {
    return jsonContentType
        ? {'Content-Type': 'application/json'}
        : {'Content-Type': 'application/x-www-form-urlencoded'};
  }

  dynamic _extraHeaders() async {
    String? token = await AppDAO.userToken;
    return withAccessToken
        ? {'Authorization': 'Bearer Token $token', 'serviceType': 'sleepaid'}
        : {'serviceType': 'sleepaid'};
  }

  void setContentType(String contentType){
    _headers['Content-Type'] = contentType;
  }
  static const Map<String, String> emptyMap = {};
  Future<dynamic> start({Map<String, String> extraHeaders = emptyMap}) async {
    bool isConnected = await checkNetworkState().then((isConnected){
      if(!isConnected){
        showToast("네트워크 연결 상태를 확인해주세요.");
      }
      return isConnected;
    });
    if(!isConnected) return;

    _url = await setUrl();
    var extra = await _extraHeaders();
    if (extra != null && extra is Map<String, String>) {
      _headers.addAll(extra);
    }
    _headers.addAll(_contentTypes());
    _headers.addAll(extraHeaders);
    return await _start();
  }

  Future<dynamic> _start() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    http.Response? response;
    try {
      response = await request();
      Util.log('BaseService request headers ${response?.request?.headers}');
      Util.log('BaseService request url ${response?.request?.url}');
      Util.log('BaseService request method ${response?.request?.method}');
    } catch (e, s) {
      return ServiceError(code: '$e', message: '$s');
    }

    if (response == null) {
      return ServiceError(code: 'null_response', message: 'response is null');
    }

    if (response.body == null) {
      return ServiceError(
          code: 'null_response_body', message: 'body of response is null');
    }

    var body;
    try {
      if (response.bodyBytes.isEmpty) {
      } else {
        log("response: ${response.body}");
        log("response: ${response.headers}");
        body = json.decode(
            const Utf8Decoder(allowMalformed: false).convert(response.bodyBytes));
      }
    } catch (e, s) {
      Util.log('BaseService $e\n$s');
      body = (String.fromCharCodes(response.bodyBytes));
    }
    Util.log('BaseService status code : ${response.statusCode}');
    Util.log('BaseService body : ${body.toString()}');

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      return success(body);
    } else {
      /// update token
      _retryCount++;
      if (_retryCount < MAX_RETRY_COUNT) {
        /// retry
        return await _start();
      }
    }
    try {
      return ServiceError.fromJson(body);
    } catch (e, s) {
      Util.log('BaseService $e\n$s');
      return ServiceError(spec: body);
    }
  }

  Future<http.Response?> request();

  T? success(dynamic body);

  Future<http.Response> fetchGet() async {
    Util.log('request url : $url');
    Util.log('request header : $_headers');
    return await http.get(Uri.parse(url!), headers: _headers);
  }

  Future<http.Response> fetchPut({
    dynamic body,
    Encoding? encoding,
  }) async {
    if(_headers["Content-Type"] == "application/json"){
      body = jsonEncode(body);
    }
    debugPrint('request url : $url');
    debugPrint('request body : $body');
    debugPrint('request header : $_headers');
    return await http.put(Uri.parse(url!),
        headers: _headers, body: body, encoding: encoding);
  }

  Future<http.Response> fetchPost({
    dynamic body,
  }) async {
    if(_headers["Content-Type"] == "application/json"){
      body = jsonEncode(body);
    }
    debugPrint('request url : $url');
    debugPrint('request body : $body');
    debugPrint('request header : $_headers');
    return await http.post(Uri.parse(url!), headers: _headers, body: body);
  }

  Future<http.Response> fetchDelete() async {
    debugPrint('request url : $url');
    debugPrint('request header : $_headers');
    return await http.delete(Uri.parse(url!), headers: _headers);
  }
}
