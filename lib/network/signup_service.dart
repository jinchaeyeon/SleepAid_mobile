import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/data/network/signup_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class PostSignUpService extends BaseService<SignUpResponse> {
  Map<String, String> body;

  PostSignUpService({required this.body});

  @override
  Future<http.Response?> request() async {
    return fetchPost(body: body);
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'signup';
  }

  @override
  SignUpResponse success(body) {
    SignUpResponse signupResponose = SignUpResponse.fromJson(body);
    return signupResponose;
  }
}