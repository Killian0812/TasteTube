import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/datetime.util.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class OrderDetailTab extends StatelessWidget {
  final Order order;
  const OrderDetailTab({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currency = UserDataUtil.getCurrency();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderCubit>().getOrders();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Overview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        'Tracking ID: ${order.trackingId}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time),
                          SizedBox(width: 4),
                          Text(DateTimeUtil.dateTimeHHmmddMMyyyy(
                              order.createdAt)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Status: ',
                              style: TextStyle(fontSize: 16)),
                          DropdownButton<String>(
                            value: order.status,
                            items: OrderStatus.values.map((status) {
                              return DropdownMenuItem<String>(
                                value: status.name,
                                child: Text(
                                  status.name,
                                  style: TextStyle(
                                      color: OrderColor.getColor(status.name)),
                                ),
                              );
                            }).toList(),
                            onChanged: (newStatus) async {
                              if (newStatus == "CANCELED") {
                                final reason =
                                    await showOrderCancelDialog(context);
                                if (reason == null) return;
                                if (context.mounted) {
                                  context.read<OrderCubit>().updateOrderStatus(
                                        order.id,
                                        newStatus,
                                        reason: reason,
                                      );
                                }
                                return;
                              }
                              final confirmed = await showConfirmDialog(
                                context,
                                title: 'Change Order Status',
                                body:
                                    'Are you sure you want to change order status to $newStatus?',
                              );
                              if (confirmed == true && context.mounted) {
                                context
                                    .read<OrderCubit>()
                                    .updateOrderStatus(order.id, newStatus);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      if (order.cancelBy != null || order.cancelReason != null)
                        Text.rich(
                          TextSpan(
                            children: [
                              if (order.cancelBy != null) ...[
                                const TextSpan(text: 'Canceled by: '),
                                TextSpan(
                                  text: order.cancelBy,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                              if (order.cancelReason != null) ...[
                                const TextSpan(text: ' - Reason: '),
                                TextSpan(
                                  text: order.cancelReason,
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      RichText(
                        text: TextSpan(
                          text: 'Payment Method: ',
                          style: Theme.of(context).textTheme.bodyMedium,
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
                      const SizedBox(height: 16),
                      Text(
                        'Total: ${CurrencyUtil.amountWithCurrency(order.total, currency)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
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

              // Items List (expandable)
              const SizedBox(height: 16),
              Card(
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    'Order Items x ${order.items.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ListView.builder(
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
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Customer Details (expandable)
              const SizedBox(height: 16),
              Card(
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: const Text(
                    'Customer Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/user/${order.user.id}'),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(order.user.image),
                                  radius: 24,
                                ),
                                const SizedBox(width: 12),
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
                          const SizedBox(height: 8),
                          Text('Delivery: ${order.address.value}'),
                          Text(
                              'Receiver: ${order.address.name} - ${order.address.phone}'),
                          if (order.notes.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Notes: ${order.notes}'),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
