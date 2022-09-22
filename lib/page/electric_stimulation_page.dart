import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/data/ble_device.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/electro_stimulation_parameter_response.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/yellow_button.dart';
import 'package:provider/provider.dart';

import '../provider/main_provider.dart';


class ElectricStimulationPage extends BaseStatefulWidget {
  static const ROUTE = "/SettingRecipe";

  const ElectricStimulationPage({Key? key}) : super(key: key);

  @override
  SettingRecipeState createState() => SettingRecipeState();
}

class SettingRecipeState extends State<ElectricStimulationPage>
    with SingleTickerProviderStateMixin{
  bool isNeckMode = true;
  bool isControllable = false;

  /// 기본값 없음. 기기와 연결되면 1회 가져와서 입력(initState, 기기연결시에 1회)
  /// 선택중인 레시피 앱 실행시에는 기본값을 모르기 때문에 null, 앱 사용 중 레시피 선택하면 해당 레시피를 선택 상태로 설정
  ElectroStimulationParameterResponse? selectedRecipe;
  /// todo 처음에 서버에서 가져와야함, 우선은 서버에서 랜덤값으로 가져옴 서버 개발 전에는 임의값으로 선언해둠
  ElectroStimulationParameterResponse? recommedRecipe = ElectroStimulationParameterResponse(id:0,onDisplay:true,name:"사용자 맞춤설정",interval:9,intensity:8, height:7);
  /// 서버에서 가져와야 함, 레시피 목록
  List<ElectroStimulationParameterResponse> recipes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    buildPage();

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
                                        setNeckMode(true);
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
                                        setNeckMode(false);
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
                                          color: isNeckMode?AppColors.borderGrey:Theme.of(context).colorScheme.secondary,
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
                                          color: !isNeckMode?AppColors.borderGrey:Theme.of(context).colorScheme.secondary,
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
                      InkWell(
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
                    if(!isControllable)getExplaationWidget(),
                    ...getRecipeWidgets(),
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
                disabled : !isControllable,
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
                    textStyle: TextStyle(
                      color: isControllable?AppColors.textPurple:Colors.transparent,
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

  /// 레시피 페이지 설정
  void buildPage() {
    isControllable = getControllableState(context, isNeckMode);
    recipes = [];
    if(isControllable){
      ///todo 추후 서버에서 맞춤설정 가져와야함
      recipes.add(ElectroStimulationParameterResponse(
          name:"사용자 맞춤 설정", interval: 1, intensity: 9, height: 6));
    }

    for (var parameter in AppDAO.baseData.electroStimulationParameters) {
      recipes.add(ElectroStimulationParameterResponse(
          name:parameter.name,
          interval: parameter.interval,
          intensity: parameter.intensity,
          height: parameter.height));
    }
  }

  List<Widget> getRecipeWidgets() {
    List<Widget> list = [];

    recipes.forEach((recipe) {
      Widget widget = GestureDetector(
        onTap: () {
          if(isControllable){
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
        decoration: BoxDecoration(
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
              recipe.name,
              style: Theme
                  .of(context)
                  .textTheme
                  .headline6,
            ),
            SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '자극\n간격',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline2,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${recipe.interval}',
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '자극\n세기',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline2,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${recipe.intensity}',
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '자극\n높이',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline2,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '${recipe.height}',
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline1,
                      ),
                    ],
                  ),
                ),
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

  /***
   * 현재
   */
  void updateCurrentRecipe(ElectroStimulationParameterResponse recipe) {
    selectedRecipe = recipe;
    sendDataToDevice(context);
  }

  double getValueFromCurrentRecipe(double index) {
    if(selectedRecipe == null) return 0;
    if(index == 0){
      return selectedRecipe!.interval.toDouble();
    }else if(index == 1){
      return selectedRecipe!.intensity.toDouble();
    }else if(index == 2){
      return selectedRecipe!.height.toDouble();
    }
    return 0;
  }

  /// 컨트롤 가능 상태인지 알림
  bool getControllableState(BuildContext context, bool isNeckMode) {
    if(isNeckMode){
      if( context.read<BluetoothProvider>().connectorNeck.connectedDeviceId !=""){
        return true;
      }
    }
    if(!isNeckMode){
      if( context.read<BluetoothProvider>().connectorForehead.connectedDeviceId !=""){
        return true;
      }
    }
    return false;
  }

  Widget getExplaationWidget() {
    return Container(
      margin:EdgeInsets.only(top:10),
      width: double.maxFinite,
      padding: const EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 26,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).focusColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(width: 1.5,
            color: Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "사용자 맞춤 설정",
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height:15),
          Text(
            "사용자 맞춤 전기 자극 설정은 실시간 생체 신호를 계산하여 인공지능을 통해 최적의 자극 레시피를 산출하는 방법으로 기기 부착 후 사용 가능한 설정입니다.",
            style: Theme.of(context).textTheme.headline3,
          ),
        ],
      ),
    );
  }

  void setNeckMode(bool _isNeckMode) {
    isNeckMode = _isNeckMode;
    buildPage();
    setState(() {});
  }

  void sendDataToDevice(BuildContext context) {
    var recipe = selectedRecipe;
    if(isNeckMode && context.read<BluetoothProvider>().deviceNeck == null){
      return ;
    }
    if(!isNeckMode && context.read<BluetoothProvider>().deviceForehead == null){
      return ;
    }
    context.read<BluetoothProvider>().sendData(isNeckMode?BODY_TYPE.NECK:BODY_TYPE.FOREHEAD, "102|" + ((recipe?.intensity??10 / 10 * 200).round()).toString() + "\n");
    context.read<BluetoothProvider>().sendData(isNeckMode?BODY_TYPE.NECK:BODY_TYPE.FOREHEAD,"104|" + ((recipe?.height??10 / 10 * 200).round()).toString() + "\n");
    context.read<BluetoothProvider>().sendData(isNeckMode?BODY_TYPE.NECK:BODY_TYPE.FOREHEAD,"106|" + ((recipe?.interval??10 / 10 * 4095).round()).toString() + "\n");
    // context.read<BluetoothProvider>().sendData(isNeckMode?BODY_TYPE.NECK:BODY_TYPE.FOREHEAD,"109|1\n");
    // context.read<BluetoothProvider>().sendData(isNeckMode?BODY_TYPE.NECK:BODY_TYPE.FOREHEAD,"909|1\n");
    context.read<BluetoothProvider>().sendData(isNeckMode?BODY_TYPE.NECK:BODY_TYPE.FOREHEAD,"910|2\n");
  }

  isSelectedRecipe(ElectroStimulationParameterResponse recipe) {
    if(isNeckMode && context.read<BluetoothProvider>().deviceNeck == null){
      return false;
    }
    if(!isNeckMode && context.read<BluetoothProvider>().deviceForehead == null){
      return false;
    }
    if(
      selectedRecipe?.height == recipe.height &&
      selectedRecipe?.interval == recipe.interval &&
      selectedRecipe?.intensity == recipe.intensity
    ){
      return true;
    }
    return false;
  }
}