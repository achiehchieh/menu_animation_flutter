import 'package:flutter/animation.dart';

class DefineData {

  // animation Curves Tile
  static String curveLinearTitle = 'Linear';
  static String curveEaseTitle = 'Ease';
  static String curveEaseInTitle = 'EaseIn';
  static String curveEaseOutTitle = 'EaseOut';

  // animation Curves
  static Curve curveLinear = Curves.linear;
  static Curve curveEase = Curves.ease;
  static Curve curveEaseIn = Curves.easeIn;
  static Curve curveEaseOut = Curves.easeOut;

  // animation time title
  static final animTimeTitle = 'Animation Time';
  static final animDurationTitle = 'Animation Duration';

  // animation time default value
  static final animTimeDefault = 400;
  static final animDurationDefault = 1500;

  // animation time min value
  static final animTimeMin = 0;
  static final animDurationMin = 0;

  // animation time max value
  static final animTimeMax = 800;
  static final animDurationMax = 3000;


}