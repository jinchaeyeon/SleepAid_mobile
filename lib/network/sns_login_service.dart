import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/auth_response.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;

class PostSNSLoginService extends BaseService<LoginResponse> {
  String type;
  String uid;

  static const String NO_SIGNED_USER_MESSAGGE = "해당 소셜로그인으로 가입되어있지 않습니다.";

  PostSNSLoginService({required this.type, required this.uid});

  @override
  Future<http.Response?> request() async {
    return fetchPost(body: {"social_type": type, "uniq_id": uid});
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'users/social_login';
  }

  @override
  LoginResponse success(body) {
    LoginResponse responose = LoginResponse.fromJson(body);
    return responose;
  }
}