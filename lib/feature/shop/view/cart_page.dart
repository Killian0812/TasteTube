import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/payment/payment_page.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_data/order/cart.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/utils/currency.util.dart';

part 'cart_page.ext.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 20),
      child: InkWell(
        onTap: () {
          context.push('/cart');
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Align(
                alignment: Alignment.center,
                child: Icon(Icons.shopping_cart, size: 35)),
            BlocConsumer<CartCubit, CartState>(
              listener: (context, state) {
                if (state is CartError) {
                  ToastService.showToast(
                      context, state.error, ToastType.warning);
                }
                if (state is CartSuccess) {
                  ToastService.showToast(
                      context, state.success, ToastType.success);
                }
              },
              builder: (context, state) {
                if (state.cart.items.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 20, left: 25),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                      child: state is CartLoading
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              state.cart.items.length.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartError) {
          ToastService.showToast(context, state.error, ToastType.warning);
        }
        if (state is CartSuccess) {
          ToastService.showToast(context, state.success, ToastType.success);
        }
      },
      builder: (context, state) {
        final cartItems = state.cart.items;

        // Grouping items by product owner
        final groupedItems =
            groupBy(cartItems, (CartItem item) => item.product.userId);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
                "Cart (${cartItems.isEmpty ? 'Empty' : cartItems.length.toString()})"),
          ),
          floatingActionButton: BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.selectedItems.isEmpty) return const SizedBox.shrink();
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentPage.provider()),
                  );
                },
                label: const Text('Payment'),
                icon: const Icon(Icons.paid_outlined),
              );
            },
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await context.read<CartCubit>().getCart();
            },
            child: cartItems.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height:
                          MediaQuery.of(context).size.height - kToolbarHeight,
                      child: const Center(
                        child: Text('Your cart is empty'),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final sellerId = groupedItems.keys.elementAt(index);
                      final sellerItems = groupedItems[sellerId]!;
                      final sellerName = sellerItems[0].product.username;
                      final sellerImage = sellerItems[0].product.userImage;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  BlocBuilder<CartCubit, CartState>(
                                    builder: (context, state) {
                                      final containsAll = state.selectedItems
                                          .toSet()
                                          .containsAll(sellerItems
                                              .map((e) => e.id)
                                              .toSet());
                                      return Checkbox(
                                          value: containsAll,
                                          onChanged: (_) {
                                            context
                                                .read<CartCubit>()
                                                .selectAllItemInSingleShop(
                                                    sellerItems);
                                          });
                                    },
                                  ),
                                  CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          NetworkImage(sellerImage)),
                                  const SizedBox(width: 12),
                                  Text(
                                    sellerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: screenSize.height * 0.6,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: sellerItems.length,
                                  itemBuilder: (context, index) {
                                    return CartItemTile(
                                        item: sellerItems[index]);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
