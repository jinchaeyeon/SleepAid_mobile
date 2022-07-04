import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';

import 'month_calendar_widget.dart.dart';

class DayCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  final DateTime day;
  final CalendarDateBuilder dateBuilder;
  final bool isSelectedDay;

  const DayCalendarWidget({Key? key, this.onTapCallback,
    required this.day, required this.dateBuilder, this.isSelectedDay = false}) : super(key: key);

  @override
  DayCalendarState createState() => DayCalendarState();
}

class DayCalendarState extends State<DayCalendarWidget>{

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        if(widget.onTapCallback != null){
          widget.onTapCallback!(widget.dateBuilder, widget.day);
        }
      },
      child: SizedBox(
          width: double.maxFinite,
          height: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height:5),
              Container(
                width:30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.isSelectedDay?AppColors.buttonYellow:Colors.transparent,
                  borderRadius: BorderRadius.circular(15)
                ),
                alignment: Alignment.center,
                child: Text("${getWeekDayString(widget.day.weekday)}", style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              Text("${widget.day.day}", style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
              Container(
                  width: 10,
                  height: 10,
                  margin: EdgeInsets.only(top:5),
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(5)
                  )
              ),
              SizedBox(height:15),
            ],
          )
      )
    );
  }

  List<String> weekdays = ["월", "화", "수", "목", "금", "토", "일",];
  String getWeekDayString(int weekday) {
    return weekdays[weekday - 1];
  }
}