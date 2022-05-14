import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepaid/page/splash_page.dart';

Map<String, WidgetBuilder> routes() => {
      SplashPage.ROUTE: (context) => SplashPage(),
   };

Route<dynamic> onGenerateRoute(RouteSettings s) {
  WidgetBuilder? widgetBuilder;
  switch (s.name) {
    //스페셜 케이스, 데이터 파라미터 있으면 case 별도처리
    default:
      widgetBuilder = routes()[s.name!];
      break;
  }
  return MaterialPageRoute(settings: s, builder: widgetBuilder!);
}
