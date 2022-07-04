import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';
import 'package:sleepaid/widget/calendar/day_calendar_widget.dart.dart';

class WeekCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  final CalendarDateBuilder dateBuilder;
  final List<DateTime?> week;
  final DateTime? selectedDate;

  const WeekCalendarWidget({Key? key, this.onTapCallback, required this.dateBuilder,
    required this.week, this.selectedDate}) : super(key: key);

  @override
  WeekCalendarState createState() => WeekCalendarState();
}

class WeekCalendarState extends State<WeekCalendarWidget>{

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      // color: Colors.red,
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: AppColors.backgroundGrey,))
      ),
      child: Column(
        children: [
          // Container(
          //     margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          //     height:2,
          //     width: double.maxFinite,
          //     color: AppColors.backgroundGrey,
          //     child: SizedBox.shrink()
          // ),
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
        days.add(
          Expanded(
            child: DayCalendarWidget(
              dateBuilder:widget.dateBuilder,
              day:date,onTapCallback:
              widget.onTapCallback,
              isSelectedDay: date.day == widget.selectedDate?.day,
            )
          )
        );
      }
    });
    return days;
  }
}