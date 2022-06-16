import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';

import 'month_calendar_widget.dart.dart';

class MyCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  const MyCalendarWidget({Key? key, this.onTapCallback }) : super(key: key);

  @override
  MyCalendarState createState() => MyCalendarState();
}

class MyCalendarState extends State<MyCalendarWidget>{
  final ScrollController _caledarController = ScrollController();

  @override
  void initState() {
    initScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll){
            overScroll.disallowGlow();
            return true;
          },
          child:SingleChildScrollView(
            controller: _caledarController,
            child: Column(
              children: [
                ...getMonthsWidget()
              ],
            )
        )
      )
    );
  }

  getMonthsWidget() {
    List<Widget> months = [];
    months.add(MonthCalendarWidget(onTapCallback: widget.onTapCallback));
    months.add(MonthCalendarWidget(onTapCallback: widget.onTapCallback));
    months.add(MonthCalendarWidget(onTapCallback: widget.onTapCallback));
    months.add(MonthCalendarWidget(onTapCallback: widget.onTapCallback));
    return months;
  }

  void initScrollController() {
    _caledarController.addListener(() {

    });
  }
}