import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taste_tube/common/text.dart';

enum ToastType {
  none,
  info,
  success,
  warning,
  error,
}

class ToastService {
  static final FToast _fToast = FToast();

  static void hideToast() {
    _fToast.removeCustomToast();
  }

  static void showToast(
    BuildContext context,
    String message,
    ToastType type, {
    VoidCallback? onTap,
  }) {
    hideToast();
    _fToast.init(context);

    Color backgroundColor;
    IconData icon;
    switch (type) {
      case ToastType.info:
        backgroundColor = Colors.blueAccent.withOpacity(0.8);
        icon = Icons.info_outline;
        break;
      case ToastType.success:
        backgroundColor = Colors.green.withOpacity(0.8);
        icon = Icons.check_circle_outline;
        break;
      case ToastType.warning:
        backgroundColor = Colors.orange.withOpacity(0.8);
        icon = Icons.warning_amber_outlined;
        break;
      case ToastType.error:
        backgroundColor = Colors.redAccent.withOpacity(0.8);
        icon = Icons.error_outline;
        break;
      default:
        backgroundColor = Colors.blueGrey.withOpacity(0.8);
        icon = Icons.notifications_active_outlined;
        break;
    }

    Widget toast = GestureDetector(
      onTap: onTap,
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          hideToast(); // Remove the toast on swipe up
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: backgroundColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: CommonTextStyleContrast.regular,
              ),
            ),
          ],
        ),
      ),
    );

    _fToast.showToast(
      child: toast,
      toastDuration: const Duration(seconds: 3),
      gravity: ToastGravity.TOP,
    );
  }
}
