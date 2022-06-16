import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/week_calendar_widget.dart.dart';

class MonthCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  const MonthCalendarWidget({Key? key, this.onTapCallback}) : super(key: key);

  @override
  MonthCalendarState createState() => MonthCalendarState();
}

class MonthCalendarState extends State<MonthCalendarWidget>{
  int weekSize = 5; //4~6
  num weekHeight = 70;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: Column(
        children: [
          getTitle(),
          ...getWeekWidget()
        ],
      )
    );
  }

  List<Widget> getWeekWidget() {
    List<Widget> weeks = [];
    weeks.add(WeekCalendarWidget(onTapCallback: widget.onTapCallback,));
    weeks.add(WeekCalendarWidget(onTapCallback: widget.onTapCallback));
    weeks.add(WeekCalendarWidget(onTapCallback: widget.onTapCallback));
    weeks.add(WeekCalendarWidget(onTapCallback: widget.onTapCallback));
    return weeks;
  }

  Widget getTitle() {
    return Container(
      height: 50,
      child: Row(
        children: const [
          Expanded(flex: 1, child: SizedBox.shrink()),
          Expanded(flex: 1,
              child: Text("5월",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black))
           ),
          Expanded(flex: 5, child: SizedBox.shrink()),

        ],
      )
    );
  }
}