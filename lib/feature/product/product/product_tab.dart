import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/product/category/category_cubit.dart';
import 'package:taste_tube/feature/product/data/product.dart';
import 'package:taste_tube/feature/product/product/product_cubit.dart';
import 'package:taste_tube/utils/user_data.util.dart';

part 'product_tab.ext.dart';

class ProductTab extends StatelessWidget {
  const ProductTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ToastService.showToast(context, state.message, ToastType.error);
            return;
          }
          if (state is ProductSuccess) {
            ToastService.showToast(context, state.message, ToastType.success);
            return;
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final categorizedProducts = state.categorizedProducts;
          final categoryKeys = categorizedProducts.keys.toList();

          return Column(
            children: [
              FloatingActionButton.extended(
                heroTag: 'Add product',
                icon: const Icon(Icons.fastfood_outlined),
                label: const Text("New product"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateOrEditProductPage(
                        categoryCubit: context.read<CategoryCubit>(),
                        productCubit: context.read<ProductCubit>(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ProductCubit>()
                        .fetchProducts(UserDataUtil.getUserId(context));
                  },
                  child: ListView(
                      children: categoryKeys.asMap().entries.map((entry) {
                    final category = entry.value;
                    final List<Product> products =
                        categorizedProducts[category] ?? [];

                    return ExpansionTile(
                      title: Row(children: [
                        Text(category.name),
                        const Spacer(),
                        Text(
                          products.length.toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                          ),
                        ),
                      ]),
                      children: products.isNotEmpty
                          ? products.map((product) {
                              return ListTile(
                                title: Text(product.name),
                                subtitle:
                                    Text('${product.cost} ${product.currency}'),
                                trailing: Text('Quantity: ${product.quantity}'),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CreateOrEditProductPage(
                                        categoryCubit:
                                            context.read<CategoryCubit>(),
                                        productCubit:
                                            context.read<ProductCubit>(),
                                        product: product,
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList()
                          : [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No products available',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                    );
                  }).toList()),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
