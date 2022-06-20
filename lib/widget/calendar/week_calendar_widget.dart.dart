import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/day_calendar_widget.dart.dart';

class WeekCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;

  final List<DateTime?> week;
  const WeekCalendarWidget({Key? key, this.onTapCallback, required this.week}) : super(key: key);

  @override
  WeekCalendarState createState() => WeekCalendarState();
}

class WeekCalendarState extends State<WeekCalendarWidget>{

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      // height: 60,
      // color: Colors.orange,
      child: Column(
        children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              height:2,
              width: double.maxFinite,
              color: AppColors.backgroundGrey,
              child: SizedBox.shrink()
          ),
          Row(
            children: [...getDaysWidget()],
          )
        ]
      )
    );
  }

  getDaysWidget() {
    List<Widget> days = [];
    widget.week.forEach((date) {
      if(date == null){
        days.add(Expanded(child: Container()));
      }else{
        days.add(Expanded(child: DayCalendarWidget(day:date,onTapCallback: widget.onTapCallback)));
      }
    });
    return days;
  }
}