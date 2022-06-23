import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/local/condition_review.dart';
import 'package:sleepaid/data/network/base_response.dart';
import 'package:sleepaid/data/network/auth_response.dart';
import 'package:sleepaid/data/network/binaural_beat_parameter_response.dart';
import 'package:sleepaid/data/network/calendar_response.dart';
import 'package:sleepaid/data/network/electro_stimulation_parameter_response.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';
import 'package:sleepaid/data/network/sleep_condition_response.dart';
import 'package:sleepaid/network/email_login_service.dart';
import 'package:sleepaid/network/get_binaural_beats_service.dart';
import 'package:sleepaid/network/get_electro_stimulations_service.dart';
import 'package:sleepaid/network/get_sleep_condition_service.dart';
import 'package:sleepaid/network/reset_password_service.dart';
import 'package:sleepaid/util/logger/service_error.dart';
import 'package:sleepaid/util/statics.dart';

class DataProvider with ChangeNotifier{
  bool isLoading = false;
  SleepConditionItemListResponse? sleepConditionItemResponse;
  //어제 컨디션 리뷰
  ConditionReview? yesterdayConditionReview;
  /// 비트 출력시 true
  bool isPlayingBeat = false;

  void setLoading(bool showLoading) {
    isLoading = showLoading;
    print("--isLoading: $isLoading");
    notifyListeners();

    if(isLoading){
      Future.delayed(const Duration(seconds: TIMEOUT_SECOND),(){
        isLoading = false;
        notifyListeners();
      });
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

  ///이메일에 리셋 링크 전송
  Future<Object> sendResetPasswordLinkToEmail(String email) async{
    setLoading(true);
    var result = await PostResetPasswordService(email:email).start();
    setLoading(false);
    return result;
  }

  Future<bool> login(String email, String pw, {bool isAutoLogin = false}) async{
    debugPrint("login: $email | $pw | $isAutoLogin");
    var params = {'email': email, 'password':pw};
    var response = await PostEmailLoginService(body:params).start();
    if(response is LoginResponse){
      //정상 응답이면 로그인 체크
      if(isAutoLogin){
        await AppDAO.authData.setUserToken(response.token!);
        await AppDAO.authData.setUserCreated(response.created!);
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

  Future<List<CalendarDetailResponse>> loadCalendarData() async{
    return [];
  }

  /// 일시적으로 비트 출력을 정지 / 해제
  Future pauseBinauralBeatState(bool pause) async{

  }

  Future loadParameters() async{
    await GetSleepConditionService().start().then((result){
      if(result is List<SleepConditionParameterResponse>){
        AppDAO.baseData.sleepConditionParameters = result;
      }
    });

    await GetElectroStimulationsService().start().then((result){
      if(result is List<ElectroStimulationParameterResponse>){
        AppDAO.baseData.electroStimulationParameters = result;
      }
    });

    await GetBinauralBeatsService().start().then((result){
      if(result is List<BinauralBeatParameterResponse>){
        AppDAO.baseData.binauralBeatParameters = result;
      }
    });
  }


}

