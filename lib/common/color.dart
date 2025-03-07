import 'package:flutter/material.dart';

class CommonColor {
  static const Color greyOutTextColor = Color.fromARGB(255, 187, 187, 187);
  static const Color greyOutBgColor = Color.fromRGBO(245, 243, 248, 1);
  static const Color activeTextColor = Colors.white;
  static const Color activeBgColor = Colors.deepPurpleAccent;
  static const Color darkGrey = Color.fromARGB(255, 30, 30, 30);
  static const Color lightGrey = Color(0xFFF5F5F5);
}

class OrderColor {
  static Color getColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.amber;
      case 'CONFIRMED':
        return Colors.lightBlue;
      case 'DELIVERY':
        return Colors.deepPurple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
