import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepaid/page/home_page.dart';
import 'package:sleepaid/page/login_page.dart';
import 'package:sleepaid/page/menu_page.dart';
import 'package:sleepaid/page/splash_page.dart';

class Routes{
  static const splash = SplashPage.ROUTE;
  static const home = HomePage.ROUTE;
  static const login = LoginPage.ROUTE;
  static const menu = MenuPage.ROUTE;


  static Route<T> fadeThrough<T>(RouteSettings settings, WidgetBuilder page,
      {int duration = 100}) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: Duration(milliseconds: duration),
      pageBuilder: (context, animation, secondaryAnimation) => page(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(animation: animation, child: child);
      },
    );
  }

  static generateRoute(RouteSettings settings, BuildContext context) {
    return Routes.fadeThrough(settings, (context) {
      switch (settings.name) {
        case Routes.splash:
          return const SplashPage();
        case Routes.home:
          return const HomePage();
        case Routes.login:
          return const LoginPage();
        case Routes.menu:
          return const MenuPage();
        default:
          return const SplashPage();
      }
    },duration: 100);
  }
}