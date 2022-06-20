import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/week_calendar_widget.dart.dart';

import 'month_calendar_widget.dart.dart';

class MyWeeklyCalendarWidget extends BaseStatefulWidget{
  final Function? onTapCallback;
  const MyWeeklyCalendarWidget({Key? key, this.onTapCallback }) : super(key: key);

  @override
  MyWeeklyCalendarState createState() => MyWeeklyCalendarState();
}

class MyWeeklyCalendarState extends State<MyWeeklyCalendarWidget>{
  final PageController _pageController = PageController();

  @override
  void initState() {
    initScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      height: 92,
        child: PageView(
          controller: _pageController,
          children: [
            ...getPages()
          ],
        )
      );
  }

  getPages() {
    List<Widget> weeks = [];
    // weeks.add(WeekCalendarWidget(onTapCallback: widget.onTapCallback));
    // weeks.add(WeekCalendarWidget(onTapCallback: widget.onTapCallback));
    // weeks.add(WeekCalendarWidget(onTapCallback: widget.onTapCallback));
    // weeks.add(WeekCalendarWidget(onTapCallback: widget.onTapCallback));
    return weeks;
  }

  void initScrollController() {
    _pageController.addListener(() {
    });
  }
}