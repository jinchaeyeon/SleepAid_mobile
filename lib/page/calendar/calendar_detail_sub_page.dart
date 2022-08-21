import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:sleepaid/data/local/app_dao.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/statics.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/graph/sleep_analysis_graph_widget.dart';
import '../../app_routes.dart';
import '../../util/extensions.dart';

class CalendarDetailSubPage extends BaseStatefulWidget {
  final DateTime selectedDate;
  final Map<String, SleepAnalysisResponse> data;

  const CalendarDetailSubPage({Key? key, required this.selectedDate,  required this.data}) : super(key: key);

  @override
  CalendarDetailSubState createState() => CalendarDetailSubState();
}

class CalendarDetailSubState extends State<CalendarDetailSubPage>
    with SingleTickerProviderStateMixin{
  bool isLoading = true;

  SleepAnalysisResponse? data;

  @override
  void initState() {
    isLoading = true;
    super.initState();
    loadDayData();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading?
      const Center(
        child:SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator()
        )
      )
      :Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: SingleChildScrollView(
          child:Wrap(
            children: [
              homeContent()
            ]
          )
        )
    );
  }

  static final format = DateFormat('yyyy-MM-dd');
  Future<void> loadDayData() async {
    await Future.delayed(const Duration(milliseconds: 200), (){
      data = widget.data[format.format(widget.selectedDate)];
      isLoading = false;
      setState(() {});
    });
  }

  Widget homeContent(){
    return Container(
      color: AppDAO.isDarkMode? AppColors.colorDarkSplash:AppColors.white,
      width: double.maxFinite,
      child:Column(
        children: [
          SizedBox(height: 20),
          ...homeSleepAnalysisContent(),
          SizedBox(height: 20),
          ...sleepConditionContents(),

        ]
      )
    );
  }

  Widget buildSliderControlWidget(String title, String timeString, double percent, {bool isNoTitle=false}) {
    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 20),
          isNoTitle?Container():
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height:5),
                Text(
                  getTimeString(timeString),
                  style: const TextStyle(
                    color: AppColors.subTextGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ]
            ),
          ),
          Expanded(flex: 9,
              child: FlutterSlider(
                disabled : true,
                values: [percent],
                max: 100,
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
                    format: formatPercent,
                    disableAnimation: true,
                    alwaysShowTooltip: true,
                    positionOffset: FlutterSliderTooltipPositionOffset(
                        top: 55,
                    ),
                    textStyle: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    boxStyle: const FlutterSliderTooltipBox(
                      decoration: BoxDecoration(),
                    )),
              )
          ),
          SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget infoBottomSheet() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
                '수면단계?',
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppColors.textBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Awake : 깨어있는 상태\nREM : 꿈 수면 상태\nNon-REM N1 : 얕은 수면 상태\nNon-REM N2: 얕은 수면 상태\nNon-REM N3/4 : 깊은 수면 상태',
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

  String getTimeString(String timeString) {
    String result = "";
    List<String> splits = timeString.split(':');
    if(splits[0]!="00"){
      result += splits[0] + "H";
    }
    if(splits[1]!="00"){
      result += splits[1] + "M";
    }
    if(result == ""){
      result = "0M";
    }
    return result;
  }

  List<Widget> homeSleepAnalysisContent() {
    if(data == null){
      return [
        Row(
          children: [
            SizedBox(width: 20),
            Text(
              '수면단계 분석',
              style: Theme.of(context).textTheme.headline1,
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
                width: 24,
                height: 24,
                margin: EdgeInsets.only(left: 10),
                child: Image.asset(AppImages.info, fit: BoxFit.fill),
              ),
            ),
          ],
        ),
        Container(
          height: 300,
          width:double.maxFinite,
        ),
        SizedBox(height: 40),
      ];
    }
    return [
      Row(
        children: [
          SizedBox(width: 20),
          Text(
            '수면단계 분석',
            style: Theme.of(context).textTheme.headline1,
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
              width: 24,
              height: 24,
              margin: EdgeInsets.only(left: 10),
              child: Image.asset(AppImages.info, fit: BoxFit.fill),
            ),
          )
        ],
      ),
      SizedBox(height: 40),
      Container(
        width: double.maxFinite,
        height: 200,
        child: SleepAnalysisGraph(),
      ),
      SizedBox(height: 20),
      buildSliderControlWidget("Awake", data!.awake, data!.getSleepAnalisysPercent(0)),
      buildSliderControlWidget("REM", data!.rem, data!.getSleepAnalisysPercent(1)),
      buildSliderControlWidget("Light", data!.light, data!.getSleepAnalisysPercent(2)),
      buildSliderControlWidget("Deep", data!.deep, data!.getSleepAnalisysPercent(3)),
      SizedBox(height: 20),
      Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Text(
          '수면 질 점수',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      buildSliderControlWidget("", "", data?.quality.toDouble()??0, isNoTitle: true),
    ];
  }

  List<Widget> sleepConditionContents() {
    if(widget.selectedDate.isToday()) {
      return [
        const SizedBox(height: 20)
      ];
    }
    return [
      Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          '수면 컨디션',
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      SizedBox(height: 20),
      InkWell(
          onTap:() async {
            var result = await Navigator.pushNamed(context, Routes.conditionReview,
                arguments: {"data": data, "selectedDate": widget.selectedDate});
            if(result is SleepAnalysisResponse){
              data = result;
              setState(() {});
            }

          },
          child: Container(
            height: 120,
            width: double.maxFinite,
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
            child: Container(
              width: double.maxFinite,
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.mainGreen,
                    width: 2,
                  )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppDAO.getConditionDateString(response: data, selectedDate: widget.selectedDate),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Text(
                    '수면컨디션을 작성해주세요.',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        // fontFamily: Util.notoSans,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: data == null?'00':data!.itemSet.length.toString().padLeft(2,'0'),
                          style: TextStyle(color: AppColors.subTextBlack),
                        ),
                        TextSpan(
                          text: ' / ${AppDAO.baseData.sleepConditionParameters.length.toString().padLeft(2,'0')}',
                          style: TextStyle(color: AppColors.textGrey),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
      SizedBox(height: 20)
    ];
  }
}

class SleepAnalysisGraph extends BaseStatefulWidget{
  @override
  SleepAnalysisGraphState createState() => SleepAnalysisGraphState();
}

class SleepAnalysisGraphState extends State<SleepAnalysisGraph>{
  List<Object> sleepAnalisysData = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      child:Row(
        children: [
          SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween ,
            children: [
              SizedBox(height:20,
                child: Text("N3/4", style: Theme.of(context).textTheme.bodyText2,),),
              SizedBox(height:20,
                child: Text("N2", style: Theme.of(context).textTheme.bodyText2,),),
              SizedBox(height:20,
                child: Text("N1", style: Theme.of(context).textTheme.bodyText2,),),
              SizedBox(height:20,
                child: Text("REM", style: Theme.of(context).textTheme.bodyText2,),),
              SizedBox(height:20,
                child: Text("Awake", style: Theme.of(context).textTheme.bodyText2,),),
            ]
          ),
          SizedBox(width: 5),
          Expanded(
            flex: 1,
            child:Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SleepAnalisysGraphWidget(data: sleepAnalisysData)
                ),

              ]
            )
          )
        ]
      )
    );
  }
}