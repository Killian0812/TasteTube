import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/providers.dart';
import 'package:taste_tube/feature/shop/data/delivery_data.dart';
import 'package:taste_tube/feature/shop/view/tabs/order/feedback_cubit.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_product_page.dart';
import 'package:taste_tube/feature/store/view/tabs/order/order_detail/order_delivery_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FeedbackCubit()..getOrderFeedbacks(orderId),
        ),
        BlocProvider(
          create: (context) => OrderDeliveryCubit(orderId)..getOrderDelivery(),
        ),
      ],
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
              context.read<OrderDeliveryCubit>().getOrderDelivery();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: ExpansionTile(
                        initiallyExpanded: true,
                        title: const Text(
                          'Delivery Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: BlocBuilder<OrderDeliveryCubit,
                                OrderDeliveryState>(
                              builder: (context, state) {
                                if (state is OrderDeliveryLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return _buildOrderDelivery(context, state);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

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

  Widget _buildOrderDelivery(BuildContext context, OrderDeliveryState state) {
    if (state.orderDelivery == null) {
      return const Center(child: Text('No delivery information available'));
    }

    if (state.orderDelivery!.statusLogs.isEmpty) {
      return const Center(child: Text('No delivery status available'));
    }

    final nextStatus =
        state.orderDelivery!.statusLogs.lastOrNull?.deliveryStatus.nextStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Origin and Destination
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trip_origin,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Origin',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.origin!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[700]),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Icon(
                  Icons.arrow_forward,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'Destination',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      state.destination!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey[700]),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Delivery status
        ...state.orderDelivery!.statusLogs.map((e) => _TimelineTile(
              status: e.deliveryStatus,
              date: e.deliveryTimestamp,
              isCompleted: true,
              showLine: !e.deliveryStatus.isFinalStatus,
            )),
        if (nextStatus != null)
          _TimelineTile(
            status: nextStatus,
            date: null,
            isCompleted: false,
            showLine: !nextStatus.isFinalStatus,
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final DeliveryStatus status;
  final DateTime? date;
  final bool isCompleted;
  final bool showLine;

  const _TimelineTile({
    required this.status,
    required this.date,
    required this.isCompleted,
    this.showLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? status.finalStatusColor : Colors.grey,
                ),
              ),
              if (showLine)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.displayName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (date != null)
                Text(
                  '${date!.day}/${date!.month}/${date!.year} ${date!.hour}:${date!.minute}',
                  style: getIt<AppSettings>().getTheme == ThemeMode.dark
                      ? const TextStyle(color: Colors.grey)
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
