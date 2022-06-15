import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/locale.dart';
import 'package:sleepaid/util/app_colors.dart';
import 'package:sleepaid/util/app_images.dart';
import 'package:sleepaid/widget/base_stateful_widget.dart';

class CalendarDetailPage extends BaseStatefulWidget {
  static const ROUTE = "CalendarDetail";

  const CalendarDetailPage({Key? key}) : super(key: key);

  @override
  CalendarDetailState createState() => CalendarDetailState();
}

class CalendarDetailState extends State<CalendarDetailPage>
    with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CalendarAppBar(
          locale: "ko",
          onDateChanged: (value) => print(value),
          firstDate: DateTime.now().subtract(Duration(days: 140)),
          lastDate: DateTime.now(),
        ),
        extendBody: true,
        body: SafeArea(
            child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
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
                          child: Text("2022년", style: TextStyle(height: 1, fontSize: 22,color: AppColors.textBlack, fontWeight: FontWeight.bold)

                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        left: 0, right:0 ,top:80,
                        child: Container(width:double.maxFinite, height: 1, color: AppColors.backgroundGrey)
                    ),
                    Positioned(
                        left: 0,right: 0,top: 81,bottom: 0,
                        child: Container(
                          width:double.maxFinite,
                          height: double.maxFinite,

                        )
                    )
                  ],
                )
            )
        )
    );
  }
}


