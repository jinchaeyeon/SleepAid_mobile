import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sleepaid/data/network/sleep_condition_response.dart';
import 'package:sleepaid/provider/bluetooth_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:provider/provider.dart';
import '../app_routes.dart';

class ConditionReviewPage extends BaseStatefulWidget {
  static const ROUTE = "ConditionReview";

  const ConditionReviewPage({Key? key}) : super(key: key);

  @override
  ConditionReviewState createState() => ConditionReviewState();
}

class ConditionReviewState extends State<ConditionReviewPage>
    with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(context, ''),
        extendBody: true,
        body: SafeArea(
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Theme.of(context).colorScheme.primaryVariant, Theme.of(context).colorScheme.secondaryVariant],
                  ),
                ),
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Container(
                        height: 50,
                        width: double.maxFinite,
                        padding: const EdgeInsets.only(left: 30),
                        child: const Text("수면 컨디션을 작성해주세요.", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                    ),
                    Container(
                        height: 30,
                        width: double.maxFinite,
                        padding: const EdgeInsets.only(left: 30, right: 30, bottom:10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("2022년 n m.", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
                            Text("00/09", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
                          ],
                        )
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.only(left: 30, right: 30, top: 0, bottom: 0),
                          child: Column(
                            children: [
                              ...getSurveyItems()
                            ],
                          ),
                        ),
                      ),
                    ),
                    bottomNavigator()
                  ],
                )
            )
        )
    );
  }

  Widget bottomNavigator() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: double.maxFinite,
        height: 80,
        color: AppColors.buttonBlue,
        child: Center(
          child: Text(
            '작성완료',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getSurveyItems() {
    List<Widget> list = [];
    list.add(getSurveryItemWidget(item: SleepConditionItem(question: "테스트1", isFixed: true, score: 0)),);
    list.add(getSurveryItemWidget(item: SleepConditionItem(question: "테스트2", isFixed: true, score: 0)),);
    list.add(getSurveryItemWidget(item: SleepConditionItem(question: "테스트3", isFixed: false, isCorrect: null)),);
    list.add(getSurveryItemWidget(item: SleepConditionItem(question: "테스트4", isFixed: false, isCorrect: null)),);
    list.add(getSurveryItemWidget(item: SleepConditionItem(question: "테스트5", isFixed: false, isCorrect: null)),);
    list.add(getSurveryItemWidget(item: SleepConditionItem(question: "테스트6", isFixed: false, isCorrect: null)),);
    return list;
  }

  Widget getSurveryItemWidget({required SleepConditionItem item}){
    return Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white,
        ),
        width: double.maxFinite,
        height: 110,
        child: Stack(
          children: [
          Positioned(
          left: 10,
          top: 10,
          child: Text(
              item.question,
              style: TextStyle(color: AppColors.textBlack, fontSize: 14, fontWeight: FontWeight.w600,)
          ),
        ),
        item.isFixed?
        Positioned(
          right: 10,
          top: 10,
          child: Text(
              "필수항목입니다",
              style: TextStyle(color: AppColors.textBlack, fontSize: 11, fontWeight: FontWeight.w400,)
          ),
        ):SizedBox.shrink(),
        item.isFixed?
        Positioned(
            left:20, top:0, right:20, bottom: 0,
            child:Container(
              width:double.maxFinite,
              height: 50,
              child: FlutterSlider(
                values: [0],
                max: 10,
                min: 0,
                handlerWidth: 0,
                handler: FlutterSliderHandler(
                  child: Container(width: 0, height: 0, color: Colors.transparent),
                ),
                jump: true,
                trackBar: FlutterSliderTrackBar(
                  activeTrackBar: BoxDecoration(gradient: sliderGradient, borderRadius: BorderRadius.circular(11)),
                  activeTrackBarHeight: 22,
                ),
                onDragging: (handlerIndex, lowerValue, upperValue) {
                  item.score = lowerValue;
                  setState(() {});
                },
                tooltip: FlutterSliderTooltip(
                    format: format,
                    disableAnimation: true,
                    alwaysShowTooltip: true,
                    positionOffset: FlutterSliderTooltipPositionOffset(
                        top: 100
                    ),
                    textStyle: TextStyle(
                      color: AppColors.textPurple,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    boxStyle: FlutterSliderTooltipBox(
                      decoration: BoxDecoration(),
                    )),
              )
            )
        ):
        Positioned(
            right:10,
            bottom: 10,
            child:SizedBox(
              width: 230,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(fixedSize: Size(110, 35), backgroundColor: AppColors.buttonGrey),
                      onPressed: (){

                      },
                      child: Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        alignment: Alignment.center,
                          child: Text("그렇다", style: TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w600),)
                      )
                  ),
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(fixedSize: Size(110, 35), backgroundColor: AppColors.white),
                      onPressed: (){

                      },
                      child: Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          alignment: Alignment.center,
                          child: Text("아니다", style: TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w600),)
                      )
                  ),
                ],
              )
            )
        ),
    ]
    )
    );
  }
}


