import 'package:flutter/material.dart';

class CommonSize {
  static Size screenSize = Size.zero;

  static initScreenSize(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
  }
}
