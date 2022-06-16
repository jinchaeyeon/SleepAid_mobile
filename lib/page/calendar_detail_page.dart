import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/locale.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';
import 'package:sleepaid/widget/calendar/my_weekly_calendar_widget.dart';

class CalendarDetailPage extends BaseStatefulWidget {
  static const ROUTE = "CalendarDetail";

  const CalendarDetailPage({Key? key}) : super(key: key);

  @override
  CalendarDetailState createState() => CalendarDetailState();
}

class CalendarDetailState extends State<CalendarDetailPage>
    with SingleTickerProviderStateMixin{
  DateTime selectedDay = DateTime.now();


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: AppColors.backgroundGrey,
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    Positioned(
                        left: 0, right:0 ,top:80,
                        child: Container(
                            width:double.maxFinite,
                            height: 92,
                            color: AppColors.backgroundGrey)
                    ),
                    Positioned(left: 10, top:10,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          child: Image.asset(
                            AppImages.back, color: Theme.of(context).primaryIconTheme.color,
                            fit: BoxFit.contain, width: 12, height: 21,

                          ),
                        ),
                      ),
                    ),
                    Positioned(left: 70, top:10,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 200,
                          height: 60,
                          alignment: Alignment.centerLeft,
                          child: Text("2월", style: TextStyle(height: 1, fontSize: 22,color: AppColors.textBlack, fontWeight: FontWeight.bold)

                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        left: 0,right: 0,top: 81,
                        child: Container(
                          width:double.maxFinite,
                          child: MyWeeklyCalendarWidget()
                        )
                    ),
                    Positioned(
                      left: 0,right: 0,top:172,bottom:0,
                      child: Container(
                        width:double.maxFinite,
                        height:double.maxFinite,
                        color: AppColors.white,
                        child: getDayDetailView()
                      )
                    )
                  ],
                )
            )
        )
    );
  }

  /// 선택일 데이터가 없으면 데이터 로딩 보여주고 로드, 데이터가 있으면 데이터 노출
  Widget getDayDetailView() {
   // return selectedDay;
   return Container(

   );
  }
}


