import 'dart:ui';

import 'package:sleepaid/data/local/app_dao.dart';

class AppColors{
  static const Color colorBackground = const Color(0xff050505);
  static const Color colorDarkSplash = const Color(0xff383D55);
  static const Color black = Color(0xFF000000);
  static const Color baseGreen = Color(0xFF95C3A0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF555555);
  static get COLOR_BG_SPASH => AppDAO.isDarkMode
      ? colorDarkSplash
      : white;

  static const Color mainBlue = Color(0xFF7282d4);
  static const Color mainYellow = Color(0xFFe9a951);
  static const Color subYellow = Color(0xFFf6c985);
  static const Color mainGrey = Color(0xFFefefef);
  static const Color mainGreen = Color(0xFF7eb641);
  static const Color textBlack = Color(0xFF3d3d3d);
  static const Color subTextBlack = Color(0xFF676767);
  static const Color textGrey = Color(0xFFc2c2c2);
  static const Color subTextGrey = Color(0x80000000);
  static const Color textPurple = Color(0xFF7667b5);
  static const Color subTextPurple = Color(0xA67667b5);
  static const Color textRed = Color(0xFFd10000);
  static const Color subTextRed = Color(0x4Dd10000);
  static const Color inputYellow = Color(0xFFe9a950);
  static const Color inputBlack = Color(0x80000000);
  static const Color inputInfoYellow = Color(0xFFf4bd74);
  static const Color buttonBlue = Color(0xFF799ddd);
  static const Color subButtonBlue = Color(0xFFc6d4ee);
  static const Color buttonGrey = Color(0xFFf3f3f3);
  static const Color subButtonGrey = Color(0xFFf7f7f7);
  static const Color backgroundGrey = Color(0xFFf3f3f3);
  static const Color loginTextBlue = Color(0xFFa7bce2);
  static const Color borderGrey = Color(0xFF9a9a9a);
  static const Color buttonYellow = Color(0xFFe9a950);

  // GRADIENT COLOR
  static const Color buttonStart = Color(0xFF9eb8e9);
  static const Color buttonEnd = Color(0xFF799ddd);
  static const Color tabBarStart = Color(0xFFefecee);
  static const Color tabBarEnd = Color(0xFFf4e3de);
  static const Color graphStart = Color(0xFF7667b5);
  static const Color graphMiddle = Color(0xFF7282d4);
  static const Color graphEnd = Color(0xFFf5e7f4);
  static const Color calendarStart = Color(0xFF7282d4);
  static const Color calendarEnd = Color(0xFFc6d4ee);
  static const Color graphYellowTop = Color(0xCCfff2ea);
  static const Color graphYellowMiddleTop = Color(0x99fff2ea);
  static const Color graphYellowMiddleBottom = Color(0x4Dfff2ea);
  static const Color graphYellowBottom = Color(0x33fff2ea);
  static const Color switchOffStart = Color(0xFFe3e3e3);
  static const Color switchOffMiddle = Color(0xFFe8e8e8);
  static const Color switchOffEnd = Color(0xFFf3f3f3);
}