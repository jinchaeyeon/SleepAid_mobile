import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:surround_sound/surround_sound.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Surround Sound Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controllerLeft = SoundController();
  final _controllerRight = SoundController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Surround Sound Example"),
      ),
      body: ListView(
        children: <Widget>[
          SoundWidget(
            soundController: _controllerLeft,
            backgroundColor: Colors.green,
          ),
          SoundWidget(
            soundController: _controllerRight,
            backgroundColor: Colors.red,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MaterialButton(
                child: Text("Play"),
                onPressed: () async {
                  await _controllerLeft.play();
                  await _controllerRight.play();
                  final valR = await _controllerLeft.isPlaying();
                  final valL = await _controllerRight.isPlaying();
                  print('isPlaying: R: $valR , L: $valL');
                },
              ),
              SizedBox(width: 24),
              MaterialButton(
                child: Text("Stop"),
                onPressed: () async {
                  await _controllerLeft.stop();
                  await _controllerRight.stop();
                  final valR = await _controllerLeft.isPlaying();
                  final valL = await _controllerRight.isPlaying();
                  print('isPlaying: R: $valR , L: $valL');
                },
              ),
            ],
          ),

          ValueListenableBuilder<AudioParam>(
            valueListenable: _controllerLeft,
            builder: (context, value, _) {
              return Column(
                children: <Widget>[
                  Text("Volume"),
                  Slider(
                    value: value.volume,
                    min: 0,
                    max: 1,
                    onChanged: (val) {
                      _controllerLeft.setVolume(val);
                    },
                  ),
                  Text("Frequency"),
                  Slider(
                    value: value.freq,
                    min: 128,
                    max: 1500,
                    onChanged: (val) {
                      _controllerLeft.setFrequency(val);
                    },
                  ),
                  SizedBox(height: 32),
                  Text(
                    "Position",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text("x-axis"),
                  Slider(
                    value: value.x,
                    min: -1.0,
                    max: 1.0,
                    onChanged: (val) {
                      _controllerLeft.setPosition(val, value.y, value.z);
                    },
                  ),
                  Text("y-axis"),
                  Slider(
                    value: value.y,
                    min: -1.0,
                    max: 1.0,
                    onChanged: (val) {
                      _controllerLeft.setPosition(value.x, val, value.z);
                    },
                  ),
                  Text("z-axis"),
                  Slider(
                    value: value.z,
                    min: -1.0,
                    max: 1.0,
                    onChanged: (val) {
                      _controllerLeft.setPosition(value.x, value.y, val);
                    },
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 50),
          ValueListenableBuilder<AudioParam>(
            valueListenable: _controllerRight,
            builder: (context, value, _) {
              return Column(
                children: <Widget>[
                  Text("Volume"),
                  Slider(
                    value: value.volume,
                    min: 0,
                    max: 1,
                    onChanged: (val) {
                      _controllerRight.setVolume(val);
                    },
                  ),
                  Text("Frequency"),
                  Slider(
                    value: value.freq,
                    min: 128,
                    max: 1500,
                    onChanged: (val) {
                      _controllerRight.setFrequency(val);
                    },
                  ),
                  SizedBox(height: 32),
                  Text(
                    "Position",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text("x-axis"),
                  Slider(
                    value: value.x,
                    min: -1.0,
                    max: 1.0,
                    onChanged: (val) {
                      _controllerRight.setPosition(val, value.y, value.z);
                    },
                  ),
                  Text("y-axis"),
                  Slider(
                    value: value.y,
                    min: -1.0,
                    max: 1.0,
                    onChanged: (val) {
                      _controllerRight.setPosition(value.x, val, value.z);
                    },
                  ),
                  Text("z-axis"),
                  Slider(
                    value: value.z,
                    min: -1.0,
                    max: 1.0,
                    onChanged: (val) {
                      _controllerRight.setPosition(value.x, value.y, val);
                    },
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}