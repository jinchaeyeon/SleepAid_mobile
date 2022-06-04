import 'package:flutter/painting.dart';

import 'app_colors.dart';

class AppStyles{
  static TextStyle textStyle({
    size = AppDimens.textSizeDefault,
    color = AppColors.black,
    weight = FontWeight.normal
  }) => TextStyle(fontSize: size, color: color, fontWeight: weight);
}

class AppDimens{
  static const double textSizeLogo = 30;
  static const double textSizeDefault = 12;
}