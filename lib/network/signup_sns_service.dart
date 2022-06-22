import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/data/network/auth_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class PostSignUpSNSService extends BaseService<LoginResponse> {
  String type;
  String uid;
  String email;
  String licenseKey;

  PostSignUpSNSService({required this.type, required this.uid,
    required this.email, required this.licenseKey});

  @override
  Future<http.Response?> request() async {
    return fetchPost(body: {
      "social_type": type,
      "uniq_id": uid,
      "email": email,
      "license_key": licenseKey
    });
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'users/social_signup';
  }

  @override
  LoginResponse success(body) {
    LoginResponse responose = LoginResponse.fromJson(body);
    return responose;
  }
}