// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:sound_generator/waveTypes.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class MyPainter extends CustomPainter {
//   //         <-- CustomPainter class
//   final List<int> oneCycleDataLeft;
//   final List<int> oneCycleDataRight;
//
//   MyPainter(this.oneCycleDataLeft, this.oneCycleDataRight);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     var i = 0;
//     List<Offset> maxPoints = [];
//
//     final t = size.width / (oneCycleDataLeft.length - 1);
//     for (var _i = 0, _len = oneCycleDataLeft.length; _i < _len; _i++) {
//       maxPoints.add(Offset(
//           t * i,
//           size.height / 2 -
//               oneCycleDataLeft[_i].toDouble() / 32767.0 * size.height / 2));
//       i++;
//     }
//
//     final paint = Paint()
//       ..color = Colors.black
//       ..strokeWidth = 1
//       ..strokeCap = StrokeCap.round;
//     canvas.drawPoints(PointMode.polygon, maxPoints, paint);
//   }
//
//   @override
//   bool shouldRepaint(MyPainter old) {
//     if (oneCycleDataLeft != old.oneCycleDataLeft) {
//       return true;
//     }
//     return false;
//   }
// }
//
// class _MyAppState extends State<MyApp> {
//
//   bool isPlayingLeft = false;
//   bool isPlayingRight = false;
//   double frequency = 20;
//   double balance = 0;
//   double volume = 1;
//   waveTypes waveType = waveTypes.SINUSOIDAL;
//   int sampleRate = 96000;
//   List<int>? oneCycleDataLeft;
//   List<int>? oneCycleDataRight;
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//             appBar: AppBar(
//               title: const Text('Sound Generator Example'),
//             ),
//             body: SingleChildScrollView(
//                 physics: AlwaysScrollableScrollPhysics(),
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 20.0,
//                   vertical: 20,
//                 ),
//                 child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text("A Cycle's Snapshot With Real Data"),
//                       SizedBox(height: 2),
//                       Container(
//                           height: 100,
//                           width: double.infinity,
//                           color: Colors.white54,
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 5,
//                             vertical: 0,
//                           ),
//                           child: oneCycleDataLeft != null
//                               ? CustomPaint(
//                             painter: MyPainter(oneCycleDataLeft!, oneCycleDataRight!),
//                           )
//                               : Container()),
//                       SizedBox(height: 2),
//                       Text("A Cycle Data Length is " +
//                           (sampleRate / this.frequency).round().toString() +
//                           " on sample rate " +
//                           sampleRate.toString()),
//                       SizedBox(height: 5),
//                       Divider(
//                         color: Colors.red,
//                       ),
//                       SizedBox(height: 5),
//                       CircleAvatar(
//                           radius: 30,
//                           backgroundColor: Colors.lightBlueAccent,
//                           child: IconButton(
//                               icon: Icon(
//                                   isPlayingLeft ? Icons.stop : Icons.play_arrow),
//                               onPressed: () {
//                                 playLeft(context);
//                               })),
//                       SizedBox(height: 5),
//                       CircleAvatar(
//                           radius: 30,
//                           backgroundColor: Colors.lightBlueAccent,
//                           child: IconButton(
//                               icon: Icon(
//                                   isPlayingRight ? Icons.stop : Icons.play_arrow),
//                               onPressed: () {
//                                 playRight(context);
//                               })),
//                       Divider(
//                         color: Colors.red,
//                       ),
//                       SizedBox(height: 5),
//                       Text("Wave Form"),
//                       Center(
//                           child: DropdownButton<waveTypes>(
//                               value: this.waveType,
//                               onChanged: (waveTypes? newValue) {
//                                 setState(() {
//                                   this.waveType = newValue!;
//                                   left.setWaveType(this.waveType);
//                                   right.setWaveType(this.waveType);
//                                 });
//                               },
//                               items:
//                               waveTypes.values.map((waveTypes classType) {
//                                 return DropdownMenuItem<waveTypes>(
//                                     value: classType,
//                                     child: Text(
//                                         classType.toString().split('.').last));
//                               }).toList())),
//                       SizedBox(height: 5),
//                       Divider(
//                         color: Colors.red,
//                       ),
//                       SizedBox(height: 5),
//                       Text("Frequency"),
//                       Container(
//                           width: double.infinity,
//                           height: 40,
//                           child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: <Widget>[
//                                 Expanded(
//                                   flex: 2,
//                                   child: Center(
//                                       child: Text(
//                                           this.frequency.toStringAsFixed(2) +
//                                               " Hz")),
//                                 ),
//                                 Expanded(
//                                   flex: 8, // 60%
//                                   child: Slider(
//                                       min: 20,
//                                       max: 10000,
//                                       value: this.frequency,
//                                       onChanged: (_value) {
//                                         setState(() {
//                                           this.frequency = _value.toDouble();
//                                           left.setFrequency(
//                                               this.frequency);
//                                           right.setFrequency(
//                                               this.frequency);
//                                         });
//                                       }),
//                                 )
//                               ])),
//                       SizedBox(height: 5),
//                       Text("Balance"),
//                       Container(
//                           width: double.infinity,
//                           height: 40,
//                           child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: <Widget>[
//                                 Expanded(
//                                   flex: 2,
//                                   child: Center(
//                                       child: Text(
//                                           this.balance.toStringAsFixed(2))),
//                                 ),
//                                 Expanded(
//                                   flex: 8, // 60%
//                                   child: Slider(
//                                       min: -1,
//                                       max: 1,
//                                       value: this.balance,
//                                       onChanged: (_value) {
//                                         setState(() {
//                                           // this.balance = _value.toDouble();
//                                           left.setBalance(-1);
//                                           right.setBalance(1);
//                                         });
//                                       }),
//                                 )
//                               ])),
//                       SizedBox(height: 5),
//                       Text("Volume"),
//                       Container(
//                           width: double.infinity,
//                           height: 40,
//                           child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: <Widget>[
//                                 Expanded(
//                                   flex: 2,
//                                   child: Center(
//                                       child:
//                                       Text(this.volume.toStringAsFixed(2))),
//                                 ),
//                                 Expanded(
//                                   flex: 8, // 60%
//                                   child: Slider(
//                                       min: 0,
//                                       max: 1,
//                                       value: this.volume,
//                                       onChanged: (_value) {
//                                         setState(() {
//                                           this.volume = _value.toDouble();
//                                           left.setVolume(this.volume);
//                                           right.setVolume(this.volume);
//                                         });
//                                       }),
//                                 )
//                               ]))
//                     ]))));
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     left.release();
//     right.release();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     isPlayingLeft = false;
//     isPlayingRight = false;
//
//     left.init(sampleRate);
//     right.init(sampleRate);
//
//     left.onIsPlayingChanged.listen((value) {
//       print("left left.onIsPlayingChanged:$value");
//       setState(() {
//         isPlayingLeft = value;
//       });
//     });
//
//     right.onIsPlayingChanged.listen((value) {
//       print("right right.onIsPlayingChanged:$value");
//       setState(() {
//         isPlayingRight = value;
//       });
//     });
//
//     left.onOneCycleDataHandler.listen((value) {
//       setState(() {
//         oneCycleDataLeft = value;
//       });
//     });
//     right.onOneCycleDataHandler.listen((value) {
//       setState(() {
//         oneCycleDataRight = value;
//       });
//     });
//
//     left.setAutoUpdateOneCycleSample(true);
//     right.setAutoUpdateOneCycleSample(true);
//     //Force update for one time
//     left.refreshOneCycleData();
//     right.refreshOneCycleData();
//   }
//
//   void playLeft(BuildContext context) {
//     if(isPlayingLeft){
//       left.stop();
//     }else{
//       left.play();
//     }
//   }
//
//   void playRight(BuildContext context) {
//     if(isPlayingRight){
//       right.stop();
//     }else{
//       right.play();
//     }
//   }
// }