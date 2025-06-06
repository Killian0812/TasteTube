import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/tabs/order/customer_order_detail_page.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_product_page.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/datetime.util.dart';

class CustomerOrderTab extends StatelessWidget {
  const CustomerOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderError) {
          ToastService.showToast(context, state.error, ToastType.warning);
        }
        if (state is OrderSuccess) {
          ToastService.showToast(context, state.success, ToastType.warning);
        }
      },
      builder: (context, state) {
        return DefaultTabController(
          length: OrderStatus.values.length,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: OrderStatus.values.map((status) {
                  return Tab(text: status.name);
                }).toList(),
              ),
              Expanded(
                child: TabBarView(
                  children: OrderStatus.values.map((status) {
                    final statusOrders = state.orders
                        .where((order) => order.status == status.name)
                        .toList();
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<OrderCubit>().getOrders();
                      },
                      child: statusOrders.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 50),
                                Center(
                                    child: Text('No orders in ${status.name}')),
                              ],
                            )
                          : ListView.builder(
                              itemCount: statusOrders.length,
                              itemBuilder: (context, index) {
                                final order = statusOrders[index];
                                return _OrderCard(order: order);
                              },
                            ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final currency = order.items.first.product.currency;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => CustomerOrderDetailPage.provider(order.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  final product = item.product;
                  return ListTile(
                    leading: Image.network(
                      product.images[0].url,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.name),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.size != null)
                          Text(
                              'Size: ${item.size!} - ${CurrencyUtil.amountWithCurrency(item.product.getSizeCostWithBaseIncluded(item.size!), product.currency)}'),
                        if (item.toppings.isNotEmpty)
                          Text(
                            'Topping: ${item.toppings.map((e) => e.name).join(', ')} - ${CurrencyUtil.amountWithCurrency(item.toppings.map((e) => e.extraCost).sum, product.currency)}',
                          ),
                        Text(
                            'Subtotal: ${CurrencyUtil.amountWithCurrency(item.cost ?? product.cost, product.currency)}')
                      ],
                    ),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                              builder: (context) =>
                                  SingleShopProductPage(product: product)));
                    },
                  );
                },
              ),
              const Divider(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 4),
                  Text(DateTimeUtil.dateTimeHHmmddMMyyyy(order.createdAt)),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Status: ',
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: order.status,
                      style: TextStyle(
                        color: OrderColor.getColor(order.status),
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Payment Method: ',
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(text: order.paymentMethod),
                    if (order.paid) ...[
                      const TextSpan(text: ' - '),
                      const TextSpan(
                        text: 'Paid',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${CurrencyUtil.amountWithCurrency(order.total, currency)}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  'Delivery fee: +${CurrencyUtil.amountWithCurrency(order.deliveryFee, currency)}',
                ),
              ),
              ExpansionTile(
                minTileHeight: 20,
                title: Text(
                  'Discounts: -${CurrencyUtil.amountWithCurrency(order.discounts.fold(0.0, (sum, appliedDiscount) => sum + appliedDiscount.amount), currency)}',
                  style: const TextStyle(fontSize: 14),
                ),
                childrenPadding: const EdgeInsets.only(left: 16.0),
                children: [
                  ...order.discounts.map((appliedDiscount) {
                    return ListTile(
                      minTileHeight: 20,
                      title: Row(
                        children: [
                          Text(
                            appliedDiscount.discount.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "-${CurrencyUtil.amountWithCurrency(appliedDiscount.amount, currency)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
