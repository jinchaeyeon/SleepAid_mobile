import 'local/app_dao.dart';

class AuthData{
  Map<String, String> userTypes = {
    "email": "email",
    "naver": "naver",
    "google": "google",
    "facebook": "facebook",
  };

  String temporaryLicenseKey = "";

  AuthData();

  /// 유저 토큰 로컬에 저장
  Future setUserToken(String token) async {
    print("setUserToken: $token");
    await AppDAO.setUserToken(token);
  }

  Future<String?> userToken() async {
    return await AppDAO.userToken;
  }

  Future<bool> get isLoggedIn async {
    return await userToken()==null?false:true;
  }

  Future setUserType(String token) async {
    await AppDAO.setUserType(token);
  }

  Future<String?> userType() async {
    return await AppDAO.userType;
  }

}