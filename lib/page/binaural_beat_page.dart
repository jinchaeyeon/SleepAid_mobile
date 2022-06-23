import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/data/network/binarual_beat_recipe_response.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';

class BinauralBeatPage extends BaseStatefulWidget {
  static const ROUTE = "BinauralBeat";

  const BinauralBeatPage({Key? key}) : super(key: key);

  @override
  BinauralBeatState createState() => BinauralBeatState();
}

class BinauralBeatState extends State<BinauralBeatPage>
    with SingleTickerProviderStateMixin{
  /// 처음에 기기에서 가져와야함, 실시간 변경되는 메인 레시피
  BinauralBeatRecipeResponse? currentRecipe;
  /// 서버에서 가져와야 함, 레시피 목록
  List<BinauralBeatRecipeResponse> recipes = [];
  /// 선택중인 레시피 앱 실행시에는 기본값을 모르기 때문에 null, 앱 사용 중 레시피 선택하면 해당 레시피를 선택 상태로 설정
  BinauralBeatRecipeResponse? selectedRecipe;

  var isRight = true;


  @override
  void initState() {
    initPage();
    super.initState();
  }

  /// 초기값 설정
  void initPage() {
    Future.delayed(const Duration(milliseconds:100),(){
      ///테스트에서만 보이는 레시피
      if(kDebugMode){
        recipes.add(BinauralBeatRecipeResponse(text:"사용자 맞춤설정", tone:400, binauralBeat: 38));
        recipes.add(BinauralBeatRecipeResponse(text:"자극 레시피1", tone:400, binauralBeat: 37));
        recipes.add(BinauralBeatRecipeResponse(text:"자극 레시피2", tone:300, binauralBeat: 28));
        recipes.add(BinauralBeatRecipeResponse(text:"자극 레시피3", tone:300, binauralBeat: 29));
        recipes.add(BinauralBeatRecipeResponse(text:"자극 레시피4", tone:300, binauralBeat: 28));
        setState(() {});
      }
      checkDeviceStatus();
    });
  }

  void checkDeviceStatus() {}

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
                      width: double.maxFinite,
                      height: 160,
                      color: Colors.red,
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isRight = false;
                              });
                            },
                            child: Container(
                              width: 69,
                              height: 35,
                              decoration: BoxDecoration(
                                border: Border.all(width: 1, color: AppColors.buttonYellow),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: !isRight ? AppColors.buttonYellow : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  'LEFT',
                                  style: TextStyle(
                                    color: !isRight ? Colors.white : AppColors.buttonYellow,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isRight = true;
                              });
                            },
                            child: Container(
                              width: 69,
                              height: 35,
                              decoration: BoxDecoration(
                                border: Border.all(width:1, color: AppColors.buttonYellow),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                color: isRight ? AppColors.buttonYellow : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  'RIGHT',
                                  style: TextStyle(
                                    color: isRight ? Colors.white : AppColors.buttonYellow,
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
          SizedBox(width:30),
          Expanded(
              flex: 7,
              child: FlutterSlider(
                values: [getValueFromCurrentRecipe(index)],
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
                  // item.score = lowerValue;
                  // setState(() {});
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
      decoration: const BoxDecoration(
        color: Colors.white,
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

  double getValueFromCurrentRecipe(double index) {
    if(currentRecipe == null) return 0;
    if(index == 0){
      return currentRecipe?.tone??0;
    }else if(index == 1){
      return currentRecipe?.binauralBeat??0;
    }
    return 0;
  }

  void updateCurrentRecipe(BinauralBeatRecipeResponse recipe) {
    currentRecipe = recipe;
    selectedRecipe = recipe;
  }

  List<Widget> getRecipeWidgets() {
    List<Widget> list = [];

    recipes.forEach((recipe) {
      Widget widget = GestureDetector(
        onTap: () {
          updateCurrentRecipe(recipe);
          setState(() {});
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
          decoration: BoxDecoration(
            color: selectedRecipe == recipe ? Theme
                .of(context)
                .cardColor : Theme
                .of(context)
                .focusColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(width: 1.5,
                color: selectedRecipe == recipe ? AppColors.mainGreen : Colors.transparent),
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

      list.add(widget);
    });
    return list;
  }
}