import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/data/network/login_response.dart';
import 'package:sleepaid/data/network/signup_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class PostEmailLoginService extends BaseService<LoginResponse> {
  Map<String, String> body;

  PostEmailLoginService({required this.body});

  @override
  Future<http.Response?> request() async {
    return fetchPost(body: body);
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'users/login';
  }

  @override
  LoginResponse success(body) {
    LoginResponse responose = LoginResponse.fromJson(body);
    return responose;
  }
}