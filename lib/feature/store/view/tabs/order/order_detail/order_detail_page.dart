import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/store/view/tabs/order/order_detail/order_delivery_tab.dart';
import 'package:taste_tube/feature/store/view/tabs/order/order_detail/order_detail_tab.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({required this.orderId, super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final order =
            state.orders.firstWhereOrNull((e) => e.id == widget.orderId);

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
                Text('Order #${order.orderId}'),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.orderId));
                    ToastService.showToast(context,
                        'Order ID copied to clipboard', ToastType.info);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Order Details'),
                Tab(text: 'Delivery Status'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              OrderDetailTab(order: order),
              OrderDeliveryTab(order: order),
            ],
          ),
        );
      },
    );
  }
}
