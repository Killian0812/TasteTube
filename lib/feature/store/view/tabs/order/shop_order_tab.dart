import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/payment/data/payment_data.dart';
import 'package:taste_tube/feature/store/view/tabs/order/order_detail/order_detail_page.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_data/order/order.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/providers.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/datetime.util.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class OrderFilter extends ChangeNotifier {
  String? totalCostRange;
  String? paymentMethod;
  String searchQuery = '';
  DateTime? fromDate;
  DateTime? toDate;

  void setTotalCostRange(String? newRange) {
    totalCostRange = newRange;
    notifyListeners();
  }

  void setPaymentMethod(String? newMethod) {
    paymentMethod = newMethod;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setDateRange(DateTime? from, DateTime? to) {
    fromDate = from;
    toDate = to;
    notifyListeners();
  }

  void reset() {
    totalCostRange = null;
    paymentMethod = null;
    searchQuery = '';
    fromDate = null;
    toDate = null;
    notifyListeners();
  }
}

class ShopOrderTab extends StatelessWidget {
  const ShopOrderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderFilter()),
      ],
      child: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ToastService.showToast(context, state.error, ToastType.warning);
          }
          if (state is OrderSuccess) {
            ToastService.showToast(context, state.success, ToastType.success);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: _buildOrderContent(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final filter = Provider.of<OrderFilter>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by Order ID or Tracking ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => filter.setSearchQuery(value),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderContent(BuildContext context, OrderState state) {
    final filter = Provider.of<OrderFilter>(context);
    final filteredOrders = _filterOrders(state.orders, filter);

    if (filteredOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<OrderCubit>().getOrders();
        },
        child: ListView(
          children: const [
            SizedBox(height: 50),
            Center(child: Text('No orders found')),
          ],
        ),
      );
    }

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
                final statusOrders = filteredOrders
                    .where((order) => order.status == status.name)
                    .toList();
                return RefreshIndicator(
                  onRefresh: () async {
                    await context.read<OrderCubit>().getOrders();
                  },
                  child: statusOrders.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 50),
                            Center(child: Text('No orders in this category')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: statusOrders.length,
                          itemBuilder: (context, index) {
                            return _OrderCard(order: statusOrders[index]);
                          },
                        ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Order> _filterOrders(List<Order> orders, OrderFilter filter) {
    var result = orders;

    // Filter by total cost range
    if (filter.totalCostRange != null) {
      result = result.where((order) {
        final total = order.total;
        switch (filter.totalCostRange) {
          case '0-100K':
            return total <= 100000;
          case '100K-1M':
            return total > 100000 && total <= 1000000;
          case '1M-5M':
            return total > 1000000 && total <= 5000000;
          case '5M+':
            return total > 5000000;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by payment method
    if (filter.paymentMethod != null) {
      result = result
          .where((order) => order.paymentMethod == filter.paymentMethod)
          .toList();
    }

    // Filter by date range
    if (filter.fromDate != null) {
      result = result
          .where((order) => order.createdAt.isAfter(filter.fromDate!))
          .toList();
    }
    if (filter.toDate != null) {
      result = result
          .where((order) => order.createdAt.isBefore(filter.toDate!))
          .toList();
    }

    // Filter by search query
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      result = result
          .where((order) =>
              order.orderId.toLowerCase().contains(query) ||
              order.trackingId.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  void _showFilterDialog(BuildContext context) {
    final filter = Provider.of<OrderFilter>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Orders'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range Filter
                    const Text(
                      'Date Range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: filter.fromDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() =>
                                    filter.setDateRange(date, filter.toDate));
                              }
                            },
                            child: Text(
                              filter.fromDate != null
                                  ? 'From: ${filter.fromDate!.toString().split(' ')[0]}'
                                  : 'From: All',
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: filter.toDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (date != null) {
                                setState(() =>
                                    filter.setDateRange(filter.fromDate, date));
                              }
                            },
                            child: Text(
                              filter.toDate != null
                                  ? 'To: ${filter.toDate!.toString().split(' ')[0]}'
                                  : 'To: All',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Payment Amount Filter
                    const Text(
                      'Payment Amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String?>(
                      value: filter.totalCostRange,
                      isExpanded: true,
                      hint: const Text('Select Total Cost Range'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All'),
                        ),
                        const DropdownMenuItem(
                          value: '0-100K',
                          child: Text('< 100K'),
                        ),
                        const DropdownMenuItem(
                          value: '100K-1M',
                          child: Text('100K - 1M'),
                        ),
                        const DropdownMenuItem(
                          value: '1M-5M',
                          child: Text('1M - 5M'),
                        ),
                        const DropdownMenuItem(
                          value: '5M+',
                          child: Text('> 5M'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => filter.setTotalCostRange(value));
                      },
                    ),
                    const SizedBox(height: 16),

                    // Payment Method Filter
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String?>(
                      value: filter.paymentMethod,
                      isExpanded: true,
                      hint: const Text('Select Payment Method'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All'),
                        ),
                        ...PaymentMethod.values.map((method) {
                          return DropdownMenuItem(
                            value: method.name,
                            child: Text(method.displayName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() => filter.setPaymentMethod(value));
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                filter.reset();
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ],
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
  Order get order => widget.order;

  @override
  Widget build(BuildContext context) {
    final currency = UserDataUtil.getCurrency();

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailPage(orderId: order.id),
                      ),
                    );
                  },
                  child: Text(
                    'Order #${order.orderId}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor:
                              getIt<AppSettings>().getTheme == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                  ),
                ),
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
            SelectableText('Tracking ID: ${order.trackingId}'),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time),
                SizedBox(width: 4),
                Text(DateTimeUtil.dateTimeHHmmddMMyyyy(order.createdAt)),
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
                  onChanged: (newStatus) async {
                    if (newStatus == "CANCELED") {
                      final reason = await showOrderCancelDialog(context);
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
            ExpansionTile(
              minTileHeight: 20,
              title: Text(
                'Items: ${order.items.length}',
                style: const TextStyle(fontSize: 14),
              ),
              initiallyExpanded: true,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
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
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                        trailing: Text('x${item.quantity}'),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
