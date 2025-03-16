import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/store/view/tabs/payment/payment_setting_cubit.dart';
import 'package:taste_tube/feature/store/view/tabs/payment/payment_setting_tab.ext.dart';

class PaymentSettingTab extends StatelessWidget {
  const PaymentSettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentSettingCubit()..loadInitialData(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<PaymentSettingCubit, PaymentSettingState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Settings',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Currency',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            DropdownButton<String>(
                              value: state.selectedCurrency,
                              isExpanded: true,
                              items: ['USD', 'VND'].map((value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  context
                                      .read<PaymentSettingCubit>()
                                      .updateCurrency(newValue);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Payment Cards',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            if (state.cards.isEmpty)
                              const Text(
                                'No cards added yet',
                                style: TextStyle(color: Colors.grey),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.cards.length,
                                itemBuilder: (context, index) {
                                  final card = state.cards[index];
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: ListTile(
                                      leading: const Icon(Icons.credit_card),
                                      title: Text(
                                          '${card.holderName} - **** ${card.lastFour}'),
                                      subtitle: card.isDefault
                                          ? const Text('Default',
                                              style: TextStyle(
                                                  color: Colors.green))
                                          : null,
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!card.isDefault)
                                            IconButton(
                                              icon:
                                                  const Icon(Icons.star_border),
                                              onPressed: () {
                                                context
                                                    .read<PaymentSettingCubit>()
                                                    .setDefaultCard(card.id);
                                                ToastService.showToast(
                                                  context,
                                                  '${card.holderName} set as default',
                                                  ToastType.success,
                                                );
                                              },
                                              tooltip: 'Set as Default',
                                            ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline),
                                            onPressed: () {
                                              _showDeleteConfirmation(
                                                  context, card);
                                            },
                                            tooltip: 'Remove Card',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: 16),
                            CommonButton(
                              text: 'Add New Card',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddCardPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, PaymentOption card) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Card'),
          content: Text(
              'Are you sure you want to remove ${card.holderName} ending in ${card.lastFour}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<PaymentSettingCubit>().removeCard(card.id);
                Navigator.pop(context);
                ToastService.showToast(
                  context,
                  'Card removed successfully',
                  ToastType.success,
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
