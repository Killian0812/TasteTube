import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_product_page.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/datetime.util.dart';

part 'order_feedback_dialog.dart';

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
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(
                  'Order #${order.trackingId}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.trackingId));
                    ToastService.showToast(context,
                        'Order ID copied to clipboard', ToastType.info);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
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
            Text(
                'Total: ${CurrencyUtil.amountWithCurrency(order.total, order.items.first.product.currency)}'),
            const SizedBox(height: 8),
            Text('Items: ${order.items.length}'),
            const Divider(),
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
                  trailing: Text(CurrencyUtil.amountWithCurrency(
                      product.cost, product.currency)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: ${item.quantity}'),
                      if (item.rating != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text("Your rating: "),
                            ...List.generate(5, (index) {
                              final starValue = index + 1;
                              return Icon(
                                item.rating! >= starValue
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              );
                            })
                          ],
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                SingleShopProductPage(product: product)));
                  },
                );
              },
            ),
            if (order.status == 'COMPLETED' && order.feedback == null) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _FeedbackDialog(order: order),
                  );
                },
                child: const Text('Send Feedback'),
              ),
            ],
            if (order.feedback != null) ...[
              const SizedBox(height: 8),
              Text('Your Feedback: ${order.feedback}'),
            ],
          ],
        ),
      ),
    );
  }
}
