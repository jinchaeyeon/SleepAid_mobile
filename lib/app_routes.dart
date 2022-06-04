import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:sleepaid/page/signup/agreement_term_page.dart';
import 'package:sleepaid/page/bluetooth_connect_page.dart';
import 'package:sleepaid/page/signup/email_signup_page.dart';
import 'package:sleepaid/page/home_page.dart';
import 'package:sleepaid/page/signup/license_key_page.dart';
import 'package:sleepaid/page/login_page.dart';
import 'package:sleepaid/page/menu_page.dart';
import 'package:sleepaid/page/splash_page.dart';

class Routes{
  static const splash = SplashPage.ROUTE;
  static const home = HomePage.ROUTE;
  static const login = LoginPage.ROUTE;
  static const menu = MenuPage.ROUTE;
  static const bluetoothConnect = BluetoothConnectPage.ROUTE;

  static const licenseKey = LicenseKeyPage.ROUTE;
  static const signupWithEmail = EmailSignUpPage.ROUTE;
  static const agreementTerm = AgreementTermPage.ROUTE;

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
        case Routes.licenseKey:
          return const LicenseKeyPage();
        case Routes.signupWithEmail:
          return const EmailSignUpPage();
        case Routes.agreementTerm:
          return const AgreementTermPage();
        case Routes.bluetoothConnect:
          return const BluetoothConnectPage();
        default:
          return const SplashPage();
      }
    },duration: 100);
  }
}