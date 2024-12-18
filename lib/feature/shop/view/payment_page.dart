import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/feature/shop/view/tabs/address/address_cubit.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/order/address.dart';

double deliveryFee = 15000; // Example only
double discount = 10000;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  static Widget provider() => MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) => AddressCubit()..fetchAddresses(),
        ),
      ], child: const PaymentPage());

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _selectedPaymentMethod = 'COD';
  String _notes = '';
  Address? selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body:
            BlocBuilder<OrderCubit, OrderState>(builder: (context, orderState) {
          if (orderState is OrderLoading) {
            return const Center(child: CommonLoadingIndicator.regular);
          }
          if (orderState is OrderError) {
            return const Center(child: Text('Something went wrong!'));
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAddressSection(),
                      const _OrderSummarySection(),
                      _buildPaymentMethodSection(),
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),
              _buildBottomOrderSection(),
            ],
          );
        }));
  }

  Widget _buildAddressSection() {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        final addresses = state.addresses;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Delivery Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              DropdownButton<dynamic>(
                isExpanded: true,
                value: selectedAddress,
                items: [
                  ...addresses.map((Address address) {
                    return DropdownMenuItem<Address>(
                      value: address,
                      child: Text('${address.name}, ${address.value}'),
                    );
                  }),
                  const DropdownMenuItem(
                      value: null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_location_alt_outlined),
                          SizedBox(width: 10),
                          Text('Add new address'),
                        ],
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedAddress = value;
                  });
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          RadioListTile<String>(
            title: Row(
              children: [
                Image.asset(AssetPath.cod, width: 24, height: 24),
                const SizedBox(width: 10),
                const Text('Cash on Delivery (COD)'),
              ],
            ),
            value: 'COD',
            groupValue: _selectedPaymentMethod,
            onChanged: (String? value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
          RadioListTile<String>(
            title: Row(
              children: [
                Image.asset(AssetPath.vnpay, width: 24, height: 24),
                const SizedBox(width: 10),
                const Text('VNPAY'),
              ],
            ),
            value: 'VNPAY',
            groupValue: _selectedPaymentMethod,
            onChanged: (String? value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
          RadioListTile<String>(
            title: Row(
              children: [
                Image.asset(AssetPath.zalopay, width: 24, height: 24),
                const SizedBox(width: 10),
                const Text('ZaloPay'),
              ],
            ),
            value: 'ZaloPay',
            groupValue: _selectedPaymentMethod,
            onChanged: (String? value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) => _notes = value,
        decoration: InputDecoration(
          alignLabelWithHint: true,
          labelText: 'Order notes (optional)',
          helperMaxLines: 3,
          hintText: "Write some notes for your order",
          hintStyle: CommonTextStyle.italic.copyWith(color: Colors.grey),
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  Widget _buildBottomOrderSection() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final selectedItems = state.cart.items
            .where((item) => state.selectedItems.contains(item.id))
            .toList();
        double total = selectedItems.fold(
            0, (sum, item) => sum + item.quantity * item.product.cost);
        double finalAmount = total + deliveryFee - discount;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Final Payment: ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                      '${finalAmount.toStringAsFixed(2)} ${selectedItems.first.currency}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              CommonButton(
                onPressed: () {
                  // Create order
                  print(_notes);
                },
                text: 'Order',
              )
            ],
          ),
        );
      },
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  const _OrderSummarySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final selectedItems = state.cart.items
            .where((item) => state.selectedItems.contains(item.id))
            .toList();
        double total = selectedItems.fold(
            0, (sum, item) => sum + item.quantity * item.product.cost);
        String currency = selectedItems.first.currency;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...selectedItems.map((item) => Row(
                    children: [
                      Image.network(item.product.images[0].url,
                          width: 50, height: 50),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            '${item.product.name} x ${item.quantity}: ${item.quantity * item.product.cost} ${item.product.currency}'),
                      ),
                    ],
                  )),
              const Divider(),
              Text('Subtotal: ${total.toStringAsFixed(2)} $currency'),
              Text(
                'Delivery Fee: ${deliveryFee.toStringAsFixed(2)} $currency',
                style: TextStyle(color: Colors.red[200]),
              ),
              Text(
                'Discount: ${discount.toStringAsFixed(2)} $currency',
                style: TextStyle(color: Colors.green[600]),
              ),
              const SizedBox(height: 10),
              Text(
                  'Total: ${(total + deliveryFee - discount).toStringAsFixed(2)} $currency',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
