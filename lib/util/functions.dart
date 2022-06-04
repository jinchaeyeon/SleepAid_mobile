import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Future<bool> checkNetworkState() async{
  ///todo 네트워크 연결 상태 체크하는 코드
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