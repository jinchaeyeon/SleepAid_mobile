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
  double frequencyTone = 400;
  double frequencyBeat = 40;
  bool isPlayingBeatMode = false;
  bool isRightBeatMode = true;

  double getBeatFrequecyValue(index){
    if(index == 0){
      return frequencyTone;
    }else{
      return frequencyBeat;
    }
  }

  double getBeatFrequecyLeftValue(){
    if(isRightBeatMode){
      return frequencyTone;
    }else{
      return frequencyTone - frequencyBeat;
    }
  }

  double getBeatFrequecyRightValue(){
    if(isRightBeatMode){
      return frequencyTone - frequencyBeat;
    }else{
      return frequencyTone;
    }
  }

  Future<void> setFrequencyValue({int? tone, int? binauralBeat}) async {
    if(tone != null){
      frequencyTone = tone.toDouble();
    }
    if(binauralBeat != null){
      frequencyBeat = binauralBeat.toDouble();
    }
    await playBeat();
    await playBeat();
    notifyListeners();
  }

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
    await controllerLeft.setFrequency(getBeatFrequecyLeftValue());
    await Future.delayed(const Duration(milliseconds: 100));
    await controllerRight.setFrequency(getBeatFrequecyRightValue());
    await Future.delayed(const Duration(milliseconds: 100));
    await controllerLeft.setPosition(0.097, 0.0, 0.0);
    await Future.delayed(const Duration(milliseconds: 100));
    await controllerRight.setPosition(-0.097, 0.0, 0.0);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> playBeat() async{
    if(isPlayingBeatMode && checkHeadsetEvent()){
      await controllerLeft.setFrequency(getBeatFrequecyLeftValue());
      await controllerRight.setFrequency(getBeatFrequecyRightValue());
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

  Future<void> togglePlayingBeatMode({SoundController? left, SoundController? right}) async {
    isPlayingBeatMode = !isPlayingBeatMode;
    if(left != null){
      controllerLeft = left;
    }
    if(right != null){
      controllerRight = right;
    }
    playBeat();
    notifyListeners();
  }

  Future<void> playingBeatMode({SoundController? left, SoundController? right}) async{
    isPlayingBeatMode = true;
    if(left != null){
      controllerLeft = left;
    }
    if(right != null){
      controllerRight = right;
    }
    playBeat();
    notifyListeners();
  }

  Future<void> stopBeatMode() async{
    isPlayingBeatMode = false;
    playBeat();
  }

  Future<void> updateSoundControllers(SoundController _controllerLeft, SoundController _controllerRight) async {
    controllerLeft = _controllerLeft;
    controllerRight = _controllerRight;
    await initBeatController();
    notifyListeners();
    playBeat();
    notifyListeners();
  }
}

