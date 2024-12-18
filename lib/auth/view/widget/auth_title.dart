import 'package:flutter/material.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/text.dart';

class AuthTitle extends StatelessWidget {
  final String title;
  const AuthTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30.0),
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
            ),
            CommonTextWidget.tasteTube,
          ],
        ),
        Image.asset(AssetPath.tastetubeInverted, height: 110),
      ]),
    );
  }
}
