import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:sleepaid/data/network/calendar_response.dart';
import 'package:sleepaid/provider/data_provider.dart';
import 'package:sleepaid/util/functions.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';

import 'month_calendar_widget.dart.dart';

/// 가입일을 기준으로 데이터 목록을 불러온다
/// 가입일부터 어제까지의 달력을 생성한다
class MyCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  DateTime startDate;
  DateTime endDate;

  MyCalendarWidget(
      {Key? key,
        this.onTapCallback,
        required this.startDate,
        required this.endDate,
      }) : super(key: key);

  @override
  MyCalendarState createState() => MyCalendarState();
}

class MyCalendarState extends State<MyCalendarWidget>{
  bool isLoading = true;
  final ScrollController _caledarController = ScrollController();
   CalendarDateBuilder dateBuilder = CalendarDateBuilder(
     DateTime.now().subtract(Duration(days:1)),
     DateTime.now().subtract(Duration(days:1)),
     []
   );

  @override
  void initState() {
    isLoading = true;
    initScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkData(context);
    return getBaseWillScope(
        context,
        mainContent()
    );
  }

  List<Widget> getMonthsWidgets() {
    List<Widget> monthWidgets = [];
    for (var monthString in dateBuilder.monthStrings) {
      monthWidgets.add(MonthCalendarWidget(
        title: "${monthString.substring(5)}월",
        onTapCallback: widget.onTapCallback,
        weeks: dateBuilder.weeks[monthString]??[]
      ));
    }
    return monthWidgets;
  }

  void initScrollController() {
    _caledarController.addListener(() {

    });
  }

  Future<void> checkData(BuildContext context) async {
    if(!isLoading) return;
    isLoading = false;
    print("checkData start");
    await Future.delayed(const Duration(milliseconds:100));
    await context.read<DataProvider>().setLoading(true);
    List<CalendarDetailResponse> response = await context.read<DataProvider>().loadCalendarData();
    dateBuilder = CalendarDateBuilder(widget.startDate, widget.endDate, response);
    setState(() {});
    await context.read<DataProvider>().setLoading(false);
  }

  Widget? mainContent() {
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
                    ...getMonthsWidgets()
                  ],
                )
            )
        )
    );
  }
}