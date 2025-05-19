import 'package:flutter/material.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  String? title,
  String? body,
  String leftText = "Cancel",
  String rightText = "Confirm",
  VoidCallback? onTapLeft,
  VoidCallback? onTapRight,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        title: title != null ? Text(title) : null,
        content: body != null ? Text(body) : null,
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: CommonTextStyle.regular,
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
              textStyle: CommonTextStyle.regular,
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

Future<String?> showOrderCancelDialog(
  BuildContext context, {
  String leftText = "Cancel",
  String rightText = "Confirm",
  VoidCallback? onTapLeft,
  VoidCallback? onTapRight,
  bool byCustomer = false,
}) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return _OrderCancelDialog(
        leftText: leftText,
        rightText: rightText,
        onTapLeft: onTapLeft,
        onTapRight: onTapRight,
        byCustomer: byCustomer,
      );
    },
  );
}

class _OrderCancelDialog extends StatefulWidget {
  final String leftText;
  final String rightText;
  final VoidCallback? onTapLeft;
  final VoidCallback? onTapRight;
  final bool byCustomer;

  const _OrderCancelDialog({
    required this.leftText,
    required this.rightText,
    this.onTapLeft,
    this.onTapRight,
    required this.byCustomer,
  });

  @override
  _OrderCancelDialogState createState() => _OrderCancelDialogState();
}

class _OrderCancelDialogState extends State<_OrderCancelDialog> {
  String? _selectedReason;
  final TextEditingController _customReasonController = TextEditingController();
  final List<String> _defaultReasons = [
    'Changed my mind',
    'Found a better option',
    'Order placed by mistake',
    'Delivery time too long',
    'Other',
  ];

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      title: const Text('Cancel Order'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this order?'),
            const SizedBox(height: 16),
            if (widget.byCustomer) ...[
              const Text('Please select a reason:'),
              const SizedBox(height: 8),
              ..._defaultReasons.map((reason) => RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    groupValue: _selectedReason,
                    onChanged: (value) {
                      setState(() {
                        _selectedReason = value;
                      });
                    },
                  )),
              if (_selectedReason == 'Other')
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: TextField(
                    controller: _customReasonController,
                    decoration: const InputDecoration(
                      labelText: 'Enter your reason',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
            ] else ...[
              const SizedBox(height: 8),
              TextField(
                controller: _customReasonController,
                decoration: const InputDecoration(
                  labelText: 'Enter reason (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: CommonTextStyle.regular,
          ),
          child: Text(widget.leftText),
          onPressed: () {
            widget.onTapLeft?.call();
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: CommonTextStyle.regular,
          ),
          child: Text(widget.rightText),
          onPressed: () {
            if (widget.byCustomer) {
              if (_selectedReason == null) {
                ToastService.showToast(
                  context,
                  'Please select a reason',
                  ToastType.warning,
                  duration: const Duration(seconds: 2),
                );
                return;
              }

              String finalReason = _selectedReason == 'Other'
                  ? _customReasonController.text.trim()
                  : _selectedReason!;

              if (_selectedReason == 'Other' && finalReason.isEmpty) {
                ToastService.showToast(
                  context,
                  'Please enter a custom reason',
                  ToastType.warning,
                  duration: const Duration(seconds: 2),
                );
                return;
              }

              widget.onTapRight?.call();
              Navigator.of(context).pop(finalReason);
            } else {
              widget.onTapRight?.call();
              Navigator.of(context).pop(_customReasonController.text.trim());
            }
          },
        ),
      ],
    );
  }
}
