import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/feature/store/view/tabs/discount/discount_cubit.dart';
import 'package:taste_tube/global_data/discount/discount.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class DiscountDialog extends StatefulWidget {
  final List<Discount> appliedDiscounts;
  final void Function(List<Discount> selectedDiscounts) onApply;

  static Future<void> show(
    BuildContext context,
    List<Discount> appliedDiscounts,
    String shopId,
    void Function(List<Discount> selectedDiscounts) onApply,
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return BlocProvider(
          create: (context) =>
              DiscountCubit()..fetchAvailableDiscountsForCustomer(shopId),
          child: DiscountDialog(
            appliedDiscounts: appliedDiscounts,
            onApply: onApply,
          ),
        );
      },
    );
  }

  const DiscountDialog({
    super.key,
    required this.appliedDiscounts,
    required this.onApply,
  });

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  late TextEditingController promoCodeController;
  late Map<String, bool> discountSelection;

  @override
  void initState() {
    super.initState();
    promoCodeController = TextEditingController();
    discountSelection = {
      for (var discount in widget.appliedDiscounts) discount.id: true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscountCubit, DiscountState>(
      builder: (context, state) {
        final discounts = [
          ...widget.appliedDiscounts,
          ...state.discounts
              .where((e) => !widget.appliedDiscounts.any((a) => a.id == e.id)),
        ];
        return AlertDialog(
          title: Text('Apply Discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: promoCodeController,
                decoration: InputDecoration(
                  labelText: 'Promo Code',
                  hintText: 'Enter promo code',
                  suffixIcon: TextButton(
                    onPressed: () {
                      final promoCode = promoCodeController.text.trim();
                      if (promoCode.isNotEmpty) {
                        // TODO: Handle promo code application
                      }
                    },
                    child: Text('Apply'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Available Discounts:'),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: CommonSize.screenSize.height * 0.3),
                child: Column(
                  children: [
                    ...discounts.map((discount) {
                      final applied = discountSelection[discount.id] ?? false;
                      return CheckboxListTile(
                        title: Text(discount.name),
                        subtitle: discount.valueType == 'percentage'
                            ? Text("${discount.value.toString()}%")
                            : Text(CurrencyUtil.amountWithCurrency(
                                discount.value, UserDataUtil.getCurrency())),
                        value: applied,
                        onChanged: (value) {
                          setState(() {
                            discountSelection[discount.id] = value ?? false;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final selectedDiscounts = discounts
                    .where((discount) => discountSelection[discount.id] == true)
                    .toList();

                // Call the onApply callback with selected discounts
                widget.onApply(selectedDiscounts);

                Navigator.pop(context);
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
