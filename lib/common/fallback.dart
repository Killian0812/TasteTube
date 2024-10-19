import 'package:flutter/services.dart';

class Fallback {
  static late Uint8List fallbackImageBytes;

  static Future<void> loadFallbackImageBytes() async {
    final byteData = await rootBundle.load('assets/images/tastetube.png');
    fallbackImageBytes = byteData.buffer.asUint8List();
  }

  static Future<void> prepareFallback() async {
    await loadFallbackImageBytes();
  }
}
