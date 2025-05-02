import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/tabs/order/feedback_cubit.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_product_page.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/datetime.util.dart';
import 'package:taste_tube/utils/user_data.util.dart';

part 'order_feedback_dialog.dart';

class CustomerOrderDetailPage extends StatelessWidget {
  final String orderId;
  const CustomerOrderDetailPage({required this.orderId, super.key});

  static Widget provider(String orderId) {
    return BlocProvider(
      create: (context) => FeedbackCubit()..getOrderFeedbacks(orderId),
      child: CustomerOrderDetailPage(orderId: orderId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final order = state.orders.firstWhereOrNull((e) => e.id == orderId);
        final currency = UserDataUtil.getCurrency();

        if (order == null) {
          return const Scaffold(
            body: Center(child: Text('Order not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Order #${order.trackingId}'),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.orderId));
                    ToastService.showToast(
                        context, 'ID copied to clipboard', ToastType.info);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
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
                    // Items List (expandable)
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
                                return BlocBuilder<FeedbackCubit,
                                    FeedbackState>(
                                  builder: (context, state) {
                                    final productFeedback = state.feedbacks
                                        .firstWhereOrNull((f) =>
                                            f.productId == product.id &&
                                            f.orderId == order.id);
                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: Image.network(
                                            product.images[0].url,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                          title: Text(product.name),
                                          trailing: Text(
                                            CurrencyUtil.amountWithCurrency(
                                              item.quantity * product.cost,
                                              product.currency,
                                            ),
                                          ),
                                          subtitle: Text(
                                              'Quantity: ${item.quantity}'),
                                          onTap: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        SingleShopProductPage(
                                                            product: product)));
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (productFeedback != null) ...[
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    children: List.generate(
                                                      5,
                                                      (index) => Icon(
                                                        index <
                                                                productFeedback
                                                                    .rating
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  if (productFeedback.feedback
                                                          ?.isNotEmpty ??
                                                      false)
                                                    Text(
                                                      '“${productFeedback.feedback}”',
                                                      style: TextStyle(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                            if (order.status ==
                                                OrderStatus.COMPLETED.name)
                                              TextButton.icon(
                                                icon: Icon(
                                                    productFeedback == null
                                                        ? Icons.rate_review
                                                        : Icons.edit),
                                                label: Text(
                                                    productFeedback == null
                                                        ? 'Leave Feedback'
                                                        : 'Edit Feedback'),
                                                onPressed: () async {
                                                  final cubit = context
                                                      .read<FeedbackCubit>();
                                                  await showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          BlocProvider.value(
                                                            value: cubit,
                                                            child:
                                                                _FeedbackDialog(
                                                              product: product,
                                                              orderId: orderId,
                                                            ),
                                                          ));
                                                },
                                              ),
                                          ],
                                        ),
                                        const Divider(),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    // Order Overview
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                            RichText(
                              text: TextSpan(
                                text: 'Status: ',
                                style: Theme.of(context).textTheme.bodyMedium,
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
                            const SizedBox(height: 8),
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
                              childrenPadding:
                                  const EdgeInsets.only(left: 16.0),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
