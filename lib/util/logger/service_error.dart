import 'dart:convert';
import 'dart:developer';

import 'package:sleepaid/util/util.dart';

class ServiceError {
  static const String NON_FIELD_ERRORS = 'non_field_errors';
  static const String UNKNOWN_ERROR = 'unknown_error';
  String? code;
  String? message;
  final String? spec;



  ServiceError({
    this.code = UNKNOWN_ERROR,
    this.message,
    this.spec,
  }) {
    Util.log('error $this');
  }

  @override
  String toString() {
    return 'code = $code\nmessage = $message';
  }

  factory ServiceError.fromJson(Map<String, dynamic> body) {
    ServiceError ret = ServiceError(
      code: body['code']??=UNKNOWN_ERROR,
      message: body['message'] as String?,
    );

    if(body['non_field_errors'] != null){
      ret.code = NON_FIELD_ERRORS;
      ret.message = body['non_field_errors'][0]['message'];
    }


    Util.log('error $ret');
    return ret;
  }
}
