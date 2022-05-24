import 'package:flutter/painting.dart';

import 'app_colors.dart';

class AppStyles{
  static TextStyle textStyle({
    size = AppDimens.textSizeDefault,
    color = AppColors.black,
  }) => TextStyle(fontSize: size, color: color);
}

class AppDimens{
  static const double textSizeLogo = 20;
  static const double textSizeDefault = 12;
}