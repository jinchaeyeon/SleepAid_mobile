import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sleepaid/data/network/calendar_response.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'month_calendar_widget.dart.dart';

/// 가입일을 기준으로 데이터 목록을 불러온다
/// 가입일부터 어제까지의 달력을 생성한다
class MyCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, SleepAnalysisResponse> data;

  const MyCalendarWidget(
      {Key? key,
        this.onTapCallback,
        required this.startDate,
        required this.endDate,
        required this.data,
      }) : super(key: key);

  @override
  MyCalendarState createState() => MyCalendarState();
}

class MyCalendarState extends State<MyCalendarWidget>{
  String currentYYYY = "";
  bool isInit = true;
  bool isLoading = true;
  final ScrollController _caledarController = ScrollController();
  CalendarDateBuilder dateBuilder = CalendarDateBuilder(
      DateTime.now().subtract(Duration(days:1)),
      DateTime.now().subtract(Duration(days:1)),
      []
  );

  DIRECTION_TYPE _direction = DIRECTION_TYPE.DIRECTION_NONE;
  double _lastPosition = 0;

  @override
  void initState() {
    isLoading = true;
    initScrollController();
    checkData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getBaseWillScope(
        context,
        Listener(
          onPointerMove: (PointerMoveEvent event){
            if(_lastPosition > event.position.dy) {
              _direction = DIRECTION_TYPE.DIRECTION_UP;
            }else if(_lastPosition < event.position.dy){
              _direction = DIRECTION_TYPE.DIRECTION_DOWN;
            }
            _lastPosition = event.position.dy;
          },
          onPointerUp: (PointerUpEvent event){
            ///업다운 드래그 스크롤링이 끝나면 현재 위치 스크롤러 위치를 기준으로 최상단에 N월을 고정한다
            jumtPosition(_direction);
            _direction = DIRECTION_TYPE.DIRECTION_NONE;
            _lastPosition = 0;
          },
          child: mainContent()
        )

    );
  }

  List<Widget> getMonthsWidgets() {
    List<Widget> monthWidgets = [];
    for (var monthString in dateBuilder.monthStrings) {
      monthWidgets.add(MonthCalendarWidget(
          title: "${monthString.substring(5)}월",
          onTapCallback: widget.onTapCallback,
          dateBuilder: dateBuilder,
          weeks: dateBuilder.weeksPerMonth[monthString]??[],
          data: widget.data,
      ));
    }
    return monthWidgets;
  }

  void initScrollController() {
    _caledarController.addListener(() {
      print("initScrollController position ${_caledarController.position}");
      print("initScrollController offset   ${_caledarController.offset}");
      // 전체 달을 가져오면
      // 달의 title height 50 + week 90height * week 숫자 로 현재 month를 확인할 수 있음
      if(currentYYYY != "${dateBuilder.getCurrentDateFromScrollPosition(_caledarController.offset).year}"){
        currentYYYY  = "${dateBuilder.getCurrentDateFromScrollPosition(_caledarController.offset).year}";
        setState(() {});
      }
    });
  }

  Future<void> checkData(BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 100), () async {
      if(!isLoading) return;
      isLoading = false;
      print("checkData start");
      context.read<DataProvider>().setLoading(true);
      List<CalendarDetailResponse> response = await context.read<DataProvider>().loadCalendarData();
      dateBuilder = CalendarDateBuilder(widget.startDate, widget.endDate.add(Duration(days:1)), response);
      setState(() {});
      context.read<DataProvider>().setLoading(false);
      if(isInit){
        await Future.delayed(const Duration(milliseconds:100));
        print("TEST 001: ${_caledarController.position.maxScrollExtent}");
        _caledarController.jumpTo(_caledarController.position.maxScrollExtent);
        isInit = false;
        setState(() {});
      }
    });
  }

  Widget mainContent(){
    return Container(
        width: double.maxFinite,
        height: double.maxFinite,
        alignment: Alignment.topCenter,
        child: Stack(
          children: [
            Positioned(left: 10, top:10,
              child: GestureDetector(
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
            ),
            Positioned(left: 70, top:10,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 200,
                  height: 60,
                  alignment: Alignment.centerLeft,
                  child: Text("${currentYYYY}${currentYYYY==""?"":"년"}", style: TextStyle(height: 1, fontSize: 22,color: AppColors.textBlack, fontWeight: FontWeight.bold)

                  ),
                ),
              )
            ),
            Positioned(
                left: 0, right:0 ,top:80,
                child: Container(width:double.maxFinite, height: 1, color: AppColors.backgroundGrey)
            ),
            Positioned(
                left: 0,right: 0,top: 81,bottom: 0,
                child: Container(
                    color:Colors.white,
                    width:double.maxFinite,
                    height: double.maxFinite,
                    padding: const EdgeInsets.all(15),
                    child: calendarMainContent()
                )
            )
          ],
        ));
  }

  Widget? calendarMainContent() {
    return Container(
        width: double.maxFinite,
        height: double.maxFinite,
        child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll){
              overScroll.disallowGlow();
              return true;
            },
            child:SingleChildScrollView(
                controller: _caledarController,
                child: Column(
                  children: [
                    ...getMonthsWidgets(),
                    SizedBox(height: 300,)
                  ],
                )
            )
        )
    );
  }

  void jumtPosition(DIRECTION_TYPE direction) {
    double position = dateBuilder.getCurrentScrollPosition(direction, _caledarController.offset);
    print("TEST 002: ${position}");
    _caledarController.animateTo(position, duration: const Duration(milliseconds:300), curve: Curves.fastOutSlowIn);
  }
}