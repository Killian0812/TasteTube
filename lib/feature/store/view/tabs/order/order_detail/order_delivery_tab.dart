import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/data/delivery_data.dart';
import 'package:taste_tube/feature/store/view/tabs/order/order_detail/order_delivery_cubit.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/providers.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class OrderDeliveryTab extends StatelessWidget {
  final Order order;
  const OrderDeliveryTab({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderDeliveryCubit(order.id)..getOrderDelivery(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocListener<OrderDeliveryCubit, OrderDeliveryState>(
              listener: (context, state) {
                if (state is OrderDeliverySuccess) {
                  ToastService.showToast(context,
                      "Successfully placed delivery", ToastType.success);
                  context.read<OrderCubit>().getOrders();
                } else if (state is OrderDeliveryError) {
                  ToastService.showToast(
                      context, state.error, ToastType.warning);
                } else if (state is OrderDeliveryLoaded) {
                  if (state.orderDelivery?.statusLogs.lastOrNull
                          ?.deliveryStatus ==
                      DeliveryStatus.COMPLETED) {
                    context.read<OrderCubit>().getOrders();
                  }
                }
              },
              child: BlocBuilder<OrderDeliveryCubit, OrderDeliveryState>(
                builder: (context, state) {
                  if (state is OrderDeliveryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<OrderDeliveryCubit>().getOrderDelivery();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: state.orderDelivery != null
                          ? _buildOrderDelivery(context, state)
                          : (state.quotes == null ||
                                  state.origin == null ||
                                  state.destination == null)
                              ? const SizedBox.shrink()
                              : _buildDeliveryOptions(context, state),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDelivery(BuildContext context, OrderDeliveryState state) {
    final nextStatus =
        state.orderDelivery!.statusLogs.lastOrNull?.deliveryStatus.nextStatus;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Delivery',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Delivery Type: ${state.orderDelivery!.deliveryType.name}'),
            const SizedBox(height: 16),
            Text('Tracking ID: ${order.trackingId}'),
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
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions(BuildContext context, OrderDeliveryState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            _buildAddressRow(context, 'From:', state.origin!, Icons.store),
            _buildAddressRow(context, 'To:', state.destination!, Icons.home),
            const Divider(height: 24),
            _buildDeliveryOption(
              context,
              'Self Delivery',
              state.quotes!['selfDelivery']!,
              'SELF',
              state.selectedDeliveryType,
              null,
            ),
            const SizedBox(height: 12),
            _buildDeliveryOption(
              context,
              'Grab Delivery',
              state.quotes!['grabDelivery']!,
              'GRAB',
              state.selectedDeliveryType,
              AssetPath.grab,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: state.selectedDeliveryType == null
                  ? null
                  : () =>
                      context.read<OrderDeliveryCubit>().createOrderDelivery(),
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirm Delivery'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(
      BuildContext context, String label, String address, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(address, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption(
    BuildContext context,
    String title,
    DeliveryQuote quote,
    String deliveryType,
    String? selectedDeliveryType,
    String? imagePath,
  ) {
    bool isSelected = selectedDeliveryType == deliveryType;

    return InkWell(
      onTap: () =>
          context.read<OrderDeliveryCubit>().selectDeliveryType(deliveryType),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio<String>(
                  value: deliveryType,
                  groupValue: selectedDeliveryType,
                  onChanged: (value) => context
                      .read<OrderDeliveryCubit>()
                      .selectDeliveryType(value!),
                  activeColor: Theme.of(context).primaryColor,
                ),
                imagePath != null
                    ? Image.asset(
                        imagePath,
                        height: 25,
                        fit: BoxFit.contain,
                      )
                    : Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                      ),
                const Spacer(),
                Text(
                  '${quote.amount.toString()} ${UserDataUtil.getCurrency()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            isSelected ? Theme.of(context).primaryColor : null,
                      ),
                ),
              ],
            ),
            if (quote.estimatedTimeline != null) ...[
              const SizedBox(height: 8),
              Text(
                'Pickup: ${_formatDate(quote.estimatedTimeline!['pickup']!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Dropoff: ${_formatDate(quote.estimatedTimeline!['dropoff']!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Complete: ${_formatDate(quote.estimatedTimeline!['completed']!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('HH:mm dd/MM/yyyy').format(date.toLocal());
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
    final editable =
        context.read<OrderDeliveryCubit>().state.orderDelivery!.deliveryType ==
            DeliveryType.SELF;
    return GestureDetector(
      onTap: () async {
        if (!editable) return;
        final approved = await showConfirmDialog(
          context,
          body:
              'Are you sure you want to update the delivery status to ${status.displayName}?',
          title: 'Confirm Status Update',
        );
        if (approved == true && context.mounted) {
          context
              .read<OrderDeliveryCubit>()
              .updateSelfOrderDelivery(status.name);
        }
      },
      onDoubleTap: () {
        if (!editable) return;
        context.read<OrderDeliveryCubit>().updateSelfOrderDelivery(status.name);
      },
      child: Padding(
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
                    color: isCompleted ? Colors.green : Colors.grey,
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
      ),
    );
  }
}
