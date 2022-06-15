import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';

import 'month_calendar_widget.dart.dart';

class DayCalendarWidget extends BaseStatefulWidget{
  const DayCalendarWidget({Key? key}) : super(key: key);

  @override
  DayCalendarState createState() => DayCalendarState();
}

class DayCalendarState extends State<DayCalendarWidget>{
  String text = "월";
  String number = "1";
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 60,
      color: Colors.orange.shade500,
      child: Column(
        children: [
          Text("$text", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
          Text("$number", style: TextStyle(color: Colors.black, fontSize: 19, fontWeight: FontWeight.bold)),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(5)
            )
          )
        ],
      )
    );
  }
}