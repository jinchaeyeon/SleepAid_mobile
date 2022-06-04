import 'dart:ui';

import 'package:sleepaid/data/local/app_dao.dart';

class AppImages{
  static String ic_menu = "assets/images/ic_menu.png";
  static String ic_x = "assets/images/ic_x.png";

  
  static get IMAGE_BG_SPLASH => AppDAO.isDarkMode
      ?"assets/images/background_images/splash_dark.png"
      :"assets/images/background_images/splash.png";
  static get IMAGE_BG_LOGIN => AppDAO.isDarkMode
      ?"assets/images/background_images/login_dark.png"
      :"assets/images/background_images/login.png";

  // ICON
  static const String add = "assets/images/add.png";
  static const String back = "assets/images/back.png";
  static const String binauralBeat = "assets/images/binaural-beat.png";
  static const String binauralBeatGraph = "assets/images/binaural-beat-graph-transparent.png";
  static const String bioSignal = "assets/images/bio-signal.png";
  static const String bluetoothConnect = "assets/images/bluetooth-connect.png";
  static const String bluetoothDisconnect = "assets/images/bluetooth-disconnect.png";
  static const String close = "assets/images/close.png";
  static const String electricalStimulation = "assets/images/electrical-stimulation.png";
  static const String facebook = "assets/images/facebook.png";
  static const String google = "assets/images/google.png";
  static const String info = "assets/images/info.png";
  static const String menu = "assets/images/menu.png";
  static const String naver = "assets/images/naver.png";
  static const String off = "assets/images/off.png";
  static const String on = "assets/images/on.png";
  static const String play = "assets/images/play.png";
  static const String sleepAnalysis = "assets/images/sleep-analysis.png";
  static const String sound = "assets/images/sound.png";
  static const String triangle = "assets/images/triangle.png";
}