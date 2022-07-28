import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/network/sleeping_analytics_service.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:surround_sound/surround_sound.dart';

class MainProvider with ChangeNotifier{
  // Instantiate it
  HeadsetEvent headsetPlugin = HeadsetEvent();
  HeadsetState headsetEvent = HeadsetState.DISCONNECT;
  double frequencyLeft = 400;
  double frequencyRight = 360;
  bool isPlayingBeatMode = false;
  bool isRightBeatMode = true;

  SoundController controllerLeft = SoundController();
  SoundController controllerRight = SoundController();

  /// 헤드셋 연결 상태 확인
  bool checkHeadsetEvent() {
    if(headsetEvent == HeadsetState.CONNECT){
      return true;
    }
    return false;
  }

  startMicrophoneScan() async {
    print("startHeadsetScan");
    headsetPlugin.getCurrentState.then((_val) async {
      if(headsetEvent == HeadsetState.DISCONNECT && _val == HeadsetState.CONNECT){
        playBeat();
      }else if(headsetEvent == HeadsetState.CONNECT && _val == HeadsetState.DISCONNECT){
        isPlayingBeatMode = false;
        playBeat();
      }
      headsetEvent = _val??HeadsetState.DISCONNECT;
      notifyListeners();
      AppDAO.completeInit = true;
    });

    /// Detect the moment headset is plugged or unplugged
    headsetPlugin.setListener((_val) {
      if(headsetEvent == HeadsetState.CONNECT && _val == HeadsetState.DISCONNECT){
        showToast("헤드폰 연결이 해제되었습니다.");
      }else if(headsetEvent == HeadsetState.DISCONNECT && _val == HeadsetState.CONNECT){
        showToast("헤드폰이 연결 되었습니다.");
      }
      headsetEvent = _val;
      playBeat();
      notifyListeners();
    });
  }


  initBeatController() async{
    await controllerLeft.setVolume(1);
    await Future.delayed(const Duration(milliseconds: 100));
    await controllerRight.setVolume(1);
    await Future.delayed(const Duration(milliseconds: 100));
    await controllerLeft.setFrequency(frequencyLeft);
    await Future.delayed(const Duration(milliseconds: 100));
    await controllerRight.setFrequency(frequencyRight);
    await Future.delayed(const Duration(milliseconds: 100));
    await controllerLeft.setPosition(0.097, 0.0, 0.0);
    await Future.delayed(const Duration(milliseconds: 100));
    await controllerRight.setPosition(-0.097, 0.0, 0.0);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> playBeat() async{
    if(isPlayingBeatMode && checkHeadsetEvent()){
      if(isRightBeatMode){
        await controllerLeft.setFrequency(frequencyLeft);
        await controllerRight.setFrequency(frequencyRight);
      }else{
        await controllerLeft.setFrequency(frequencyRight);
        await controllerRight.setFrequency(frequencyLeft);
      }
      print("play left: ${controllerLeft.value.freq} ${controllerLeft.value.volume} ${controllerLeft.value.x} ${controllerLeft.value.y}");
      print("play right: ${controllerRight.value.freq} ${controllerRight.value.volume} ${controllerRight.value.x} ${controllerRight.value.y}");
      controllerRight.play();
      controllerLeft.play();
    }else{
      print("stop");
      controllerRight.stop();
      controllerLeft.stop();
    }
    final valR = await controllerLeft.isPlaying();
    final valL = await controllerRight.isPlaying();
    print('isPlaying: R: $valR , L: $valL');
    notifyListeners();
  }

  Future<void> setRightBeatMode(bool isRight) async {
    isRightBeatMode = isRight;
    playBeat();
    notifyListeners();
  }

  Future<void> togglePlayingBeatMode(SoundController left, SoundController right) async {
    isPlayingBeatMode = !isPlayingBeatMode;
    controllerLeft = left;
    controllerRight = right;
    playBeat();
    notifyListeners();
  }

  Future<void> updateSoundControllers(SoundController _controllerLeft, SoundController _controllerRight) async {
    controllerLeft = _controllerLeft;
    controllerRight = _controllerRight;
    // await initBeatController();
    playBeat();
    notifyListeners();
  }

  void getSleepAnalysisList(DateTime created) {
    // List<>
    DateTime yesterday = DateTime.now().subtract(Duration(days: 1));
    GetSleepConditionsService().start().then((result){
      if(result is List<SleepAnalysisResponse>){
        print("result:$result}");
      }
    });
  }
}

