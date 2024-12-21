import 'package:flutter/material.dart';

class CommonColor {
  static const Color greyOutTextColor = Color.fromARGB(255, 187, 187, 187);
  static const Color greyOutBgColor = Color.fromRGBO(245, 243, 248, 1);
  static const Color activeTextColor = Colors.white;
  static const Color activeBgColor = Colors.deepPurpleAccent;
}

class OrderColor {
  static Color getColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.amber;
      case 'CONFIRMED':
        return Colors.lightBlue;
      case 'DELIVERY':
        return Colors.lightGreen;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
