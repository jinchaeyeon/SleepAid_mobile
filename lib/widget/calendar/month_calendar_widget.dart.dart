import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/data/network/sleep_analysis_response.dart';
import 'package:sleepaid/data/network/sleep_condition_parameter_response.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';
import 'package:sleepaid/widget/calendar/week_calendar_widget.dart.dart';

class MonthCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  final List<List<DateTime?>> weeks;
  final String title;
  final CalendarDateBuilder dateBuilder;
  final Map<String, SleepConditionDateResponse> data;

  const MonthCalendarWidget({
    Key? key,
    required this.title,
    this.onTapCallback,
    required this.weeks,
    required this.dateBuilder,
    this.data = const {},
  }) : super(key: key);

  @override
  MonthCalendarState createState() => MonthCalendarState();
}

class MonthCalendarState extends State<MonthCalendarWidget>{
  num weekHeight = 70;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Column(
        children: [
          Container(
            child: getTitle(),
          ),
          ...getWeekWidget()
        ],
      )
    );
  }

  List<Widget> getWeekWidget() {
    List<Widget> weekWidgets = [];
    print("week=-----------------");
    for (var week in widget.weeks) {
      print("week: ${week}");
      weekWidgets.add(WeekCalendarWidget(
        dateBuilder: widget.dateBuilder, week:week,
        onTapCallback: widget.onTapCallback, data: widget.data,));
    }
    return weekWidgets;
  }

  Widget getTitle() {
    List<Widget> row = [
      const Expanded(flex: 1, child: SizedBox.shrink()),
      const Expanded(flex: 1, child: SizedBox.shrink()),
      const Expanded(flex: 1, child: SizedBox.shrink()),
      const Expanded(flex: 1, child: SizedBox.shrink()),
      const Expanded(flex: 1, child: SizedBox.shrink()),
      const Expanded(flex: 1, child: SizedBox.shrink()),
    ];
    int titleIndex = getTitleIndex(widget.weeks);

    row.insert(titleIndex, Expanded(flex: 1,
        child: Text("${widget.title}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black))
    ));

    return Container(
      height: 50,
      child: Row(
        children: row,
      )
    );
  }

  int getTitleIndex(List<List<DateTime?>> weeks) {
    int index = 0;
    for (var date in weeks[0]) {
      if(date == null){
        index = index + 1;
      }
    }
    return index;
  }
}