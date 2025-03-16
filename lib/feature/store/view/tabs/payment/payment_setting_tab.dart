import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/store/data/payment_card.dart';
import 'package:taste_tube/feature/store/view/tabs/payment/payment_setting_cubit.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/providers.dart';

part 'payment_setting_tab.ext.dart';

class PaymentSettingTab extends StatelessWidget {
  const PaymentSettingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<PaymentSettingCubit, PaymentSettingState>(
          listener: (context, state) {
            if (state is PaymentSettingError) {
              ToastService.showToast(context, state.message, ToastType.error);
            }
          },
          builder: (context, state) {
            final cubit = context.read<PaymentSettingCubit>();
            if (state is PaymentSettingLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return RefreshIndicator(
              onRefresh: () => cubit.fetchCards(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Currency',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 10),
                                DropdownButton<String>(
                                  value: state.selectedCurrency,
                                  items: ['USD', 'VND'].map((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      cubit.updateCurrency(newValue);
                                    }
                                  },
                                ),
                              ],
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
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Expires: ${card.expiryDate}'),
                                          if (card.isDefault)
                                            const Text(
                                              'Default',
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: card.isDefault
                                                ? const Icon(Icons.check_circle)
                                                : const Icon(
                                                    Icons.circle_outlined),
                                            onPressed: () {
                                              if (!card.isDefault) {
                                                cubit.setDefaultCard(card.id);
                                              }
                                            },
                                            tooltip: card.isDefault
                                                ? "Using as default"
                                                : "Set as Default",
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_outline),
                                            onPressed: () async {
                                              await _showDeleteConfirmation(
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
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddCardPage.provider(cubit),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.credit_card),
                              label: Text('Add New Card'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, PaymentCard card) async {
    final cubit = context.read<PaymentSettingCubit>();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Card'),
          content: Text(
              'Are you sure you want to remove card ending in ${card.lastFour}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                cubit.removeCard(card.id);
                Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
