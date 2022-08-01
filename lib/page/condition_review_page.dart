import 'dart:math';
import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:provider/src/provider.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';
import 'package:sleepaid/data/network/sleep_condition_response.dart';
import 'package:sleepaid/network/sleeping_analytics_service.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';


class ConditionReviewPage extends BaseStatefulWidget {
  static const ROUTE = "/ConditionReview";

  const ConditionReviewPage({Key? key}) : super(key: key);

  @override
  ConditionReviewState createState() => ConditionReviewState();
}

class ConditionReviewState extends State<ConditionReviewPage>
    with SingleTickerProviderStateMixin{
  List<SleepConditionParameterResponse> parameters = [];
  List<SleepConditionItem> items = [];

  List<int> requiredIndexes = []; /// 필수 항목 인덱스
  Set<int> updatedIndexes = {}; /// 수정(값이 유저로부터 받아져 온 인덱스)

  Map<String, dynamic>? args;

  SleepAnalysisResponse? data;
  DateTime? selectedDate;

  @override
  void initState() {
    parameters.addAll(List.from(AppDAO.baseData.sleepConditionParameters));
    for (var parameter in parameters) {
      if(parameter.isRequired){
        requiredIndexes.add(parameters.indexOf(parameter));  
      }
      
      if(parameter.answerType == answerTypes[0]){ //score
        items.add(SleepConditionItem(
          id: parameter.id,
          answerType: parameter.answerType,
            question: parameter.question, isFixed: true, answerScore: parameter.score));
      }else { // bool
        items.add(SleepConditionItem(
            id: parameter.id,
            answerType: parameter.answerType,
            question: parameter.question, isFixed: true, answerBool: null));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(args == null){
      args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      data = args?["data"];
      selectedDate = args?["selectedDate"];
    }

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
                            Text(getDateString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
                            Text("${updatedIndexes.length.toString().padLeft(2, '0')}/${items.length.toString().padLeft(2, '0')}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),),
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
      onTap: () async {
        /// 먼저 필수 체크 한 후에
        /// 전부 선택했으면
        /// 서버에 저장 요청 후
        /// 저장 완료되면 종료
        bool existAll = true;
        requiredIndexes.forEach((index) {
          if(!updatedIndexes.contains(index)){
            existAll = false;
          }
        });
        if(existAll) {
          await sendConditionData();
        }else{
          showToast("필수입력항목을 입력해주세요.");
        }
      },
      child: Container(
        width: double.maxFinite,
        height: 80,
        color: AppColors.buttonBlue,
        child: const Center(
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
    items.forEach((item) {
      list.add(getSurveryItemWidget(index: items.indexOf(item)));
    });
    return list;
  }

  Widget getSurveryItemWidget({required int index}){
    SleepConditionItem item = items[index];
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
              requiredIndexes.contains(index)?"필수항목입니다":"",
              style: TextStyle(color: AppColors.textBlack, fontSize: 11, fontWeight: FontWeight.w400,)
          ),
        ):SizedBox.shrink(),
        item.answerType == "score"?
        Positioned(
            left:20, top:0, right:20, bottom: 0,
            child:Container(
              width:double.maxFinite,
              height: 50,
              child: FlutterSlider(
                values: [item.answerScore.toDouble()],
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
                  // print("lower; $lowerValue upper:$upperValue");
                  item.answerScore = (lowerValue as double).toInt();
                  updatedIndexes.add(index);
                  setState(() {});
                },
                tooltip: FlutterSliderTooltip(
                    format: format,
                    disableAnimation: true,
                    alwaysShowTooltip: true,
                    positionOffset: FlutterSliderTooltipPositionOffset(
                        top: 100
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
                        item.answerBool = true;
                        updatedIndexes.add(index);
                        setState(() {});
                      },
                      child: Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        alignment: Alignment.center,
                          child: Text("그렇다", style: TextStyle(color: item.answerBool == true?AppColors.textBlack:AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w600),)
                      )
                  ),
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(fixedSize: Size(110, 35), backgroundColor: AppColors.white),
                      onPressed: (){
                        item.answerBool = false;
                        updatedIndexes.add(index);
                        setState(() {});
                      },
                      child: Container(
                          width: double.maxFinite,
                          height: double.maxFinite,
                          alignment: Alignment.center,
                          child: Text("아니다", style: TextStyle(color: item.answerBool == false?AppColors.textBlack:AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.w600),)
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

  /// 수면 컨디션 데이터를 서버에 전송한다
  sendConditionData() async{
    var rand = Random();
    int arRandVal = rand.nextInt(25);
    int ldRandVal = rand.nextInt(25);
    List<Map<String, dynamic>> list = [];
    updatedIndexes.toList().forEach((index) {
      list.add(items[index].toSendDataJson());
    });
    await PostSleepConditionService(
      id: 0,
      date: getDateStringForAPI(),
      /// todo 임의값 부여
      awake: 25+arRandVal,
      rem: 25-arRandVal,
      light: 25+ldRandVal,
      deep: 25-ldRandVal,
      quality: rand.nextInt(99),
      itemSet:list
    ).start().then((result) async {
      if(result is SleepAnalysisResponse){
        AppDAO.baseData.sleepConditionAnalysis = result;
        AppDAO.setLastSleepCondition(result.date, result.id,);
        await context.read<DataProvider>().getSleepAnalysisList();
        Navigator.pop(context, result);
      }else{
        showToast("잠시 후 다시 시도해주세요.");
      }
    });
  }

  String getDateString() {
    if(data == null){
      DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
      return "${yesterday.year}년 ${yesterday.month}월 ${yesterday.day}일";
    }else{
      List<String> split = data!.date.split("-");
      return "${split[0]}년 ${split[1]}월 ${split[2]}일";
    }
  }

  String getDateStringForAPI() {
    if(data != null){
      return data!.date;

    }else if(selectedDate != null){
      return DateFormat('yyyy-MM-dd').format(selectedDate!);
    }else{
      DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
      return DateFormat('yyyy-MM-dd').format(yesterday);
    }
  }
}


