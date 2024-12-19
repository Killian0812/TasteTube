import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/tabs/address/address_cubit.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/order/address.dart';

part 'payment_page.ext.dart';

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
        body: BlocListener<OrderCubit, OrderState>(
          listener: (context, state) {
            if (state is OrderSuccess) {
              ToastService.showToast(context, state.success, ToastType.success);
              context.read<OrderCubit>().getOrders();
              context.read<CartCubit>().getCart();
              Navigator.pop(context);
            }
            if (state is OrderError) {
              ToastService.showToast(context, state.error, ToastType.warning);
            }
          },
          child: Column(
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
          ),
        ));
  }

  Widget _buildAddressSection() {
    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state is AddressError) {
          ToastService.showToast(context, state.message, ToastType.warning);
        }
        if (state is AddressLoaded) {
          setState(() {
            selectedAddress = state.addresses.first;
          });
        }
        if (state is AddressAdded) {
          setState(() {
            selectedAddress = state.addresses.last;
          });
        }
      },
      builder: (context, state) {
        if (state is AddressLoading) {
          return const Center(child: CircularProgressIndicator());
        }

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
                value: selectedAddress ?? addresses.first,
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
                  if (value == null) {
                    showAddressForm(context);
                  } else {
                    setState(() {
                      selectedAddress = value;
                    });
                  }
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
    return BlocBuilder<CartCubit, CartState>(
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
              BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  return CommonButton(
                    isLoading: state is OrderLoading,
                    onPressed: () {
                      context.read<OrderCubit>().createOrder(
                            selectedItems.map((e) => e.id).toList(),
                            selectedAddress!.id,
                            _selectedPaymentMethod!,
                            _notes,
                          );
                    },
                    text: 'Order',
                  );
                },
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
    return BlocBuilder<CartCubit, CartState>(
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
