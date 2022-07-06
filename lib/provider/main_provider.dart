import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:headset_connection_event/headset_event.dart';
import 'package:sleepaid/data/local/app_dao.dart';
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

  startMicrophoneScan() async {
    headsetPlugin.getCurrentState.then((_val) async {
      if(headsetEvent == HeadsetState.DISCONNECT && _val == HeadsetState.CONNECT){
        playBeat();
      }else if(headsetEvent == HeadsetState.CONNECT && _val == HeadsetState.DISCONNECT){
        playBeat();
      }
      headsetEvent = _val??HeadsetState.DISCONNECT;
      notifyListeners();
      AppDAO.completeInit = true;
    });

    /// Detect the moment headset is plugged or unplugged
    headsetPlugin.setListener((_val) {
      headsetEvent = _val;
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
    if(isPlayingBeatMode){
      if(isRightBeatMode){
        await controllerLeft.setFrequency(frequencyLeft);
        await controllerRight.setFrequency(frequencyRight);
      }else{
        await controllerLeft.setFrequency(frequencyRight);
        await controllerRight.setFrequency(frequencyLeft);
      }

      print("play");
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

  Future<void> updateSoundControllers(SoundController controllerLeft, SoundController controllerRight) async {
    this.controllerLeft = controllerLeft;
    this.controllerRight = controllerRight;
    await initBeatController();
  }
}

