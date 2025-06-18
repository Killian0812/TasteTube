import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/text.dart';

class OtpTextField extends StatefulWidget {
  final int numberOfFields;
  final Color borderColor;
  final TextStyle textStyle;
  final bool enabled;
  final void Function(String) onSubmit;

  const OtpTextField({
    super.key,
    required this.numberOfFields,
    required this.borderColor,
    this.textStyle = CommonTextStyle.regular,
    this.enabled = true,
    required this.onSubmit,
  });

  @override
  State<OtpTextField> createState() => _OtpTextFieldState();
}

class _OtpTextFieldState extends State<OtpTextField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.numberOfFields,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.numberOfFields,
      (_) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < widget.numberOfFields - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_controllers.every((c) => c.text.length == 1)) {
      final code = _controllers.map((c) => c.text).join();
      widget.onSubmit(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.numberOfFields, (index) {
        return Padding(
          padding: (index == 0) ? EdgeInsets.zero : EdgeInsets.only(left: 12),
          child: SizedBox(
            width: 40,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: widget.textStyle,
              maxLength: 1,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              decoration: InputDecoration(
                counterText: '',
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: widget.borderColor)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: CommonColor.activeBgColor, width: 2)),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (value) => _onChanged(value, index),
            ),
          ),
        );
      }),
    );
  }
}
