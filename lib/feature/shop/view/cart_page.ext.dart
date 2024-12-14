part of 'cart_page.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Space between items
      decoration: BoxDecoration(
        border:
            Border.all(color: Colors.grey.shade300), // Border to separate items
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align image with the top of the row
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(8.0), // Rounded corners for image
              image: DecorationImage(
                image: NetworkImage(item.product.images[0].url),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12), // Spacing between image and details

          // Product details (name, cost, quantity controls)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4), // Space between name and cost
                // Product Cost
                Text(
                  '${item.product.cost.toStringAsFixed(2)} ${item.currency}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                // Quantity Row (buttons and quantity display)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        // Add logic to decrease quantity
                      },
                    ),
                    Text(
                      item.quantity.toString(),
                      style: const TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        // Add logic to increase quantity
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
    );
  }
}
