import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'define_data.dart';

class MainAnimation extends StatefulWidget {
  MainAnimation(this.mainImages, this.bgImages, this.resizeMainImages, this.resizeBgImages);

  final mainImages;
  final bgImages;
  final resizeMainImages;
  final resizeBgImages;

  MainAnimationState createState() =>
      MainAnimationState(this.mainImages, this.bgImages, this.resizeMainImages, this.resizeBgImages);
}

class MainAnimationState extends State<MainAnimation>
    with TickerProviderStateMixin {
  MainAnimationState(this.mainImages, this.bgImages, this.resizeMainImages, this.resizeBgImages);

  final mainImages;
  final bgImages;
  final resizeMainImages;
  final resizeBgImages;

  double displayHeight, displayWidth;
  double newHeight, newWidth;

  // animation params
  int animTime, animDuration;
  Curve animCurve;
  List<AnimationController> moveController = [];
  List<Animation> moveAnimation = [];
  List<Tween> moveTween = [];
  Offset tweenBegin, tweenEnd;

  AnimationController scaleController;
  Animation scaleAnimation;
  Tween scaleTween;

  AnimationController slideController;
  Animation slideAnimation;
  Tween slideTween;
  Offset slideTweenBegin, slideTweenEnd;

  AnimationController mainSlideController;
  Animation mainSlideAnimation;
  Tween mainSlideTween;
  Offset mainSlideTweenEnd;

  // Timer
  Timer moveTimer;
  Timer mainSlideTimer;
  Timer subSlideUpTimer;

  List<String> realRes = [];
  List<int> realResOrder = [];
  List<String> bgRes = [];
  int subUpResOrder;
  String subUpRes;
  int mainResOrder;
  String mainRes;
  GlobalKey _unitKey;

  DragStartDetails testSlideStart;
  DragUpdateDetails testSlideUpdate;

  bool firstLoad;
  bool animSetPopupVisibility;
  double subUpOpacity;

  // animation settings
  List<String> curveTitle = [];
  List<Curve> curveValue = [];
  List<String> settingsTitle = [];
  List<double> settingsDefault = [];
  List<double> settingsMin = [];
  List<double> settingsMax = [];
  List<int> settingsDivision = [];
  List<double> settingsRealVal = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initParams();
    initAnimation();
    initAnimSettings();

    subUpOpacity = 0.0;
    firstLoad = true;
    animSetPopupVisibility = false;
    mainSlideController.animateTo(0.0,
        duration: Duration(milliseconds: 0), curve: animCurve);
    for (int i = 0; i < moveController.length; i++) {
      moveController[i].animateTo(1.0,
          duration: Duration(milliseconds: 0), curve: animCurve);
    }
    realResOrder = [1, 2, 3, 4, 5];
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    displayWidth = MediaQuery
        .of(context)
        .size
        .width;
    displayHeight = MediaQuery
        .of(context)
        .size
        .height;

    if (displayHeight / displayWidth != 16 / 9) {
      double tmpWidth, tmpHeight;
      tmpHeight = displayWidth * 16 / 9;
      if (tmpHeight > displayHeight) {
        tmpWidth = displayHeight * 9 / 16;
        newWidth = tmpWidth;
        newHeight = displayHeight;
      } else {
        newWidth = displayWidth;
        newHeight = tmpHeight;
      }
    } else {
      newWidth = displayWidth;
      newHeight = displayHeight;
    }

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Container(
              width: newWidth,
              height: newHeight,
              color: Color(0xffe8af30),
              child: Stack(
                children: [
                  mainZone(newWidth, mainRes, bgImages),
                  flowZone(newWidth, realRes, bgRes, subUpRes),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      // margin: EdgeInsets.only(right: displayWidth - newWidth),
                      width: 20,
                      color: Color(0xffe8af30),
                    ),
                  ),
                  touchControl(),
                  animSettingPopup(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: displayWidth - newWidth,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget flowZone(_realWidth, _realRes, _bgRes, _subRes) {
    double wdgWidth = (_realWidth - 40) / 4;

    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          // color: Colors.white,
          child: Stack(
            children: [
              Row(
                children: [
                  thumbnailBgUnit(wdgWidth, _bgRes[1]),
                  thumbnailBgUnit(wdgWidth, _bgRes[2]),
                  thumbnailBgUnit(wdgWidth, _bgRes[3]),
                  thumbnailBgUnit(wdgWidth, _bgRes[4]),
                ],
              ),
              Row(
                children: [
                  thumbnailUnit(wdgWidth, _realRes[1], 0),
                  thumbnailUnit(wdgWidth, _realRes[2], 1),
                  thumbnailUnit(wdgWidth, _realRes[3], 2),
                  thumbnailUnit(wdgWidth, _realRes[4], 3),
                ],
              ),
              Opacity(
                opacity: subUpOpacity,
                child: Container(
                  key: _unitKey,
                  width: wdgWidth,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: ScaleTransition(
                      scale: scaleAnimation,
                      alignment: Alignment.bottomLeft,
                      child: Image.asset(
                        _subRes,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),),
            ],
          ),
        ));
  }

  Widget thumbnailUnit(double _width, String _res, int _index) {
    return SlideTransition(
      position: moveAnimation[_index],
      child: Container(
        width: _width,
        child: Image.asset(
          _res,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  Widget thumbnailBgUnit(double _width, String _res) {
    return Container(
      width: _width,
      child: Image.asset(
        _res,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget mainZone(_realWidth, _mainRes, _bgRes) {
    double wdgWidth = _realWidth - 40;

    return Align(
      alignment: Alignment.topCenter,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 20),
            width: wdgWidth,
            color: Colors.white,
            child: Image.asset(
              _bgRes[0],
              fit: BoxFit.fitWidth,
            ),
          ),
          SlideTransition(
            position: mainSlideAnimation,
            child: Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 20),
              width: wdgWidth,
              color: Colors.white,
              child: Image.asset(
                _mainRes,
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget touchControl() {
    return GestureDetector(
      child: Container(
        height: newHeight,
        width: newWidth,
        color: Colors.transparent,
      ),
      onHorizontalDragStart: (details) {
        testSlideStart = details;
      },
      onHorizontalDragUpdate: (details) {
        testSlideUpdate = details;
      },
      onHorizontalDragEnd: (details) {
        double dy = testSlideUpdate.globalPosition.dy -
            testSlideStart.globalPosition.dy;

        if (dy > 500) {
          setState(() {
            animSetPopupVisibility = true;
          });
        }
      },
    );
  }

  Widget animSettingPopup() {
    return Visibility(
        visible: animSetPopupVisibility,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            color: Colors.white.withOpacity(0.9),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'Animation Settings',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Animation Curves',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CurveSelect(0),
                        CurveSelect(1),
                        CurveSelect(2),
                        CurveSelect(3),
                      ],
                    ),

                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Animation Time',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                            alignment: Alignment.topLeft,
                            color: Colors.grey.withOpacity(0.5),
                            child: Text(
                              'Reset',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: resetAnimTime,
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              SizedBox(
                                height: 1,
                                child: Container(
                                  color: Colors.grey,
                                ),
                              ),
                          scrollDirection: Axis.vertical,
                          itemCount: settingsTitle.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(top: 10),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        color:
                                        Colors.deepPurple.withOpacity(0.5),
                                        child: Text(
                                          settingsTitle[index],
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            height: 1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 100,
                                        color: Colors.yellow.withOpacity(0.5),
                                        child: Text(
                                          settingsRealVal[index].toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            height: 1,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    //width: 300,
                                    child: Slider(
                                      value: settingsRealVal[index],
                                      min: settingsMin[index],
                                      max: settingsMax[index],
                                      divisions: settingsDivision[index],
                                      label: settingsRealVal[index]
                                          .round()
                                          .toString(),
                                      onChanged: (double value) {
                                        setState(() {
                                          settingsRealVal[index] = value;

                                          if (index == 0) {
                                            animTime =
                                                settingsRealVal[index].floor();
                                            int animTimeTmp =
                                            (animTime / 4).floor();

                                            mainSlideController.duration =
                                                Duration(
                                                    milliseconds: animTime);
                                            slideController.duration = Duration(
                                                milliseconds: animTime);
                                            scaleController.duration = Duration(
                                                milliseconds: animTime);
                                            for (int i = 0;
                                            i < moveController.length;
                                            i++) {
                                              moveController[i].duration =
                                                  Duration(
                                                      milliseconds:
                                                      animTimeTmp);
                                            }
                                          } else if (index == 1) {
                                            animDuration =
                                                settingsRealVal[index].floor();
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      width: 20,
                      height: 20,
                      color: Colors.black.withOpacity(0.1),
                      child: Text(
                        'X',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        animSetPopupVisibility = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget CurveSelect(int _index,) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(right: 0, top: 10),
        color: (animCurve == curveValue[_index])
            ? Colors.red.withOpacity(0.5)
            : Colors.grey.withOpacity(0.5),
        child: Text(
          curveTitle[_index],
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            height: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          animCurve = curveValue[_index];

          mainSlideAnimation = mainSlideTween.animate(CurvedAnimation(
            parent: mainSlideController,
            curve: animCurve,
          ));
          scaleAnimation = scaleTween.animate(CurvedAnimation(
            parent: scaleController,
            curve: animCurve,
          ));
          slideAnimation = slideTween.animate(CurvedAnimation(
            parent: slideController,
            curve: animCurve,
          ));
          for (int i = 0; i < moveAnimation.length; i++) {
            moveAnimation[i] = moveTween[i].animate(CurvedAnimation(
              parent: moveController[i],
              curve: animCurve,
            ));
          }
        });
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    for (int i = 0; i < 4; i++) {
      moveController[i].dispose();
    }
    scaleController.dispose();
    slideController.dispose();
    mainSlideController.dispose();

    if (moveTimer != null) moveTimer.cancel();
    if (mainSlideTimer != null) mainSlideTimer.cancel();
    if (subSlideUpTimer != null) subSlideUpTimer.cancel();

    super.dispose();
  }

  void initAnimation() {
    int animCount = 4;
    tweenBegin = Offset(1, 0);
    tweenEnd = Offset.zero;
    animCurve = DefineData.curveEase;
    animTime = DefineData.animTimeDefault;
    animDuration = DefineData.animDurationDefault;

    int animTimeTmp = (animTime / 4).floor();

    moveController.length = animCount;
    moveTween.length = animCount;
    moveAnimation.length = animCount;

    for (int i = 0; i < animCount; i++) {
      moveController[i] = AnimationController(
          duration: Duration(milliseconds: animTimeTmp), vsync: this);
      moveTween[i] = Tween<Offset>(begin: tweenBegin, end: tweenEnd);
      moveAnimation[i] = moveTween[i].animate(CurvedAnimation(
        parent: moveController[i],
        curve: animCurve,
      ));
    }

    for (int i = 0; i < moveAnimation.length; i++) {
      moveAnimation[i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (!firstLoad) {
            moveTimer = new Timer(Duration(milliseconds: animDuration), () {

              if (i == moveAnimation.length - 1 && realResOrder[i] == 3) {
                stopAnimation();
              } else {
                if (i < moveAnimation.length - 1) {
                  moveController[i + 1].forward(from: 0);
                } else {
                  for (int i = 0; i < realResOrder.length; i++) {
                    if (realResOrder[i] == mainImages.length - 1)
                      realResOrder[i] = 0;
                    else
                      realResOrder[i] = realResOrder[i] + 1;
                  }

                  if (realResOrder[0] == 0)
                    mainResOrder = mainImages.length - 1;
                  else
                    mainResOrder = realResOrder[0] - 1;


                  setState(() {
                    subUpOpacity = 0.0;
                    // mainRes = mainImages[mainResOrder];
                    subUpRes = mainImages[realResOrder[0]];
                    mainRes = resizeMainImages[mainResOrder];
                    // subUpRes = resizeMainImages[realResOrder[0]];
                  });

                  slideController.reset();
                  scaleController.reset();
                  mainSlideController.forward(from: 0);
                }
              }

            });
          }

        }
      });
    }

    // mini unit scale animation
    scaleController = AnimationController(
        duration: Duration(milliseconds: animTime), vsync: this);
    scaleTween = Tween<double>(begin: 1.0, end: 4.0);
    scaleAnimation = scaleTween.animate(CurvedAnimation(
      parent: scaleController,
      curve: animCurve,
    ));

    // mini unit slide animation
    slideTweenBegin = Offset(0, 1);
    slideTweenEnd = Offset(0, 1);
    slideController = AnimationController(
        duration: Duration(milliseconds: animTime), vsync: this);
    slideTween = Tween<Offset>(begin: Offset.zero, end: slideTweenEnd);
    slideAnimation = slideTween.animate(CurvedAnimation(
      parent: slideController,
      curve: animCurve,
    ));

    slideAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        subSlideUpTimer = new Timer(Duration(milliseconds: animDuration), () {
          moveController[0].forward(from: 0);
        });
      }
    });

    //  main slide animation
    mainSlideController = AnimationController(
        duration: Duration(milliseconds: animTime), vsync: this);
    mainSlideTween = Tween<Offset>(begin: Offset.zero, end: Offset(1, 0));
    mainSlideAnimation = mainSlideTween.animate(CurvedAnimation(
      parent: mainSlideController,
      curve: animCurve,
    ));

    mainSlideAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        mainSlideTimer = new Timer(Duration(milliseconds: animDuration), () {
          if (firstLoad) {
            setState(() {
              firstLoad = false;
            });
            mainSlideController.forward(from: 0);
          } else {

            setState(() {
              realRes = getRes(realResOrder);
              subUpOpacity = 1.0;
            });

            for (int i = 0; i < moveController.length; i++) {
              moveController[i].reset();
            }

            double _unitHeight = _getHeight();
            double _ratio =
                -(newHeight - 40 - _unitHeight * 4) / _unitHeight;

            slideTween.end = Offset(0, _ratio);
            slideController.forward(from: 0);
            scaleController.forward(from: 0);
          }
        });
      }
    });
  }

  void initParams() {
    // init bg images
    // bgRes = bgImages;
    bgRes = resizeBgImages;

    // init product images
    int resCount = 5;
    realResOrder = [0, 1, 2, 3, 4];

    realRes.length = resCount;
    realRes = getRes(realResOrder);

    mainResOrder = 0;
    mainRes = mainImages[mainResOrder];
    mainRes = resizeMainImages[mainResOrder];
    subUpResOrder = 1;
    subUpRes = mainImages[subUpResOrder];
    // subUpRes = resizeMainImages[subUpResOrder];

    _unitKey = GlobalKey();
  }

  List<String> getRes(List<int> _order) {
    List<String> _resPath = [];
    _resPath.length = _order.length;
    for (int i = 0; i < _resPath.length; i++) {
      // _resPath[i] = mainImages[_order[i]];
      _resPath[i] = resizeMainImages[_order[i]];
    }

    return _resPath;
  }

  void initAnimSettings() {
    curveTitle = [
      DefineData.curveLinearTitle,
      DefineData.curveEaseTitle,
      DefineData.curveEaseInTitle,
      DefineData.curveEaseOutTitle
    ];
    curveValue = [
      DefineData.curveLinear,
      DefineData.curveEase,
      DefineData.curveEaseIn,
      DefineData.curveEaseOut
    ];

    settingsTitle = [DefineData.animTimeTitle, DefineData.animDurationTitle];
    settingsDefault = [
      DefineData.animTimeDefault.toDouble(),
      DefineData.animDurationDefault.toDouble()
    ];
    settingsMin = [
      DefineData.animTimeMin.toDouble(),
      DefineData.animDurationMin.toDouble()
    ];
    settingsMax = [
      DefineData.animTimeMax.toDouble(),
      DefineData.animDurationMax.toDouble()
    ];
    settingsDivision = [
      ((DefineData.animTimeMax - DefineData.animTimeMin) / 100).floor(),
      ((DefineData.animDurationMax - DefineData.animDurationMin) / 100).floor()
    ];
    settingsRealVal = [
      DefineData.animTimeDefault.toDouble(),
      DefineData.animDurationDefault.toDouble()
    ];
  }

  // Common function
  double _getHeight() {
    final RenderBox renderBoxRed = _unitKey.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size;

    return sizeRed.height;
  }

  void resetAnimTime() {
    setState(() {
      for (int i = 0; i < settingsRealVal.length; i++) {
        settingsRealVal[i] = settingsDefault[i];
      }
    });
    animTime = settingsDefault[0].floor();
    int animTimeTmp = (animTime / 4).floor();

    mainSlideController.duration = Duration(milliseconds: animTime);
    slideController.duration = Duration(milliseconds: animTime);
    scaleController.duration = Duration(milliseconds: animTime);
    for (int i = 0; i < moveController.length; i++) {
      moveController[i].duration = Duration(milliseconds: animTimeTmp);
    }

    animDuration = settingsDefault[1].floor();
  }

  void startAnimation() {

    if (mounted)
      setState(() {
        initParams();
      });

    //initAnimation();
    //initAnimSettings();

    for (int i = 0; i < 4; i++) {
      moveController[i].reset();
    }
    scaleController.reset();
    slideController.reset();
    mainSlideController.reset();

    subUpOpacity = 0.0;
    firstLoad = true;
    mainSlideController.animateTo(0.0,
        duration: Duration(milliseconds: 0), curve: animCurve);
    for (int i = 0; i < moveController.length; i++) {
      moveController[i].animateTo(1.0,
          duration: Duration(milliseconds: 0), curve: animCurve);
    }
    realResOrder = [1, 2, 3, 4, 5];

  }

  void stopAnimation() {
    for (int i = 0; i < 4; i++) {
      moveController[i].stop();
    }
    scaleController.stop();
    slideController.stop();
    mainSlideController.stop();

    if (moveTimer != null) moveTimer.cancel();
    if (mainSlideTimer != null) mainSlideTimer.cancel();
    if (subSlideUpTimer != null) subSlideUpTimer.cancel();

    // startPosterFade();
  }
}
