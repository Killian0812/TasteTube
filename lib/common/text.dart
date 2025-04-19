import 'package:flutter/material.dart';
import 'package:taste_tube/common/color.dart';

class CommonTextStyle {
  static const TextStyle regular = TextStyle(
    fontFamily: 'Ganh',
    fontStyle: FontStyle.normal,
    fontSize: 16.0,
  );
  static const TextStyle bold = TextStyle(
    fontFamily: 'Ganh',
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );
  static const TextStyle italic = TextStyle(
    fontFamily: 'Ganh',
    fontStyle: FontStyle.italic,
    fontSize: 16.0,
  );
  static const TextStyle thin = TextStyle(
    fontFamily: 'Ganh',
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w100,
    fontSize: 16.0,
  );
  static const TextStyle thinItalic = TextStyle(
    fontFamily: 'Ganh',
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w100,
    fontSize: 16.0,
  );
  static const TextStyle boldItalic = TextStyle(
    fontFamily: 'Ganh',
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.bold,
    fontSize: 16.0,
  );
}

final lightTextTheme =
    ThemeData.light().textTheme.apply(fontFamily: 'Ganh').copyWith(
          bodyMedium: const TextStyle(
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
          bodyLarge: const TextStyle(
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
          titleLarge: const TextStyle(
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
          // Add other styles if needed
        );

final darkTextTheme =
    ThemeData.dark().textTheme.apply(fontFamily: 'Ganh').copyWith(
          bodyMedium: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
          bodyLarge: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
          titleLarge: const TextStyle(
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
          // Add other styles if needed
        );

class CommonTextWidget {
  static Widget tasteTube = const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "Taste",
        style: TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        "Tube",
        style: TextStyle(
          fontSize: 50,
          fontWeight: FontWeight.bold,
          color: CommonColor.activeBgColor,
        ),
      ),
    ],
  );

  static Widget tasteTubeMini = const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        "Taste",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        "Tube",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: CommonColor.activeBgColor,
        ),
      ),
    ],
  );

  static Text loginPageMessage = const Text(
    "Continue to our video-sharing platform and discover amazing F&B products! Follow your favorites, explore unique offerings, and dive into delicious video content.",
    style: CommonTextStyle.thinItalic,
  );

  static Text registerPageMessage = const Text(
    "Sign up now and embark on a delightful culinary journey that will tantalize your taste buds and inspire your next meal!",
    style: CommonTextStyle.thinItalic,
  );
}
