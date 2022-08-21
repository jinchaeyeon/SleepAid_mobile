import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/network/base_service.dart';
import 'package:http/http.dart' as http;
import '../data/network/push_response.dart';

class PostFCMTokenService extends BaseService<PushResponse> {
  String token;

  PostFCMTokenService({required this.token});

  @override
  Future<http.Response?> request() async {
    return fetchPost(body: {
      "registration_id": token,
      "cloud_message_type": "FCM",
      "active":true,
      ///todo name 어떻게 해야하는지 문의
      "name":""
    });
  }

  @override
  setUrl() {
    return AppDAO.baseUrl + 'fcm/';
  }

  @override
  PushResponse success(body) {
    PushResponse responose = PushResponse.fromJson(body);
    return responose;
  }
}