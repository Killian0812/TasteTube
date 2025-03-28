import 'package:flutter/material.dart';
import 'package:taste_tube/global_data/order/order.dart';

class OrderDeliveryTab extends StatelessWidget {
  final Order order;
  const OrderDeliveryTab({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    // Assuming you have delivery status information in your order model
                    // If not, you'll need to add it to your Order model and Cubit
                    Text('Current Status: ${order.status}'),
                    const SizedBox(height: 16),
                    Text('Tracking ID: ${order.trackingId}'),
                    const SizedBox(height: 16),
                    // Example delivery timeline - customize based on your needs
                    _TimelineTile(
                      status: 'Order Placed',
                      date: order.createdAt,
                      isCompleted: true,
                    ),
                    _TimelineTile(
                      status: 'Processing',
                      date: order.createdAt.add(Duration(hours: 1)),
                      // isCompleted:
                      //     order.status != OrderStatus.pending.name,
                      isCompleted: false,
                    ),
                    _TimelineTile(
                      status: 'Shipped',
                      date: order.createdAt.add(Duration(days: 1)),
                      // isCompleted: order.status ==
                      //         OrderStatus.shipped.name ||
                      //     order.status == OrderStatus.delivered.name,
                      isCompleted: false,
                    ),
                    _TimelineTile(
                      status: 'Delivered',
                      date: order.createdAt.add(Duration(days: 2)),
                      // isCompleted:
                      //     order.status == OrderStatus.delivered.name,
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  final String status;
  final DateTime date;
  final bool isCompleted;

  const _TimelineTile({
    required this.status,
    required this.date,
    required this.isCompleted,
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
                  color: isCompleted ? Colors.green : Colors.grey,
                ),
              ),
              if (status != 'Delivered') // No line after last item
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
                status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
