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

  static Color mainBlue = Color(0xFF7282d4);
  static Color mainYellow = Color(0xFFe9a951);
  static Color subYellow = Color(0xFFf6c985);
  static Color mainGrey = Color(0xFFefefef);
  static Color mainGreen = Color(0xFF7eb641);
  static Color textBlack = Color(0xFF3d3d3d);
  static Color subTextBlack = Color(0xFF676767);
  static Color textGrey = Color(0xFFc2c2c2);
  static Color subTextGrey = Color(0x80000000);
  static Color textPurple = Color(0xFF7667b5);
  static Color subTextPurple = Color(0xA67667b5);
  static Color textRed = Color(0xFFd10000);
  static Color subTextRed = Color(0x4Dd10000);
  static Color inputYellow = Color(0xFFe9a950);
  static Color inputBlack = Color(0x80000000);
  static Color inputInfoYellow = Color(0xFFf4bd74);
  static Color buttonBlue = Color(0xFF799ddd);
  static Color subButtonBlue = Color(0xFFc6d4ee);
  static Color buttonGrey = Color(0xFFf3f3f3);
  static Color subButtonGrey = Color(0xFFf7f7f7);
  static Color backgroundGrey = Color(0xFFf3f3f3);
  static Color loginTextBlue = Color(0xFFa7bce2);
  static Color borderGrey = Color(0xFF9a9a9a);
  static Color buttonYellow = Color(0xFFe9a950);

  // GRADIENT COLOR
  static Color buttonStart = Color(0xFF9eb8e9);
  static Color buttonEnd = Color(0xFF799ddd);
  static Color tabBarStart = Color(0xFFefecee);
  static Color tabBarEnd = Color(0xFFf4e3de);
  static Color graphStart = Color(0xFF7667b5);
  static Color graphMiddle = Color(0xFF7282d4);
  static Color graphEnd = Color(0xFFf5e7f4);
  static Color calendarStart = Color(0xFF7282d4);
  static Color calendarEnd = Color(0xFFc6d4ee);
  static Color graphYellowTop = Color(0xCCfff2ea);
  static Color graphYellowMiddleTop = Color(0x99fff2ea);
  static Color graphYellowMiddleBottom = Color(0x4Dfff2ea);
  static Color graphYellowBottom = Color(0x33fff2ea);
  static Color switchOffStart = Color(0xFFe3e3e3);
  static Color switchOffMiddle = Color(0xFFe8e8e8);
  static Color switchOffEnd = Color(0xFFf3f3f3);
}