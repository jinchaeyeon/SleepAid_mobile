import 'package:flutter/material.dart';

class AppThemes{
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColorBrightness: Brightness.light,
    primaryColor:Colors.white,
    primarySwatch: createMaterialColor(Colors.white),
    primaryColorLight:Colors.white,
    primaryTextTheme: const TextTheme(
      headline6: TextStyle(
        color: Color(0xFF0000000),
        fontSize: 20,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w700,
      ),
    ),
    primaryIconTheme: const IconThemeData(
      color: Color(0xFF0000000),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.yellow,
      // backgroundColor:const Colors.grey,
    ),
    textTheme: const TextTheme(
      bodyText1: TextStyle(
        color: Color(0xFF676767),
        fontSize: 14,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w400,
      ),
      bodyText2: TextStyle(
        color: Color(0xFF3d3d3d),
        fontSize: 11,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w400,
      ),
      headline1: TextStyle(
        color: Color(0xFF000000),
        fontSize: 20,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w700,
      ),
      headline2: TextStyle(
        color: Color(0x80000000),
        fontSize: 14,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w500,
      ),
      headline3: TextStyle(
        color: Color(0xFF000000),
        fontSize: 12,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w500,
      ),
      headline4: TextStyle(
        color: Colors.white,
        fontSize: 14,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w500,
      ),
      headline5: TextStyle(
        color: Colors.white,
        fontSize: 14,
        // fontFamily: Util.roboto,
        fontWeight: FontWeight.w500,
      ),
      headline6: TextStyle(
        color: Color(0xFF000000),
        fontSize: 14,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(
        color: Color(0xFF676767),
        fontSize: 18,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w400,
      ),
      subtitle2: TextStyle(
        color: Color(0xFF000000),
        fontSize: 18,
        // fontFamily: Util.roboto,
        fontWeight: FontWeight.w400,
      ),
      button: TextStyle(
        color: Colors.white,
        fontSize: 10,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w500,
      ),
      caption: TextStyle(
        color: Color(0xFF000000),
        fontSize: 16,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w700,
      ),
      overline: TextStyle(
        color: Color(0x80000000),
        fontSize: 12,
        // fontFamily: Util.appleGothic,
        fontWeight: FontWeight.w500,
      ),
    ),
    colorScheme:const ColorScheme.light(
      primary:Color(0xFFefecee),
      secondary:Color(0xFFf4e3de),
      primaryVariant:Color(0xFFefecee),
      secondaryVariant:Color(0xFFf4e3de),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor:Colors.white,
    cardColor:const Color(0xFFffffff).withOpacity(0.85),
    focusColor:const Color(0xFFf3f3f3).withOpacity(0.66),
    highlightColor:const Color(0xFFa7bce2),
    hintColor:const Color(0xFF3d3d3d),
    dividerColor:const Color(0x80000000),
    // textSelectionColor:const Color(0xFF0000000),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor:Color(0xFF0000000),
    ),
    toggleableActiveColor:Colors.transparent,
    disabledColor:const Color(0xFFefefef),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColorBrightness: Brightness.dark,
    primaryColor:const Color(0xFF262a42),
    primarySwatch: createMaterialColor(const Color(0xFF262a42)),
    primaryColorDark:const Color(0xFF262a42),
    primaryTextTheme: const TextTheme(
      headline6: TextStyle(
        color: Color(0xFFffffff),
        fontSize: 20,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w700,
      ),
    ),
    primaryIconTheme: const IconThemeData(
      color: Color(0xFFffffff),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.red,
      // backgroundColor:const Colors.grey,
    ),
    textTheme: const TextTheme(
      bodyText1: TextStyle(
        color: Color(0xFFe8e8e8),
        fontSize: 14,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w400,
      ),
      bodyText2: TextStyle(
        color: Color(0xFFf1f1f1),
        fontSize: 11,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w400,
      ),
      headline1: TextStyle(
        color: Color(0xFFf1f1f1),
        fontSize: 20,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w700,
      ),
      headline2: TextStyle(
        color: Color(0xFFc2c2c2),
        fontSize: 14,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w500,
      ),
      headline3: TextStyle(
        color: Colors.white,
        fontSize: 12,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w500,
      ),
      headline4: TextStyle(
        color: Color(0xFF3c3f55),
        fontSize: 14,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w500,
      ),
      headline5: TextStyle(
        color:Color(0xFF3c3f55),
        fontSize: 14,
        // fontFamily: Util.roboto,
        fontWeight: FontWeight.w500,
      ),
      headline6: TextStyle(
        color:Color(0xFFf1f1f1),
        fontSize: 14,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.bold,
      ),
      subtitle1: TextStyle(
        color:Color(0xFFf1f1f1),
        fontSize: 18,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w400,
      ),
      subtitle2: TextStyle(
        color:Color(0xFFf1f1f1),
        fontSize: 18,
        // fontFamily: Util.roboto,
        fontWeight: FontWeight.w400,
      ),
      button: TextStyle(
        color:Color(0xFF3c3f55),
        fontSize: 10,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w500,
      ),
      caption: TextStyle(
        color:Color(0xFFffffff),
        fontSize: 16,
        // fontFamily: Util.notoSans,
        fontWeight: FontWeight.w700,
      ),
      overline: TextStyle(
        color:Color(0x80f1f1f1),
        fontSize: 12,
        // fontFamily: Util.appleGothic,
        fontWeight: FontWeight.w500,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary:Color(0xFF4b4e68),
      secondary:Color(0xFF3c3f55),
      primaryVariant:Color(0xFF262a42),
      secondaryVariant:Color(0xFF262a42),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor:const Color(0xFF262a42),
    cardColor:const Color(0xFF4b4e68),
    focusColor:const Color(0xFF3c3f55).withOpacity(0.66),
    highlightColor:const Color(0xFFa5afda),
    hintColor:const Color(0xFFf1f1f1),
    dividerColor:const Color(0xFFf1f1f1),
    // textSelectionColor:const Color(0xFFffffff),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor:Color(0xFFffffff),
    ),
    toggleableActiveColor:const Color(0xFFd6d6d6),
    disabledColor:const Color(0xFF4b4e68),
  );

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int,Color> swatch = <int,Color>{};
    final int r =color.red, g =color.green, b =color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] =Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}