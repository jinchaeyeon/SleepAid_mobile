import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/src/provider.dart';
import 'package:sleepaid/page/binaural_beat_page.dart';
import 'package:sleepaid/page/calendar_detail_page.dart';
import 'package:sleepaid/page/calendar_page.dart';
import 'package:sleepaid/page/condition_review_page.dart';
import 'package:sleepaid/page/email_login_page.dart';
import 'package:sleepaid/page/realtime_signal_page.dart';
import 'package:sleepaid/page/electric_stimulation_page.dart';
import 'package:sleepaid/page/signup/agreement_term_page.dart';
import 'package:sleepaid/page/bluetooth_connect_page.dart';
import 'package:sleepaid/page/signup/change_password_page.dart';
import 'package:sleepaid/page/signup/email_signup_page.dart';
import 'package:sleepaid/page/home_page.dart';
import 'package:sleepaid/page/signup/find_password_page.dart';
import 'package:sleepaid/page/signup/license_key_page.dart';
import 'package:sleepaid/page/login_list_page.dart';
import 'package:sleepaid/page/menu_page.dart';
import 'package:sleepaid/page/splash_page.dart';
import 'package:sleepaid/provider/data_provider.dart';

class Routes{
  static const splash = SplashPage.ROUTE;
  static const home = HomePage.ROUTE;
  static const loginList = LoginListPage.ROUTE;
  static const emailLogin = EmailLoginPage.ROUTE;
  static const findPassword = FindPasswordPage.ROUTE;
  static const changePassword = ChangePasswordPage.ROUTE;
  static const menu = MenuPage.ROUTE;
  static const bluetoothConnect = BluetoothConnectPage.ROUTE;
  static const conditionReview = ConditionReviewPage.ROUTE;
  static const bodySignal = RealtimeSignalPage.ROUTE;
  static const settingRecipe = ElectricStimulationPage.ROUTE;
  static const binauralBeat = BinauralBeatPage.ROUTE;
  static const licenseKey = LicenseKeyPage.ROUTE;
  static const signupWithEmail = EmailSignUpPage.ROUTE;
  static const agreementTerm = AgreementTermPage.ROUTE;
  static const calendar = CalendarPage.ROUTE;
  static const calendarDetail = CalendarDetailPage.ROUTE;

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
        case Routes.loginList:
          return const LoginListPage();
        case Routes.emailLogin:
          return const EmailLoginPage();
        case Routes.findPassword:
          return const FindPasswordPage();
        case Routes.changePassword:
          return const ChangePasswordPage();
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
        case Routes.conditionReview:
          return const ConditionReviewPage();
        case Routes.bodySignal:
          return const RealtimeSignalPage();
        case Routes.binauralBeat:
          return const BinauralBeatPage();
        case Routes.settingRecipe:
          return const ElectricStimulationPage();
        case Routes.calendar:
          return const CalendarPage();
        case Routes.calendarDetail:
          return const CalendarDetailPage();
        default:
          return const SplashPage();
      }
    },duration: 100);
  }
}