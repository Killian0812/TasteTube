import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/payment/data/payment_data.dart';
import 'package:taste_tube/feature/payment/view/payment_cubit.dart';
import 'package:taste_tube/feature/shop/view/online_payment_page.dart';
import 'package:taste_tube/feature/shop/view/tabs/address/address_cubit.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/utils/location/location.util.dart';
import 'package:url_launcher/url_launcher_string.dart';

double deliveryFee = 0; // Example only
double discount = 0;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  static Widget provider() => MultiBlocProvider(providers: [
        BlocProvider(
          create: (context) => AddressCubit()..fetchAddresses(),
        ),
        BlocProvider(
          create: (context) => PaymentCubit(),
        ),
      ], child: const PaymentPage());

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.COD;
  String _notes = '';
  Address? selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
          centerTitle: true,
        ),
        body: BlocListener<PaymentCubit, PaymentState>(
          listener: (context, state) async {
            if (state is PaymentSuccess) {
              final orderState = context.read<CartCubit>().state;
              final selectedItems = orderState.cart.items
                  .where((item) => orderState.selectedItems.contains(item.id))
                  .toList();

              context.read<OrderCubit>().createOrder(
                    selectedItems.map((e) => e.id).toList(),
                    selectedAddress!.id!,
                    _selectedPaymentMethod.name,
                    _notes,
                    state.pid,
                  );
            }
            if (state is PaymentUrlReady) {
              final url = state.url;
              if (kIsWeb) {
                await launchUrlString(url,
                    mode: LaunchMode.externalApplication);
                return;
              }
              final cubit = context.read<PaymentCubit>();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      OnlinePaymentPage(cubit: cubit, url: url)));
            }
          },
          child: BlocListener<OrderCubit, OrderState>(
            listener: (context, state) {
              if (state is OrderSuccess) {
                ToastService.showToast(
                    context, state.success, ToastType.success);
                getIt<OrderCubit>().getOrders();
                getIt<CartCubit>().getCart();
                Navigator.pop(context);
                return;
              }
              if (state is OrderError) {
                ToastService.showToast(context, state.error, ToastType.warning);
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
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
          ),
        ));
  }

  Widget _buildAddressSection() {
    final cartCubit = context.read<CartCubit>();
    return BlocConsumer<AddressCubit, AddressState>(
      listener: (context, state) {
        if (state is AddressError) {
          ToastService.showToast(context, state.message, ToastType.warning);
        }
        if (state is AddressLoaded) {
          setState(() {
            selectedAddress = state.addresses.firstOrNull;
          });
          cartCubit.updateOrderSummary(selectedAddress);
        }
        if (state is AddressAdded) {
          setState(() {
            selectedAddress = state.addresses.last;
          });
          cartCubit.updateOrderSummary(selectedAddress);
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
                    pickLocationThenShowAddressForm(context);
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
          ...PaymentMethod.values.map(
            (e) => RadioListTile<PaymentMethod>(
              title: Row(
                children: [
                  Image.asset(e.assetPath, width: 24, height: 24),
                  const SizedBox(width: 10),
                  Text(e.displayName),
                ],
              ),
              value: e,
              groupValue: _selectedPaymentMethod,
              onChanged: (PaymentMethod? value) {
                if (value == null) return;
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
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
        String currency = selectedItems.first.currency;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    isDisabled: _selectedPaymentMethod ==
                        PaymentMethod.ZALOPAY, // Temporary disable
                    isLoading: state is OrderLoading,
                    onPressed: () {
                      context.read<PaymentCubit>().createPayment(
                          _selectedPaymentMethod, finalAmount, currency);
                      return;
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
