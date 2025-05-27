import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/feature/store/view/tabs/discount/discount_cubit.dart';
import 'package:taste_tube/global_data/discount/discount.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class DiscountDialog extends StatefulWidget {
  final List<Discount> appliedDiscounts;
  final String shopId;
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
            shopId: shopId,
            onApply: onApply,
          ),
        );
      },
    );
  }

  const DiscountDialog({
    super.key,
    required this.appliedDiscounts,
    required this.shopId,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: promoCodeController,
                decoration: InputDecoration(
                  labelText: 'Promo Code',
                  hintText: 'Enter promo code',
                  suffixIcon: IconButton(
                    onPressed: () {
                      final promoCode = promoCodeController.text.trim();
                      if (promoCode.isNotEmpty) {
                        context
                            .read<DiscountCubit>()
                            .checkCouponDiscount(widget.shopId, promoCode);
                      }
                    },
                    icon: Icon(Icons.add_circle_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Available Discounts:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screenSize.height * 0.3),
                child: Column(
                  children: [
                    ...discounts.map((discount) {
                      final applied = discountSelection[discount.id] ?? false;
                      return CheckboxListTile(
                        title: Text(
                          discount.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            discount.valueType == 'percentage'
                                ? Text(
                                    "Discount: ${discount.value.toString()}%")
                                : Text(
                                    "Discount: ${CurrencyUtil.amountWithCurrency(discount.value, UserDataUtil.getCurrency())}"),
                            if (discount.minOrderAmount != null)
                              Text(
                                  "Min order amount: ${CurrencyUtil.amountWithCurrency(discount.minOrderAmount!, UserDataUtil.getCurrency())}"),
                          ],
                        ),
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
