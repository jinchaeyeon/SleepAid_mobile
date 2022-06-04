import 'package:sleepaid/util/util.dart';

class ServiceError {
  final String? code;
  final String? message;
  final String? spec;

  ServiceError({
    this.code = "unknown error",
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
      code: body['code'] as String?,
      message: body['message'] as String?,
    );

    Util.log('error $ret');
    return ret;
  }
}
