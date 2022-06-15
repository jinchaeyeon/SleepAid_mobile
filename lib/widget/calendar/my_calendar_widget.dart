import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';

import 'month_calendar_widget.dart.dart';

class MyCalendarWidget extends BaseStatefulWidget{
  const MyCalendarWidget({Key? key}) : super(key: key);

  @override
  MyCalendarState createState() => MyCalendarState();
}

class MyCalendarState extends State<MyCalendarWidget>{
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      color: Colors.green,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...getMonthsWidget()
          ],
        )
      )
    );
  }

  getMonthsWidget() {
    List<Widget> months = [];
    months.add(MonthCalendarWidget());
    months.add(MonthCalendarWidget());
    months.add(MonthCalendarWidget());
    months.add(MonthCalendarWidget());
    return months;
  }
}