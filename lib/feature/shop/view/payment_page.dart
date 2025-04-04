import 'package:collection/collection.dart';
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
import 'package:taste_tube/global_data/order/cart.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/utils/location/location.util.dart';
import 'package:taste_tube/utils/user_data.util.dart';
import 'package:url_launcher/url_launcher_string.dart';

final currency = UserDataUtil.getCurrency();

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
              final cartState = context.read<CartCubit>().state;
              final selectedItems = cartState.cart.items
                  .where((item) => cartState.selectedItems.contains(item.id))
                  .toList();

              context.read<OrderCubit>().createOrder(
                    selectedItems.map((e) => e.id).toList(),
                    selectedAddress!.id!,
                    _selectedPaymentMethod.name,
                    _notes,
                    state.pid,
                    cartState.orderSummary,
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

        if (addresses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Address',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    pickLocationThenShowAddressForm(context);
                  },
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add new address'),
                ),
              ],
            ),
          );
        }

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
      builder: (context, cartState) {
        final grandTotal = cartState.orderSummary
            .fold(0.0, (sum, summary) => sum + (summary.totalAmount ?? 0.0));
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
                    'Total: ${grandTotal.toStringAsFixed(2)} $currency',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  return CommonButton(
                    isDisabled:
                        _selectedPaymentMethod == PaymentMethod.ZALOPAY ||
                            cartState.orderSummary.isEmpty ||
                            cartState.orderSummary
                                .any((summary) => summary.deliveryFee == null),
                    isLoading: state is OrderLoading,
                    onPressed: () {
                      context.read<PaymentCubit>().createPayment(
                          _selectedPaymentMethod, grandTotal, currency);
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

        if (selectedItems.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No items selected'),
          );
        }

        // Group items by shop
        final Map<String, List<CartItem>> itemsByShop = {};
        for (var item in selectedItems) {
          final shopId = item.product.userId;
          if (!itemsByShop.containsKey(shopId)) {
            itemsByShop[shopId] = [];
          }
          itemsByShop[shopId]!.add(item);
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Cart items
              ...itemsByShop.entries.map((entry) {
                final shopId = entry.key;
                final shopItems = entry.value;
                final orderSummary = state.orderSummary
                    .firstWhereOrNull((summary) => summary.shopId == shopId);
                final shopImage = shopItems.first.product.userImage;
                final shopName = shopItems.first.product.username;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Shop header
                    ExpansionTile(
                      initiallyExpanded: true,
                      childrenPadding:
                          const EdgeInsets.symmetric(horizontal: 30),
                      title: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(shopImage),
                            radius: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              shopName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Items for this shop
                      children: [
                        ...shopItems.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Image.network(
                                    item.product.images[0].url,
                                    width: 50,
                                    height: 50,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${item.product.name} x ${item.quantity}: ${(item.quantity * item.product.cost).toStringAsFixed(2)} ${item.product.currency}',
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),

                    // Summary for this shop
                    if (orderSummary != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 30),
                        child: orderSummary.message == null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Delivery Fee: ${orderSummary.deliveryFee!.toStringAsFixed(2)} $currency',
                                    style: TextStyle(color: Colors.blue[200]),
                                  ),
                                  Text(
                                    'Discount: ${orderSummary.discountAmount!.toStringAsFixed(2)} $currency',
                                    style: TextStyle(color: Colors.green[600]),
                                  ),
                                  Text(
                                    'Subtotal: ${orderSummary.totalAmount!.toStringAsFixed(2)} $currency',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            : Text(
                                orderSummary.message!,
                                style: TextStyle(color: Colors.red[200]),
                              ),
                      ),
                    const Divider(),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
