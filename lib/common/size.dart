import 'package:flutter/material.dart';

class CommonSize {
  static Size screenSize = Size.zero;

  static initScreenSize(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
  }

  static double appBarHeight = AppBar().preferredSize.height;
  static double bottomNavBarHeight = kBottomNavigationBarHeight;
}
