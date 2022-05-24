import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';

/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';*/

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';


class Util {
  static const mainColor = Color(0xffe74e0f);
  /// log
  static Logger logger = Logger();

  static void log(String message) {
    logger.d(message);
  }
}
