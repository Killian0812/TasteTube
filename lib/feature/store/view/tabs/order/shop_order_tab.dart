import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/toast.dart';
// ignore: unused_import
import 'package:taste_tube/feature/profile/view/profile_page.dart';
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
                    return _OrderCard(order: order);
                  },
                ),
        );
      },
    );
  }
}

class _OrderCard extends StatefulWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _isExpanded = false;

  Order get order => widget.order;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.orderId}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ID: ${order.trackingId}',
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
            Row(
              children: [
                const Text('Status: '),
                DropdownButton<String>(
                  value: order.status,
                  items: OrderStatus.values.map((status) {
                    return DropdownMenuItem<String>(
                      value: status.name,
                      child: Text(
                        status.name,
                        style:
                            TextStyle(color: OrderColor.getColor(status.name)),
                      ),
                    );
                  }).toList(),
                  onChanged: (newStatus) {
                    context
                        .read<OrderCubit>()
                        .updateOrderStatus(order.id, newStatus);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                  ]
                ],
              ),
            ),
            const SizedBox(height: 8),
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
            const Divider(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                children: [
                  Text(
                    _isExpanded ? 'Hide Customer' : 'Show Customer',
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      context.push('/user/${order.user.id}');
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(order.user.image),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${order.user.username}'),
                            Text('Email: ${order.user.email}'),
                            if (order.user.phone != null)
                              Text('Phone: ${order.user.phone}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (order.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Notes: ${order.notes}'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
