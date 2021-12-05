import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_animation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<String> mainRes = [];
  List<String> bgRes = [];
  List<String> resizeMainRes = [];
  List<String> resizeBgRes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initRes();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      // body: MainAnimation(mainRes), // first ver.
      // body: AnimationVer2(mainRes, bgRes),
      body: MainAnimation(mainRes, bgRes, resizeMainRes, resizeBgRes),
      // body: DebugTest(mainRes, bgRes),

    );
  }

  void initRes() {

    // main
    int resCount = 11;
    mainRes.length = resCount;
    resizeMainRes.length = resCount;

    for (int i = 0; i < resCount; i++) {
      String tmpPath = 'resource/images/uhd/img';
      String tmpResizePath = 'resource/images/uhd/resize_img';

      if (i < 9) {
        mainRes[i] = tmpPath + '0' + (i+1).toString() + '.jpg';
        resizeMainRes[i] = tmpResizePath + '0' + (i+1).toString() + '.jpg';
      } else {
        mainRes[i] = tmpPath + (i+1).toString() + '.jpg';
        resizeMainRes[i] = tmpResizePath + (i+1).toString() + '.jpg';
      }

      print(resizeMainRes[i]);

    }

    // bg
    int bgCount = 5;
    bgRes.length = bgCount;
    resizeBgRes.length = bgCount;
    for (int i = 0; i < bgCount; i++) {
      // String tmpPath = 'resource/images/bg';
      String tmpPath = 'resource/images/uhd/bg';
      String tmpResPath = 'resource/images/uhd/resize_bg';
      if (i < 9) {
        bgRes[i] = tmpPath + '0' + (i+1).toString() + '.jpg';
        resizeBgRes[i] = tmpResPath + '0' + (i+1).toString() + '.jpg';
      } else {
        bgRes[i] = tmpPath + (i+1).toString() + '.jpg';
        resizeBgRes[i] = tmpResPath + (i+1).toString() + '.jpg';
      }

      print(resizeBgRes[i]);
    }

  }
}
