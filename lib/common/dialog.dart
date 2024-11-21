import 'package:flutter/material.dart';
import 'package:taste_tube/common/text.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  String? title,
  String? body,
  String leftText = "Cancel",
  String rightText = "Confirm",
  bool contrast = false,
  VoidCallback? onTapLeft,
  VoidCallback? onTapRight,
}) {
  final actionTextStyle =
      contrast ? CommonTextStyleContrast.regular : CommonTextStyle.regular;
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: contrast ? Colors.black87 : null,
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        title: title != null
            ? Text(
                title,
                style: TextStyle(color: contrast ? Colors.white : null),
              )
            : null,
        content: body != null
            ? Text(
                body,
                style: TextStyle(color: contrast ? Colors.white : null),
              )
            : null,
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: actionTextStyle,
            ),
            child: Text(leftText),
            onPressed: () {
              if (onTapLeft != null) {
                onTapLeft();
              }
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: actionTextStyle,
            ),
            child: Text(rightText),
            onPressed: () {
              if (onTapRight != null) {
                onTapRight();
              }
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}
