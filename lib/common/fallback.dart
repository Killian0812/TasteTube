import 'package:flutter/services.dart';
import 'package:taste_tube/common/constant.dart';

class Fallback {
  static late Uint8List fallbackImageBytes;

  static Future<void> loadFallbackImageBytes() async {
    final byteData = await rootBundle.load(AssetPath.tastetube);
    fallbackImageBytes = byteData.buffer.asUint8List();
  }

  static Future<void> prepareFallback() async {
    await loadFallbackImageBytes();
  }
}
