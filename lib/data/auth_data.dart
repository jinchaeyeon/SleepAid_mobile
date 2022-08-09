import 'package:flutter/src/services/text_input.dart';
import 'package:sleepaid/data/local/condition_review.dart';

import 'local/app_dao.dart';

class AuthData{
  AuthData();

  String temporaryLicenseKey = "";
  String temporarySNSType = "";
  String temporarySNSUID = "";

  static Map<String, String> userTypes = {
    "email": "email",
    "naver": "naver",
    "google": "google",
    "facebook": "facebook",
  };

  DateTime created = DateTime.now().subtract(const Duration(days: 1));

  String get temporarySNSPW{
    return "${temporarySNSType}${dateFormat.format(DateTime.now())}";
  }


  /// 유저 토큰 로컬에 저장
  Future setUserToken(String? token) async {
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

  Future setUserCreated(DateTime created) async {
    await AppDAO.setUserCreated(created);
  }

  DateTime getUserCreated(){
    if(created == null){
      return DateTime.now().subtract(Duration(days:1));
    }
    return created!;
  }

  Future setAutoLogin(bool isAutoLogin) async {
    await AppDAO.setAutoLogin(isAutoLogin);
  }

}