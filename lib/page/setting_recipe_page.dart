import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/data/network/recipe_response.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/yellow_button.dart';
import 'package:provider/provider.dart';


class SettingRecipePage extends BaseStatefulWidget {
  static const ROUTE = "SettingRecipe";

  const SettingRecipePage({Key? key}) : super(key: key);

  @override
  SettingRecipeState createState() => SettingRecipeState();
}

class SettingRecipeState extends State<SettingRecipePage>
    with SingleTickerProviderStateMixin{
  /// 처음에 기기에서 가져와야함, 실시간 변경되는 메인 레시피
  RecipeResponse? currentRecipe;
  /// 서버에서 가져와야 함, 레시피 목록
  List<RecipeResponse> recipes = [];
  /// 선택중인 레시피 앱 실행시에는 기본값을 모르기 때문에 null, 앱 사용 중 레시피 선택하면 해당 레시피를 선택 상태로 설정
  RecipeResponse? selectedRecipe;

  @override
  void initState() {
    initPage();
    super.initState();

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: appBar(context, '전기 자극 상태', isRound: false,),
        extendBody: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: <Color>[Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                          ),
                        ),
                        width: double.maxFinite,
                        height: 50,
                        child: Row(
                            children:[
                              Expanded(
                                  child: InkWell(
                                      onTap: (){

                                      },
                                      child: Container(
                                          width: double.maxFinite,
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: Text("목", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBlack))
                                      ))),
                              Expanded(
                                  child: InkWell(
                                      onTap: (){

                                      },
                                      child: Container(
                                          width: double.maxFinite,
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: Text("이마", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textBlack))
                                      ))),
                            ]
                        )
                    ),
                    Container(
                        width: double.maxFinite,
                        height: 3,
                        child: Row(
                            children:[
                              Expanded(
                                  child: InkWell(
                                      onTap: (){

                                      },
                                      child: Container(
                                          width: double.maxFinite,
                                          height: 3,
                                          color: AppColors.borderGrey,
                                          alignment: Alignment.center,
                                          child: SizedBox.shrink()
                                      ))),
                              Expanded(
                                  child: InkWell(
                                      onTap: (){

                                      },
                                      child: Container(
                                          width: double.maxFinite,
                                          height: 3,
                                          color: Theme.of(context).colorScheme.secondary,
                                          alignment: Alignment.center,
                                          child: SizedBox.shrink()
                                      ))),
                            ]
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
              left: 0, right: 0, bottom: 0, top: 0,
              child: Container(
                width: 300,
                height:double.maxFinite,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                'PPG (Photoplethysmograp)',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '말초 혈류량 변화에 따른 조직에서의 광흡수도 변화를 측정. 심장 박동 주기에 따라 혈류량이 변하며, 이로 인해 신호의 크기가 변하게 됨',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'HRV (Heart rate variability)',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '심박 변이도',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Actigraphy',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'monitoring human rest/activity cycles',
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

  Widget parameterBottomSheet() {
    return Container(
      padding: EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Column(
            children: [
              Text(
                '파라미터 선택',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 14),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      YellowButton(buttonText: 'NNI'),
                      const SizedBox(width: 20),
                      YellowButton(buttonText: 'NN50'),
                      const SizedBox(width: 20),
                      YellowButton(buttonText: 'LF/HF'),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      YellowButton(buttonText: 'parameter1'),
                      const SizedBox(width: 20),
                      YellowButton(buttonText: 'parameter2'),
                      const SizedBox(width: 20),
                      YellowButton(buttonText: 'parameter3'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 80,
                        color: AppColors.buttonGrey,
                        child: Center(
                          child: Text(
                            '취소',
                            style: TextStyle(
                              color: AppColors.textBlack,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: 80,
                        color: AppColors.buttonBlue,
                        child: const Center(
                          child: Text(
                            '적용',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget homeContent() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        children: [
          buildSliderControlWidget(text:"자극\n간격", index: 0),
          SizedBox(height: 20),
      buildSliderControlWidget(text:"자극\n세기", index: 1),
          SizedBox(height: 20),
        buildSliderControlWidget(text:"자극\n높이", index: 2),
          SizedBox(height: 20),
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

  buildSliderControlWidget({double index=0, double max=10, double step=1, String text=""}) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Expanded(flex: 7,
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
                    format: format,
                    disableAnimation: true,
                    alwaysShowTooltip: true,
                    positionOffset: FlutterSliderTooltipPositionOffset(
                        top: 60
                    ),
                    textStyle: const TextStyle(
                      color: AppColors.textPurple,
                      fontSize: 13,
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

  /// 초기값 설정
  void initPage() {
    Future.delayed(const Duration(milliseconds:100),(){
      ///테스트에서만 보이는 레시피
      if(kDebugMode){
        recipes.add(RecipeResponse(text:"TEST RECIPE 1", interval: 1, intensity: 9, elevation: 6));
        recipes.add(RecipeResponse(text:"TEST RECIPE 2", interval: 4, intensity: 3, elevation: 5));
        recipes.add(RecipeResponse(text:"TEST RECIPE 3", interval: 5, intensity: 4, elevation: 6));
        recipes.add(RecipeResponse(text:"TEST RECIPE 4", interval: 6, intensity: 3, elevation: 3));
        recipes.add(RecipeResponse(text:"TEST RECIPE 5", interval: 5, intensity: 1, elevation: 1));
        setState(() {});
      }
      checkDeviceStatus();
    });
  }

  /// 현재 연결된 기기 상태 체크
  /// 목일때에는 목기기, 이마일때는 이마 기기 체크
  void checkDeviceStatus() {
    // context.read<BluetoothProvider>().connectedDeviceForNeck
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
                        '자극\n간격',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline2,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${recipe.interval.toInt()}',
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
                        '자극\n세기',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline2,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${recipe.intensity.toInt()}',
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
                        '자극\n높이',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline2,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '${recipe.elevation.toInt()}',
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

  void updateCurrentRecipe(RecipeResponse recipe) {
    currentRecipe = recipe;
    selectedRecipe = recipe;
  }

  double getValueFromCurrentRecipe(double index) {
    if(currentRecipe == null) return 0;
    if(index == 0){
      return currentRecipe!.interval;
    }else if(index == 1){
      return currentRecipe!.intensity;
    }else if(index == 2){
      return currentRecipe!.elevation;
    }
    return 0;
  }
}