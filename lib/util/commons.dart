import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sleepaid/util/app_colors.dart';

import '../app_routes.dart';

class NoBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

void fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}

void fieldChangeUnFocus(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  width: double.maxFinite- 72,
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 150,
                          alignment: const Alignment(0, 0),
                          child: Center(
                            child: Text(
                              "정말 종료하시겠습니까?",
                              style: TextStyle(
                                  color: AppColors.textBlack,
                                  fontSize: 14,
                                // fontFamily: Util.notoSans,
                                  fontWeight: FontWeight.w600,),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.buttonGrey,
                                  borderRadius: const BorderRadius.only(
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
                                        // fontFamily: Util.notoSans,
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
                                decoration: BoxDecoration(
                                  color: AppColors.mainBlue,
                                  borderRadius: const BorderRadius.only(
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
                                      // fontFamily: Util.notoSans,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (Platform.isAndroid) {
                                      SystemNavigator.pop();
                                    }
                                  },
                                ),
                              ),
                              flex: 1,
                            ),
                          ],
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

/// 미사용, UI만 구현
Future<bool> showLogoutDialog(BuildContext context) async {
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
                  width: 320,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: 150,
                          alignment: const Alignment(0, 0),
                          child: Text(
                            "정말 로그아웃 하시겠습니까?",
                            style: TextStyle(
                                color: AppColors.textBlack, fontSize: 14, fontWeight: FontWeight.w600,
                                // fontFamily: Util.notoSans
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.buttonGrey,
                                  borderRadius: const BorderRadius.only(
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
                                      // fontFamily: Util.notoSans,
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
                                decoration: BoxDecoration(
                                  color: AppColors.mainBlue,
                                  borderRadius: const BorderRadius.only(
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
                                        // fontFamily: Util.notoSans,
                                      ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pushReplacementNamed(context, Routes.loginList);
                                  },
                                ),
                              ),
                              flex: 1,
                            ),
                          ],
                        )
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
