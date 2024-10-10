import 'package:flutter/material.dart';

class CustomTextStyle {
  static const TextStyle regular = TextStyle(
    fontFamily: "Ganh",
    fontStyle: FontStyle.normal,
    color: Colors.black,
    fontSize: 16.0,
  );
  static const TextStyle bold = TextStyle(
    fontFamily: "Ganh",
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontSize: 16.0,
  );
  static const TextStyle italic = TextStyle(
    fontFamily: "Ganh",
    fontStyle: FontStyle.italic,
    color: Colors.black,
    fontSize: 16.0,
  );
  static const TextStyle thin = TextStyle(
    fontFamily: "Ganh",
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w100,
    color: Colors.black,
    fontSize: 16.0,
  );
  static const TextStyle thinItalic = TextStyle(
    fontFamily: "Ganh",
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w100,
    color: Colors.black,
    fontSize: 16.0,
  );
  static TextStyle boldItalic = italic.copyWith(fontWeight: FontWeight.bold);
}

class CustomTextWidget {
  static Widget tasteTube = const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "Taste",
        style: TextStyle(
          fontFamily: "Ganh",
          fontSize: 50,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        "Tube",
        style: TextStyle(
            fontFamily: "Ganh",
            fontSize: 50,
            fontWeight: FontWeight.bold,
            color: Colors.red),
      ),
    ],
  );

  static Text loginPageMessage = const Text(
    "Continue to our video-sharing platform and discover amazing restaurants! Follow your favorites, explore their unique offerings, and dive into delicious video content.",
    style: CustomTextStyle.thinItalic,
  );

  static Text registerPageMessage = const Text(
    "Sign up now and embark on a delightful culinary journey that will tantalize your taste buds and inspire your next meal!",
    style: CustomTextStyle.thinItalic,
  );
}
