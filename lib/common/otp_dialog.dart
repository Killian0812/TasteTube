import 'dart:async';
import 'package:flutter/material.dart';
import 'otp_textfield.dart';

class OtpConfirmDialog extends StatefulWidget {
  final int resendAfterSeconds;
  final void Function(String otp) onSubmit;
  final VoidCallback onResend;

  const OtpConfirmDialog({
    super.key,
    required this.resendAfterSeconds,
    required this.onSubmit,
    required this.onResend,
  });

  @override
  State<OtpConfirmDialog> createState() => _OtpConfirmDialogState();
}

class _OtpConfirmDialogState extends State<OtpConfirmDialog> {
  late int _secondsLeft;
  Timer? _timer;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = widget.resendAfterSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleResend() {
    widget.onResend();
    _startTimer();
  }

  void _handleSubmit() {
    widget.onSubmit(_otp);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter OTP'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OtpTextField(
            numberOfFields: 6,
            borderColor: Theme.of(context).primaryColor,
            onSubmit: (String verificationCode) {
              setState(() {
                _otp = verificationCode;
              });
            },
          ),
          const SizedBox(height: 16),
          _secondsLeft > 0
              ? Text('Resend OTP in $_secondsLeft seconds')
              : TextButton(
                  onPressed: _handleResend,
                  child: const Text('Resend OTP'),
                ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _otp.isNotEmpty ? _handleSubmit : null,
          child: const Text('Submit'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
