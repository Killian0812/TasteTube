import 'package:flutter/material.dart';
import 'package:taste_tube/common/toast.dart';

class QuantityInputDialog extends StatefulWidget {
  const QuantityInputDialog({super.key});

  @override
  State<QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<QuantityInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuantity(int qty) {
    if (qty <= 0) {
      _controller.text = "1";
      if (context.mounted) {
        ToastService.showToast(
            context, "Minimum quantity is 1", ToastType.warning);
        return;
      }
    }
    _controller.text = qty.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select quantity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  _setQuantity(int.parse(_controller.text) - 1);
                },
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final int? newQuantity = int.tryParse(value);
                    if (newQuantity != null) {
                      _setQuantity(newQuantity);
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _setQuantity(int.parse(_controller.text) + 1);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close without returning a value
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(
                int.parse(_controller.text)); // Return the selected quantity
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
