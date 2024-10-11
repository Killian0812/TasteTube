import 'package:flutter/material.dart';
import 'package:taste_tube/common/text.dart';

class AuthButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AuthButton(
      {super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, 
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: Colors.grey), 
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 50),
            Text(
              title,
              style: CommonTextStyle.regular,
            ),
          ],
        ),
      ),
    );
  }
}
