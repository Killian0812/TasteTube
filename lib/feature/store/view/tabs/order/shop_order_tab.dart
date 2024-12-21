import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/order/order.dart';

class ShopOrderTab extends StatelessWidget {
  const ShopOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderCubit, OrderState>(
      listener: (context, state) {
        if (state is OrderError) {
          ToastService.showToast(context, state.error, ToastType.warning);
        }
        if (state is OrderSuccess) {
          ToastService.showToast(context, state.success, ToastType.success);
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<OrderCubit>().getOrders();
          },
          child: state.orders.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 50),
                    Center(
                      child: Text('No orders found'),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: state.orders.length,
                  itemBuilder: (context, index) {
                    final order = state.orders[index];
                    return OrderCard(order: order);
                  },
                ),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

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
                Text(
                  'Order #${order.orderNum} - ${order.orderId}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.orderId));
                    ToastService.showToast(context,
                        'Order ID copied to clipboard', ToastType.info);
                  },
                ),
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
            Text(
                'Total: ${order.total.toStringAsFixed(2)} ${order.items.first.product.currency}'),
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
                  trailing: Text(
                      '${product.cost.toStringAsFixed(2)} ${product.currency}'),
                  subtitle: Text('Quantity: ${item.quantity}'),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
