import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/data/product_options.dart';
import 'package:taste_tube/feature/shop/view/payment/payment_page.dart';
import 'package:taste_tube/feature/shop/view/product_options_dialog.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_product_page.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/utils/currency.util.dart';

void showAttachedProductsSheet(BuildContext context, List<Product> products) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      int currentIndex = 0;
      return BlocListener<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ToastService.showToast(context, state.error, ToastType.warning);
          }
          if (state is CartSuccess) {
            ToastService.showToast(context, state.success, ToastType.success);
          }
          if (state is AddedToCartAndReadyToPay) {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => PaymentPage.provider()),
            );
          }
        },
        child: FractionallySizedBox(
          heightFactor: 0.6,
          child: StatefulBuilder(
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (products.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (currentIndex > 0)
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              onPressed: () {
                                snapshot(() {
                                  currentIndex--;
                                });
                              },
                            )
                          else
                            const SizedBox(width: 30),
                          Text(
                            'Product ${currentIndex + 1} of ${products.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (currentIndex < products.length - 1)
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios),
                              onPressed: () {
                                snapshot(() {
                                  currentIndex++;
                                });
                              },
                            )
                          else
                            const SizedBox(width: 30)
                        ],
                      ),
                    Expanded(
                      child: PageView.builder(
                        itemCount: products.length,
                        onPageChanged: (index) {
                          snapshot(() {
                            currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final product = products[currentIndex];
                          return ProductItem(product: product);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: PageView(
            children: product.images.map((image) {
              return Image.network(image.url, fit: BoxFit.cover);
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          SingleShopProductPage(product: product))),
              child: Text(
                product.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            if (product.avgRating != null && product.avgRating! > 0.0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 15),
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.avgRating!.toStringAsFixed(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
          ],
        ),
        if (product.description != null && product.description!.isNotEmpty)
          Text(
            product.description!,
            style: const TextStyle(fontSize: 18),
          ),
        Text(
          CurrencyUtil.amountWithCurrency(product.cost, product.currency),
          style: const TextStyle(fontSize: 18, color: Colors.green),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            context.push("/shop/${product.userId}");
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(product.userImage),
                radius: 16,
              ),
              const SizedBox(width: 8),
              Text(
                product.username,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (product.ship)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    ProductOptions? options = await showDialog<ProductOptions>(
                      context: context,
                      builder: (context) =>
                          ProductOptionsDialog(product: product),
                    );
                    if (!context.mounted ||
                        options == null ||
                        options.quantity <= 0) {
                      return;
                    }
                    context.read<CartCubit>().addToCart(product, options);
                  },
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: CommonColor.activeBgColor)),
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(color: CommonColor.activeBgColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    ProductOptions? options = await showDialog<ProductOptions>(
                      context: context,
                      builder: (context) => ProductOptionsDialog(
                        product: product,
                      ),
                    );
                    if (!context.mounted ||
                        options == null ||
                        options.quantity <= 0) {
                      return;
                    }
                    context
                        .read<CartCubit>()
                        .addToCartAndPayImmediate(product, options);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CommonColor.activeBgColor,
                  ),
                  child: const Text(
                    'Buy Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
