enum USER_TYPE{
  NO_USER,
  EMAIL_USER,
  FACEBOOK_USER,
  GOOGLE_USER,
  NAVER_USER
}

class AuthData{
  USER_TYPE userType = USER_TYPE.NO_USER;
  bool isLoggedIn = true;
  bool isCheckedLicense = false;

  AuthData({this.isLoggedIn = false});
}