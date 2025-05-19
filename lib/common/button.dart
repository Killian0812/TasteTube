import 'package:flutter/material.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/providers.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';

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
                backgroundColor:
                    isDisabled ? CommonColor.greyOutBgColor : color,
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

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: IconButton(
            onPressed: () async {
              bool? confirmed = await showConfirmDialog(
                context,
                title: context.localizations.confirm_logout_title,
                body: context.localizations.confirm_logout_body,
              );
              if (confirmed != true) {
                return;
              }
              if (context.mounted) {
                final authBloc = getIt<AuthBloc>();
                authBloc.add(LogoutEvent());
              }
            },
            icon: Icon(Icons.logout),
          ),
        ),
      ),
    );
  }
}
