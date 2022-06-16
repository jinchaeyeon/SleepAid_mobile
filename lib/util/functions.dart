import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/src/provider.dart';
import 'package:sleepaid/provider/data_provider.dart';

import 'app_colors.dart';

Future<void> completedExit() async {
  if (Platform.isIOS) {
    exit(0);
  } else {
    await SystemNavigator.pop();
  }
}

Future<bool> checkNetworkState() async{
  ///todo 네트워크 연결 상태 체크하는 코드
  return true;
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
Widget getBaseWillScope(BuildContext context, Widget? body, {Function? onWillScope}){
  return WillPopScope(
    onWillPop: () async{
      if(context.read<DataProvider>().isLoading){
        Fluttertoast.showToast(msg:"로딩중입니다");
        return false;
      }
      if(onWillScope!=null){
        return onWillScope();
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
          )
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