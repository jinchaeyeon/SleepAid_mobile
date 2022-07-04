// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:sleepaid/util/app_colors.dart';
// import 'package:sleepaid/util/app_images.dart';
// import 'package:sleepaid/widget/base_stateful_widget.dart';
// import 'package:sleepaid/widget/calendar/calendar_date_builder.dart';
// import 'package:sleepaid/widget/calendar/week_calendar_widget.dart.dart';
//
//
// /// 전달받은 dateBuilder 값을 이용해서 페이지뷰를 생성하고, 각 페이지에 관련된 데이터가 없으면 페이지별
// /// 서버에서 데이터를 불러온다
// class MyWeeklyCalendarWidget extends BaseStatefulWidget{
//   final Function? onTapCallback;
//   final DateTime selectedDate;
//   final CalendarDateBuilder dateBuilder;
//
//   const MyWeeklyCalendarWidget({Key? key, this.onTapCallback,
//     required this.selectedDate,  required this.dateBuilder }) : super(key: key);
//
//   @override
//   MyWeeklyCalendarState createState() => MyWeeklyCalendarState();
// }
//
// class MyWeeklyCalendarState extends State<MyWeeklyCalendarWidget>{
//   DateTime? selectedDate;
//   final PageController _pageController = PageController();
//   onTapCallback(builder, date){
//     selectedDate = date;
//     widget.onTapCallback!(widget.dateBuilder, widget.selectedDate);
//     setState(() {});
//   }
//
//   @override
//   void initState() {
//     initScrollController();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     selectedDate ??= widget.selectedDate;
//
//     return Container(
//       width: double.maxFinite,
//       height: 80,
//         child: Stack(
//           children: [
//             Positioned(left: 10, top:10,
//               child: InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   width: 60,
//                   height: 60,
//                   alignment: Alignment.center,
//                   child: Image.asset(
//                     AppImages.back, color: Theme.of(context).primaryIconTheme.color,
//                     fit: BoxFit.contain, width: 12, height: 21,
//
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(left: 70, top:10,
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: Container(
//                   width: 200,
//                   height: 60,
//                   alignment: Alignment.centerLeft,
//                   child: Text("${selectedDate!.month}월", style: TextStyle(height: 1, fontSize: 22,color: AppColors.textBlack, fontWeight: FontWeight.bold)
//
//                   ),
//                 ),
//               ),
//             ), // Positioned()
//             Expanded(
//               child:PageView(
//
//               )
//             )
//           ],
//         )
//       );
//   }
//
//   void initScrollController() {
//     _pageController.addListener(() {
//     });
//   }
// }