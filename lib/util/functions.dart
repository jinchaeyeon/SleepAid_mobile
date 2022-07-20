import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/src/provider.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/page/realtime_signal_page.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/provider/data_provider.dart';
import '../app_routes.dart';
import 'app_colors.dart';
import 'dart:math';
import 'dart:developer' as developer;

dPrint(text){
  if(AppDAO.debugData.showDebugPrint){
    // developer.log(text);
    print(text);
  }
}

Future<void> completedExit(BuildContext? context) async {
  try{
    if(context!=null){
      await context.read<BluetoothProvider>().destroyClient();
    }
  }catch(e){

  }

  if (Platform.isIOS) {
    exit(0);
  } else {
    await SystemNavigator.pop();
  }
}

Future<bool> showExitDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (context) => GestureDetector(
      onTap: () {
        Navigator.pop(context, false);
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin:const EdgeInsets.only(left:20, right:20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
              ),
              width: double.maxFinite,
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 150,
                      child: Center(
                        child: Text(
                          "정말 종료하시겠습니까?",
                          style: TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.buttonGrey,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(15),
                                ),
                              ),
                              child: TextButton(
                                child: Text(
                                  "취소",
                                  style: TextStyle(
                                    color: AppColors.textBlack,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                              ),
                            ),
                            flex: 1,
                          ),
                          Expanded(
                            child: Container(
                              height: 56,
                              decoration: const BoxDecoration(
                                color: AppColors.mainBlue,
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: TextButton(
                                child: const Text(
                                  "확인",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onPressed: () async {
                                  completedExit(context);
                                },
                              ),
                            ),
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ) ??
      false;
}

/// 네트워크 연결 상태 체크하는 코드
Future<bool> checkNetworkState() async{
  bool result = await InternetConnectionChecker().hasConnection;
  if(result == true) {
    return true;
  } else {
    return false;
  }
}

showToast(String msg){
  Fluttertoast.showToast(msg: msg, gravity: ToastGravity.BOTTOM);
}

// int bytesToInteger(List<int> bytes) {
//   //byte to Uint8 변환
//   var value = 0;
//   for (var i = 0, length = bytes.length; i < length; i++) {
//     value += (bytes[i] * pow(256, i)).toInt();
//   }
//   return value;
// }


/// 2자리수 센서값은 2개로 3자리수 센서값은 3개로 처리해서 리턴
int bytesToInteger(List<int> byteArray) {
  // Python 에서는 temp +="{},".format(int.from_bytes(ba[pos:pos+3],'big',signed=True)); //big 형식으로 처리
  // 해당
  // int 3자리 ex  7f ff ff -> 0111 1111  1111 1111  1111 1111    0으로 시작 하는 + 값
  // int 2자리 ex  fd c5    -> 1111 1101  1100 0101               1로 시작하기 때문에 0000 0010 0011 1010 + 1 값인 -571  - 값
  int value = 0;
  if(byteArray.length == 3){
    value += byteArray[0] << 16;
    value += byteArray[1] << 8;
    value += byteArray[2];
    value = value.toSigned(24);
  }else if(byteArray.length == 2){
    value += byteArray[0] << 8;
    value += byteArray[1];
    value = value.toSigned(16);
  }
 return value;
}

const String validEmail = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
bool checkEmailPattern(String email) {
  RegExp validEmailStr = RegExp(validEmail);
  if (email.trim().isEmpty || !validEmailStr.hasMatch(email)) {
    return false;
  } else if (email.isEmpty) {
    return false;
  }
  return true;
}

void fieldFocusChange(BuildContext context, FocusNode? currentFocus, FocusNode? nextFocus) {
  currentFocus?.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

showSimpleAlertDialog(BuildContext context, String text) {
  // set up the button
  Widget okButton = TextButton(
    child: Text("확인", style: Theme.of(context).textTheme.headline3,),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text(text),
    actions: [
      okButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

/// 로딩, 로딩중 뒤로가기 처리
Widget getBaseWillScope(BuildContext context, Widget? body, {Function? onWillScope, String? routes}){
  return WillPopScope(
    onWillPop: () async{
      if(context.read<DataProvider>().isLoading){
        Fluttertoast.showToast(msg:"로딩중입니다");
        return false;
      }
      if(onWillScope!=null){
        await onWillScope();
        return true;
      }
      Navigator.pop(context);
      return true;
    },
    child: Stack(
        children: [
          if(body != null)Positioned(
            left: 0, right: 0, top: 0, bottom: 0,
            child: body,
          ),
          if(context.watch<DataProvider>().isLoading)Positioned(
            left: 0, right: 0, top: 0, bottom: 0,
            child: getLoading(context),
          ),
        ]
    )
  );
}

Widget getLoading(BuildContext context) {
  return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: AppColors.backgroundGrey.withOpacity(0.5),
      child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.borderGrey,
          )
      )
  );
}