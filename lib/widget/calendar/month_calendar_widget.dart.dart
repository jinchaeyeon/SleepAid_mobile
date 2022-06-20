import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/week_calendar_widget.dart.dart';

class MonthCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  final List<List<DateTime?>> weeks;
  final String title;

  const MonthCalendarWidget({
    Key? key,
    required this.title,
    this.onTapCallback,
    required this.weeks
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
          getTitle(),
          ...getWeekWidget()
        ],
      )
    );
  }

  List<Widget> getWeekWidget() {
    List<Widget> weekWidgets = [];
    for (var week in widget.weeks) {
      weekWidgets.add(WeekCalendarWidget(week:week, onTapCallback: widget.onTapCallback,));
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
    weeks[0]!.forEach((date) {
      if(date == null){
        index = index + 1;
      }
    });
    return index;
  }
}