import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/auth_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class PostSignUpEmailService extends BaseService<LoginResponse> {
  Map<String, String> body;

  PostSignUpEmailService({required this.body});

  @override
  Future<http.Response?> request() async {
    return fetchPost(body: body);
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'users/email_signup';
  }

  @override
  LoginResponse success(body) {
    LoginResponse responose = LoginResponse.fromJson(body);
    return responose;
  }
}