import 'dart:math';
import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/src/provider.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/binarual_beat_recipe_response.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/provider/main_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/graph/beat_painter.dart';
import 'package:surround_sound/surround_sound.dart';

import '../provider/data_provider.dart';

class BinauralBeatPage extends BaseStatefulWidget {
  static const ROUTE = "/BinauralBeat";

  const BinauralBeatPage({Key? key}) : super(key: key);

  @override
  BinauralBeatState createState() => BinauralBeatState();
}

class BinauralBeatState extends State<BinauralBeatPage>
    with SingleTickerProviderStateMixin{
  /// 서버에서 가져와야 함, 레시피 목록
  List<BinauralBeatRecipeResponse> recipes = [];

  SoundController controllerLeft = SoundController();
  SoundController controllerRight = SoundController();
  List<int> cycleLeft = [];
  List<int> cycleRight = [];

  bool isDeviceConected = false;

  @override
  void initState() {
    initSoundController();
    initPage();
    Future.delayed(const Duration(milliseconds: 600),() async {
      if(context.read<MainProvider>().isPlayingBeatMode){
        await context.read<MainProvider>().playingBeatMode();
      }
    });
    super.initState();
  }

  /// 장치 연결상태 체크
  void checkDeviceStatus() {
    isDeviceConected = context.read<BluetoothProvider>().checkBluetoothConnection();
  }

  /// 초기값 설정
  void initPage() {
    Future.delayed(const Duration(milliseconds:200),(){
      checkDeviceStatus();
      var userTargetParameter = AppDAO.baseData.binauralBeatUserTargetParameter;
      recipes.add(BinauralBeatRecipeResponse(
          text:userTargetParameter.name,
          tone:userTargetParameter.toneFrequency,
          binauralBeat: userTargetParameter.beatFrequency));

      for (var _recipe in AppDAO.baseData.binauralBeatParameters) {
        if(_recipe.onDisplay){
          recipes.add(BinauralBeatRecipeResponse(text:_recipe.name,
              tone:_recipe.toneFrequency, binauralBeat: _recipe.beatFrequency));
        }
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: appBar(context, 'Binaural Beat 관리', isRound: true,),
        extendBody: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Container(
                      child:Column(
                        children: [
                          SoundWidget(
                            soundController: controllerLeft,
                          ),
                          SoundWidget(
                            soundController: controllerRight,
                          ),
                        ]
                      )
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 160,
                      alignment: Alignment.center,
                      child: Container(
                          width: double.maxFinite,
                          height: 100,
                        child: CustomPaint(
                          painter: BeatPainter(cycleLeft, cycleRight),
                        )
                      )
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(width:20),
                          !isDeviceConected?Container():InkWell(
                            onTap:() async {
                              bool isHeadsetConnected = context.read<MainProvider>().checkHeadsetEvent();
                              if(!isDeviceConected){
                                showToast("장치를 연결 해 주세요.");
                              }else if(isHeadsetConnected){
                                context.read<MainProvider>().togglePlayingBeatMode();
                              }else{
                                showToast("헤드셋을 연결해주세요.");
                              }
                            },
                            child: Container(
                              width: 90,
                              height: 35,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: Colors.black),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: !context.watch<MainProvider>().isPlayingBeatMode ? Colors.transparent:AppColors.buttonYellow,
                              ),
                              child: Center(
                                child: Text(
                                  context.watch<MainProvider>().isPlayingBeatMode?'STOP':'PLAY',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(child:SizedBox.shrink()),
                          InkWell(
                            onTap: () {
                              setState(() {
                                context.read<MainProvider>().setRightBeatMode(false);
                              });
                            },
                            child: Container(
                              width: 69,
                              height: 35,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: AppColors.buttonYellow),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: !context.watch<MainProvider>().isRightBeatMode ? AppColors.buttonYellow : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  'LEFT',
                                  style: TextStyle(
                                    color: !context.watch<MainProvider>().isRightBeatMode ? Colors.white : AppColors.buttonYellow,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              setState(() {
                                context.read<MainProvider>().setRightBeatMode(true);
                              });
                            },
                            child: Container(
                              width: 69,
                              height: 35,
                              decoration: BoxDecoration(
                                border: Border.all(width:1, color: AppColors.buttonYellow),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: context.watch<MainProvider>().isRightBeatMode ? AppColors.buttonYellow : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  'RIGHT',
                                  style: TextStyle(
                                    color: context.watch<MainProvider>().isRightBeatMode ? Colors.white : AppColors.buttonYellow,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width:20)
                        ],
                      )
                    ),
                    Expanded(
                        child: homeContent()
                    )
                  ],
                )
            )
        )
    );
  }

  PreferredSize appBar(BuildContext context, String title, {bool isRound = true}) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(140),
      child: Container(
        width: double.maxFinite,
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
          ),
          borderRadius: isRound? const BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ): BorderRadius.zero,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0, right: 0, bottom: 0, top: 50,
              child: Container(
                  width: double.maxFinite,
                  height: 50,
                  alignment: Alignment.center,
                  child: Container(
                    width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 14,
                          margin: const EdgeInsets.only(right: 2),
                          child: Image.asset(AppImages.sound, fit: BoxFit.fill),
                        ),
                        const Center(
                          child: Text(
                            '이어폰을 착용해주세요.',
                            style: TextStyle(
                              color: AppColors.mainYellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  )
              )
            ),
            Positioned(
              left: 0, right: 0, bottom: 0, top: 0,
              child: Container(
                width: 300,
                height:double.maxFinite,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 60, height: 60,child: SizedBox.shrink(),),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          height: 1.08,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          builder: (context) => SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              child: infoBottomSheet(),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.info,
                          fit: BoxFit.contain, width: 24, height: 24,

                        ),
                      ),
                    )
                  ]
                )
              ),
            ),
            Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(
                  height: 123,
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 36,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          child: Image.asset(
                            AppImages.back, color: Theme.of(context).primaryIconTheme.color,
                            fit: BoxFit.contain, width: 12, height: 21,

                          ),
                        ),
                      ),
                    ],
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget homeContent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Column(
        children: [
          buildSliderControlWidget(text:"Tone\nFrequency", index: 0, max: 400),
          const SizedBox(height: 20),
          buildSliderControlWidget(text:"Binaural Beat\nFrequency", index: 1, max: 40),
          const SizedBox(height: 20),
          Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Column(
                    children: [
                      ...getRecipeWidgets()
                    ],
                  ),
                ),
              )
          )
        ],
      ),
    );
  }

  buildSliderControlWidget({double index=0, double max=40, double step=1, String text=""}) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPurple,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width:30),
          Expanded(
              flex: 7,
              child: FlutterSlider(
                disabled: !isDeviceConected,
                values: [getSelectedFrequecyValue(context, index)],
                max: max,
                min: 0,
                handlerWidth: 0,
                handler: FlutterSliderHandler(
                  child: Container(width: 0, height: 0, color: Colors.transparent),
                ),
                jump: true,
                trackBar: FlutterSliderTrackBar(
                  activeTrackBar: BoxDecoration(gradient: sliderGradient, borderRadius: BorderRadius.circular(11)),
                  activeTrackBarHeight: 22,
                  inactiveTrackBar: BoxDecoration(color: AppColors.subButtonGrey, borderRadius: BorderRadius.circular(11)),
                  inactiveTrackBarHeight: 22,
                ),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  if(index == 0){
                    context.read<MainProvider>().setFrequencyValue(tone: lowerValue.toInt());
                  }else if(index == 1){
                    context.read<MainProvider>().setFrequencyValue(binauralBeat: lowerValue.toInt());
                  }
                },
                tooltip: FlutterSliderTooltip(
                    format: formatHz,
                    disableAnimation: true,
                    alwaysShowTooltip: true,
                    positionOffset: FlutterSliderTooltipPositionOffset(
                        top: 55
                    ),
                    textStyle: const TextStyle(
                      color: AppColors.textPurple,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    boxStyle: const FlutterSliderTooltipBox(
                      decoration: BoxDecoration(),
                    )),
              )
          )
        ],
      ),
    );
  }
  
  Widget infoBottomSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: AppDAO.isDarkMode?AppColors.colorDarkSplash:Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Binaural Beat?',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '특정 주파수의 소리를 이용하여 뇌의 뇌파를 조절하는 소리를 뜻합니다.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Binaural Beat 설정 시 확인사항',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tone frequency는 1000Hz 미만까지 설정 가능하며, 두 주파수의 값 차이는 30Hz를 초과할 수 없습니다.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }

  /// 선택한 레시피로 데이터 설정
  void updateCurrentRecipe(BinauralBeatRecipeResponse recipe) {
    context.read<MainProvider>().setFrequencyValue(
        tone: recipe.tone, binauralBeat:recipe.binauralBeat);
  }

  List<Widget> getRecipeWidgets() {
    List<Widget> list = [];

    for (var recipe in recipes) {
      Widget widget = GestureDetector(
        onTap: () {
          if(isDeviceConected){
            updateCurrentRecipe(recipe);
            setState(() {});
          }
        },
        child: Container(
          margin:EdgeInsets.only(top:10),
          width: double.maxFinite,
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 26,
          ),
          decoration: !isDeviceConected
              ?BoxDecoration(color:AppColors.borderGrey, borderRadius: BorderRadius.circular(14),)
              :BoxDecoration(
            color: isSelectedRecipe(recipe) ? Theme
                .of(context)
                .cardColor : Theme
                .of(context)
                .focusColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(width: 1.5,
                color: isSelectedRecipe(recipe) ? AppColors.mainGreen : Colors.transparent),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.text,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline6,
              ),
              SizedBox(height: 22),
              Row(
                children: [
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Text(
                          'Tone\nPrequency',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline2,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${recipe.tone.toInt()}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline1,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Text(
                          'Binaural Beat\nFrequency',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline2,
                        ),
                        SizedBox(width: 6),
                        Text(
                          '${recipe.binauralBeat.toInt()}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .headline1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                ],
              )
            ],
          ),
        ),
      );
      bool isFirstRecipe = recipes.indexOf(recipe) == 0;
      if(isFirstRecipe){
        if(isDeviceConected){
          widget = Container();
        }else{
          widget = Container(
            margin:const EdgeInsets.only(top:10),
            width: double.maxFinite,
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 26,
            ),
            decoration: BoxDecoration(
              color:AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(width: 1.5,
                  color: Colors.transparent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.text,
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline6,
                ),
                SizedBox(height: 10),
                Text(
                  "사용자 맞춤 전기 자극 설정은 실시간 생체 신호를 계산하여 인공지능을 통해 최적의 자극 레시피를 산출하는 방법으로 기기 부착 후 사용 가능한 설정입니다.",
                  style: Theme
                      .of(context)
                      .textTheme
                      .bodyText2,
                )
              ],
            ),
          );
        }
      }
      list.add(widget);
    }
    return list;
  }


  Future<void> initSoundController() async {
    context.read<MainProvider>().updateSoundControllers(controllerLeft, controllerRight);
    int index = 0;
     while(mounted){
       try{
         await Future.delayed(const Duration(milliseconds: 500), () async{
           // if(context.read<BluetoothProvider>().deviceList.isNotEmpty){
           buildSineWave(index);
           index +=10;
           if(index > 300) index = 0;
           setState(() {});
           // }
         });
       }catch (e){}
     }
  }

  buildSineWave(int index) {
    int phaseCnt = index;
    int sampleRate = 5000;
    cycleLeft = [];
    cycleRight = [];
    for(int i = 0; i < 60; i++){
      phaseCnt++;
      if (phaseCnt > sampleRate) phaseCnt = 0;
      cycleLeft.add((sin(context.read<MainProvider>().getBeatFrequecyLeftValue() * (2 * pi) * (phaseCnt) / sampleRate) * 100).toInt());
      cycleRight.add((sin(context.read<MainProvider>().getBeatFrequecyRightValue() * (2 * pi) * (phaseCnt) / sampleRate) * 100).toInt());
    }
    return;
  }

  /// 재생모드가 아니면 0
  /// 재생모드면 기본 랜덤값 출력(기본랜덤값음 앱 실행시에 초기화 1회
  /// 자극 레시피를 클릭하면 기본 선택값이 수정됨
  double getSelectedFrequecyValue(BuildContext context, double index) {
    if(context.watch<MainProvider>().isPlayingBeatMode){
      return context.watch<MainProvider>().getBeatFrequecyValue(index);
    }else{
      return 0;
    }
  }

  bool isSelectedRecipe(BinauralBeatRecipeResponse recipe) {
    if(!context.watch<MainProvider>().isPlayingBeatMode){
      return false;
    }
    if(context.watch<MainProvider>().frequencyTone == recipe.tone.toDouble() &&
        context.watch<MainProvider>().frequencyBeat == recipe.binauralBeat.toDouble()){
      return true;
    }else{
      return false;
    }
  }
}