import 'package:flutter/widgets.dart';
import 'package:sleepaid/data/auth_data.dart';

class AuthProvider with ChangeNotifier{
  AuthData authData = AuthData();

  setTempToggleLoggedIn(){
    authData.isLoggedIn = !authData.isLoggedIn;
    notifyListeners();
  }

  // 1번 로그인 상태 확인
  bool isLoginState() {
    return false;
  }
}

