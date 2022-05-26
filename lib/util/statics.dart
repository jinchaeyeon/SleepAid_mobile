import 'package:flutter/material.dart';

import 'app_colors.dart';

class Statics{
  static ThemeData baseTheme = ThemeData(
    primarySwatch: Colors.cyan,
    textTheme: const TextTheme(
      headline1: TextStyle(color: AppColors.black, fontSize: 13),
      headline2: TextStyle(color: AppColors.black, fontSize: 13),
      headline3: TextStyle(color: AppColors.black, fontSize: 13),
      headline4: TextStyle(color: AppColors.black, fontSize: 13),
      headline5: TextStyle(color: AppColors.black, fontSize: 13),
      headline6: TextStyle(color: AppColors.black, fontSize: 13),
      subtitle1: TextStyle(color: AppColors.black, fontSize: 13),
      subtitle2: TextStyle(color: AppColors.black, fontSize: 13),
      bodyText1: TextStyle(color: AppColors.black, fontSize: 13),
      bodyText2: TextStyle(color: AppColors.black, fontSize: 13),
      caption: TextStyle(color: AppColors.black, fontSize: 13),
      button: TextStyle(color: AppColors.black, fontSize: 13),
      overline: TextStyle(color: AppColors.black, fontSize: 13),
    )
  );
}