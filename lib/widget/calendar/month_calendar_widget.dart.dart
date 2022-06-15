import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/week_calendar_widget.dart.dart';

class MonthCalendarWidget extends BaseStatefulWidget{
  const MonthCalendarWidget({Key? key}) : super(key: key);

  @override
  MonthCalendarState createState() => MonthCalendarState();
}

class MonthCalendarState extends State<MonthCalendarWidget>{
  int weekSize = 5; //4~6

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: weekSize * 60,
      color: Colors.orange,
      child: Column(
        children: [...getWeekWidget()],
      )
    );
  }

  getWeekWidget() {
    List<Widget> weeks = [];
    weeks.add(WeekCalendarWidget());
    weeks.add(WeekCalendarWidget());
    weeks.add(WeekCalendarWidget());
    weeks.add(WeekCalendarWidget());
    return weeks;
  }
}