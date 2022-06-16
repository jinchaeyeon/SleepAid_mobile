import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sleepaid/data/auth_data.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/local/condition_review.dart';
import 'package:sleepaid/data/network/base_response.dart';
import 'package:sleepaid/data/network/license_response.dart';
import 'package:sleepaid/data/network/login_response.dart';
import 'package:sleepaid/data/network/signup_response.dart';
import 'package:sleepaid/data/network/sleep_condition_response.dart';
import 'package:sleepaid/network/email_login_service.dart';
import 'package:sleepaid/network/license_service.dart';
import 'package:sleepaid/network/signup_service.dart';
import 'package:sleepaid/network/sleep_condition_service.dart';
import 'package:sleepaid/util/logger/service_error.dart';

class DataProvider with ChangeNotifier{
  bool isLoading = false;
  SleepConditionItemListResponse? sleepConditionItemResponse;
  //어제 컨디션 리뷰
  ConditionReview? yesterdayConditionReview;

  Future<void> setLoading(bool showLoading) async{
    isLoading = showLoading;
    print("--isLoading: $isLoading");
    notifyListeners();
  }

  /// 수면컨디션 목록
  /// 필수는 고정이므로, 선택목록을 가져온다
  Future<int> getSleepConditionQuestions() async{
    DateTime yesterDay = DateTime.now().subtract(const Duration(days: 1));
    var format = DateFormat.yMd();
    var params = {"date": format.format(yesterDay)};
    var response = await GetSleepConditionService(body:params).start();
    if(response is SleepConditionItemListResponse){
      sleepConditionItemResponse = response;
      //응답체크
      return BaseResponse.STATE_CORRECT;
    }else{
      //이상응답
      return BaseResponse.STATE_UNCORRECT;
    }
  }

  String getYesterdayDateTime() {
    return "2022년 n월 m일";
    // if(yesterdayConditionReview.getYesterdayStr() !=
    //     dateFormat.format(DateTime.now().subtract(const Duration(days:1)))) {
    //
    // }
    // return yesterdayConditionReview?.getYesterdayStr()??"";
  }

  Future<bool> checkValidEmail(String email) async{
    //todo 처리필요
    return true;
  }

  Future<bool> login(String email, String pw, {bool isAutoLogin = false}) async{
    debugPrint("login: $email | $pw | $isAutoLogin");
    var params = {'email': email, 'password':pw};
    var response = await PostEmailLoginService(body:params).start();
    if(response is LoginResponse){
      //정상 응답이면 로그인 체크
      if(isAutoLogin){
        await AppDAO.authData.setUserToken(response.token!);
      }
      return true;
    }else if(response is ServiceError){
      Fluttertoast.showToast(msg:response.message??ServiceError.UNKNOWN_ERROR);
    }
    else{
      return false;
    }
    return false;
  }
}

