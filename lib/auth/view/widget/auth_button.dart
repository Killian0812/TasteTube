import 'package:flutter/material.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/providers.dart';

class AuthButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AuthButton(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeMode = getIt<AppSettings>().getTheme;
    final isDarkMode = themeMode == ThemeMode.dark;

    final buttonColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.grey[600] : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: textColor,
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: borderColor!),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 50),
            Text(
              title,
              style: CommonTextStyle.regular.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
