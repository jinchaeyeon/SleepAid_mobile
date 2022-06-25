import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:surround_sound/surround_sound.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surround Sound Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controllerLeft = SoundController();
  final _controllerRight = SoundController();

  @override
  Widget build(BuildContext context) {
    checkTestCode();
    return Scaffold(
      appBar: AppBar(
        title: Text("Surround Sound Example"),
      ),
      body: Container()
    );
  }

  void checkTestCode() {
    //33 * 5 160(0A)
    List<List<int>> responseLists = [
      [ 160, 33, 105, 66, 115, 127, 255, 255, 0, 14, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 35, 0, 0, 255, 255, 3, 231, 192],
      [ 160, 34, 105, 66, 128, 127, 255, 255, 0, 14, 74, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 35, 0, 0, 0, 0, 3, 232, 192],
      [ 160, 35, 105, 66, 153, 127, 255, 255, 0, 14, 86, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 35, 0, 0, 0, 0, 3, 232, 192],
      [ 160, 36, 105, 66, 165, 127, 255, 255, 0, 14, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 35, 0, 0, 0, 0, 3, 232, 192],
      [ 160, 37, 105, 66, 167, 127, 255, 255, 0, 14, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 35, 0, 0, 0, 0, 3, 232, 192],
    ];
    for (List list in responseLists){
      log("------------------");
      for (int index in list){
        log("index: ${index.toRadixString(16).padLeft(2, '0')}");
      }
    }
    List<int> responseList =
    [
      ...responseLists[0],
      ...responseLists[1],
      ...responseLists[2],
      ...responseLists[3],
      ...responseLists[4],
    ];

    Uint8List message = Uint8List.fromList(responseList);
    print("message: ${message}");
    String brainSignal = "";
    for (int i = 0; i < 8; i++) {
      int pos = 2 + i * 3;
      Uint8List list = message.sublist(pos, pos + 3);
      int value = (bytesToInteger(list) / 1000).round();
      log("--brainSignal[$i]==:list:[$list]");
      log("--brainSignal[$i]==:value:[$value]");
      brainSignal = brainSignal + value.toString() + ", ";

    }
    log("brainSignal==:"+brainSignal);

    //ppg 신호 가져오기
    List<String> brainSignalPPGList = brainSignal.split(",");
  }
}