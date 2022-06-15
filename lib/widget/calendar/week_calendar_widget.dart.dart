import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/day_calendar_widget.dart.dart';

class WeekCalendarWidget extends BaseStatefulWidget{
  const WeekCalendarWidget({Key? key}) : super(key: key);

  @override
  WeekCalendarState createState() => WeekCalendarState();
}

class WeekCalendarState extends State<WeekCalendarWidget>{

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 60,
      color: Colors.orange,
      child: Row(
        children: [...getDaysWidget()],
      )
    );
  }

  getDaysWidget() {
    List<Widget> days = [];
    days.add(Expanded(child: DayCalendarWidget()));
    days.add(Expanded(child: DayCalendarWidget()));
    days.add(Expanded(child: DayCalendarWidget()));
    days.add(Expanded(child: DayCalendarWidget()));
    days.add(Expanded(child: DayCalendarWidget()));
    days.add(Expanded(child: DayCalendarWidget()));
    days.add(Expanded(child: DayCalendarWidget()));
    return days;
  }
}