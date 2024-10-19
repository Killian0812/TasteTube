import 'dart:typed_data';

import 'package:flutter/material.dart';

class UploadPage extends StatelessWidget {
  final Uint8List thumbnail; // base64Encode to save in mongoDB
  const UploadPage({super.key, required this.thumbnail});

  @override
  Widget build(BuildContext context) {
    return Center(child: Image.memory(thumbnail));
  }
}
