import 'dart:io';
import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/store/view/tabs/product/category_cubit.dart';
import 'package:taste_tube/global_data/product/category.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/feature/store/view/tabs/product/product_cubit.dart';
import 'package:taste_tube/utils/user_data.util.dart';

part 'product_tab.ext.dart';

class ProductTab extends StatelessWidget {
  const ProductTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (state is CategoryError) {
            ToastService.showToast(context, state.message, ToastType.error);
          }
          if (state is CategoryLoaded) {
            context
                .read<ProductCubit>()
                .fetchProducts(UserDataUtil.getUserId());
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final categories = state.categories;

          return BlocConsumer<ProductCubit, ProductState>(
            listener: (context, state) {
              if (state is ProductError) {
                ToastService.showToast(context, state.message, ToastType.error);
                return;
              }
              if (state is ProductSuccess) {
                ToastService.showToast(
                    context, state.message, ToastType.success);
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

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      FloatingActionButton.extended(
                        heroTag: 'Add category',
                        icon: const Icon(Icons.add_card),
                        label: const Text("New category"),
                        onPressed: () {
                          _showEditOrCreateDialog(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          context.read<CategoryCubit>().fetchCategory(),
                      child: ListView(
                        children: categories.asMap().entries.map((entry) {
                          final category = entry.value;
                          final List<Product> products =
                              categorizedProducts[category] ?? [];

                          return ExpansionTile(
                            initiallyExpanded: true,
                            title: Row(children: [
                              Text(category.name),
                              const Spacer(),
                              Text(
                                "Total products: ${products.length.toString()}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                ),
                              ),
                            ]),
                            trailing: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (String value) {
                                if (value == 'edit') {
                                  _showEditOrCreateDialog(context,
                                      category: category);
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, category);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline_outlined),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: products.isNotEmpty
                                    ? GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 0.75,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount: products.length,
                                        itemBuilder: (context, index) {
                                          final product = products[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      CreateOrEditProductPage(
                                                    categoryCubit: context
                                                        .read<CategoryCubit>(),
                                                    productCubit: context
                                                        .read<ProductCubit>(),
                                                    product: product,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              elevation: 2,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Product Image
                                                  Expanded(
                                                    child: product
                                                            .images.isNotEmpty
                                                        ? Image.network(
                                                            product
                                                                .images[0].url,
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                          )
                                                        : Container(
                                                            color: Colors
                                                                .grey[300],
                                                            child: const Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                              size: 50,
                                                            ),
                                                          ),
                                                  ),
                                                  // Product Details
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          product.name,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          '${product.cost} ${product.currency}',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .green[700],
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          'Qty: ${product.quantity}',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[600],
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                        if (product.ship)
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 4),
                                                            child: Text(
                                                              'Shipping Available',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          'No products available',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showEditOrCreateDialog(BuildContext context, {Category? category}) {
    final isEditing = category != null;
    final TextEditingController categoryController =
        TextEditingController(text: category?.name);
    final cubit = context.read<CategoryCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Edit category" : 'New category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(labelText: 'Category name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (categoryController.text.isNotEmpty) {
                  isEditing
                      ? cubit.editCategory(category.id, categoryController.text)
                      : cubit.addCategory(categoryController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    final cubit = context.read<CategoryCubit>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete category"),
          content: const Text(
              "This action will also delete every product under category. Do you want to proceed?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                cubit.deleteCategory(category);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
