import 'package:flutter/material.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/text.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final bool isLoading;
  final bool isDisabled;
  final VoidCallback onPressed;

  const CommonButton({
    super.key,
    required this.text,
    this.textColor = CommonColor.activeTextColor,
    this.color = CommonColor.activeBgColor,
    this.isLoading = false,
    this.isDisabled = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: (isLoading || isDisabled) ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled ? CommonColor.greyOutBgColor : color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: CommonTextStyle.bold.copyWith(color: textColor),
                  ),
                  if (isLoading) ...[
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: isDisabled
                            ? CommonColor.greyOutTextColor
                            : textColor,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
