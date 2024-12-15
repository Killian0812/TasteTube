part of 'cart_page.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (dialogContext) async {
              bool? confirmed = await showConfirmDialog(
                context,
                title: "Confirm remove cart item",
                body: 'Are you sure you want to remove this item from the cart?',
              );
              if (confirmed == true && context.mounted) {
                await context.read<OrderCubit>().removeFromCart(item);
              }
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(item.product.images[0].url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.product.cost.toStringAsFixed(2)} ${item.currency}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quantity
                  Row(
                    children: [
                      BlocBuilder<OrderCubit, OrderState>(
                        builder: (context, state) {
                          return IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (state is OrderLoading) return;
                              context
                                  .read<OrderCubit>()
                                  .updateItemQuantity(item, item.quantity - 1);
                            },
                          );
                        },
                      ),
                      Text(
                        item.quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      BlocBuilder<OrderCubit, OrderState>(
                        builder: (context, state) {
                          return IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              if (state is OrderLoading) return;
                              context
                                  .read<OrderCubit>()
                                  .updateItemQuantity(item, item.quantity + 1);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Total Price
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(item.cost).toStringAsFixed(2)} ${item.currency}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
