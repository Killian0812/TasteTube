import 'package:flutter/material.dart';
import 'package:taste_tube/common/text.dart';

Future<void> showConfirmDialog(
  BuildContext context, {
  String? title,
  String? body,
  String leftText = "Cancel",
  String rightText = "Confirm",
  VoidCallback? onTapLeft,
  VoidCallback? onTapRight,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        title: title != null ? Text(title) : null,
        content: body != null ? Text(body) : null,
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: CommonTextStyle.regular,
            ),
            child: Text(leftText),
            onPressed: () {
              print("DIALOG: NO");
              if (onTapLeft != null) {
                onTapLeft();
              }
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: CommonTextStyle.regular,
            ),
            child: Text(rightText),
            onPressed: () {
              print("DIALOG: YES");
              if (onTapRight != null) {
                onTapRight();
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
