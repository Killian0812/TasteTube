import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/data/product_options.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/utils/currency.util.dart';

class ProductOptionsDialog extends StatefulWidget {
  final Product product;

  const ProductOptionsDialog({super.key, required this.product});

  @override
  State<ProductOptionsDialog> createState() => _ProductOptionsDialogState();
}

class _ProductOptionsDialogState extends State<ProductOptionsDialog> {
  late TextEditingController _controller;
  int quantity = 1;
  String? selectedSize;
  double sizeExtraCost = 0;
  final Set<ToppingOption> selectedToppings = {};

  @override
  void initState() {
    super.initState();
    selectedSize = product.sizes.isEmpty
        ? null
        : product.sizes.firstWhereOrNull((e) => e.extraCost == 0.0)?.name ??
            product.sizes.first.name;
    _controller = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Product get product => widget.product;

  double get totalCost {
    double base = widget.product.cost;
    double toppingCost =
        selectedToppings.fold(0.0, (sum, t) => sum + t.extraCost);
    return (base + sizeExtraCost + toppingCost) * quantity;
  }

  void _setQuantity(int qty) {
    if (qty <= 0) {
      _controller.text = "1";
      quantity = 1;
      if (context.mounted) {
        ToastService.showToast(
            context, "Minimum quantity is 1", ToastType.warning);
      }
    } else {
      quantity = qty;
      _controller.text = qty.toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return AlertDialog(
      title: Text(product.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Size selection
            if (product.sizes.isNotEmpty) ...[
              const Text("Choose size",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AnimatedToggleSwitch.size(
                current: selectedSize,
                values: product.sizes.map((s) => s.name).toList(),
                iconBuilder: (value) => Text(value!),
                onChanged: (val) {
                  final selected =
                      product.sizes.firstWhere((s) => s.name == val);
                  setState(() {
                    selectedSize = val;
                    sizeExtraCost = selected.extraCost;
                  });
                },
                style: ToggleStyle(
                  borderColor: Colors.grey,
                  backgroundColor: Colors.grey.shade300,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorBorderRadius: BorderRadius.circular(8),
                ),
                height: 48,
                spacing: 4,
                animationDuration: const Duration(milliseconds: 200),
              ),
            ],

            // Toppings selection
            if (product.toppings.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text("Choose toppings",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ...product.toppings.map((topping) {
                return CheckboxListTile(
                  title: Text(topping.name),
                  subtitle: Text(CurrencyUtil.amountWithCurrency(
                    topping.extraCost,
                    product.currency,
                  )),
                  value: selectedToppings.contains(topping),
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        selectedToppings.add(topping);
                      } else {
                        selectedToppings.remove(topping);
                      }
                    });
                  },
                );
              }),
            ],

            const SizedBox(height: 12),
            // Quantity input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => _setQuantity(quantity - 1),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      final int? newQty = int.tryParse(value);
                      if (newQty != null) _setQuantity(newQty);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _setQuantity(quantity + 1),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              'Total: ${totalCost.toStringAsFixed(0)} ${product.currency}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final options = ProductOptions(
              quantity: quantity,
              size: selectedSize,
              toppings: selectedToppings.toList(),
            );
            Navigator.of(context).pop(options);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
