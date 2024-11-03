import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/product/category/category_cubit.dart';
import 'package:taste_tube/feature/product/data/product.dart';
import 'package:taste_tube/feature/product/product/product_cubit.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class ProductTab extends StatefulWidget {
  const ProductTab({super.key});

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  final List<int> _expandedPanels = [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: BlocConsumer<ProductCubit, ProductState>(
        listener: (context, state) {
          if (state is ProductError) {
            ToastService.showToast(context, state.message, ToastType.error);
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
                icon: const Icon(Icons.fastfood_outlined),
                label: const Text("New product"),
                onPressed: () {
                  _showCreateDialog(context);
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
                    children: [
                      ExpansionPanelList(
                        elevation: 1,
                        expandedHeaderPadding: const EdgeInsets.all(0),
                        expansionCallback: (int index, bool isExpanded) {
                          setState(() {
                            if (isExpanded) {
                              _expandedPanels.remove(index);
                            } else {
                              _expandedPanels.add(index);
                            }
                          });
                        },
                        children: categoryKeys.asMap().entries.map((entry) {
                          final int index = entry.key;
                          final String categoryId = entry.value;
                          final List<Product> products =
                              categorizedProducts[categoryId] ?? [];

                          return ExpansionPanel(
                            headerBuilder:
                                (BuildContext context, bool isExpanded) {
                              return ListTile(
                                title: Text(
                                  categoryId.isNotEmpty
                                      ? categoryId
                                      : 'Uncategorized',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                            body: Column(
                              children: products.map((product) {
                                return Card(
                                  margin: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(product.name),
                                    subtitle: Text(
                                        '${product.cost} ${product.currency}'),
                                    trailing: Text('Qty: ${product.quantity}'),
                                    onTap: () {
                                      // Action on product tap
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                            isExpanded: _expandedPanels.contains(index),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final costController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    final categoryIdController = TextEditingController();
    String selectedCurrency = 'VND';
    String? selectedCategory;
    final categories = context.read<CategoryCubit>().state.categories;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create new product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Cost',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    StatefulBuilder(
                      builder: (context, setState) => DropdownButton<String>(
                        value: selectedCurrency,
                        items: <String>['USD', 'VND'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCurrency = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                  ),
                ),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, setState) => DropdownButton<String>(
                    hint: const Text('Category'),
                    isExpanded: true,
                    value: selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                final double cost = double.tryParse(costController.text) ?? 0;
                final String description = descriptionController.text.trim();
                final int quantity = int.tryParse(quantityController.text) ?? 0;
                final String categoryId = categoryIdController.text.trim();

                if (name.isNotEmpty &&
                    cost > 0 &&
                    quantity > 0 &&
                    categoryId.isNotEmpty) {
                  await context.read<ProductCubit>().addProduct(
                    name,
                    cost,
                    selectedCurrency,
                    description,
                    quantity,
                    categoryId,
                    [],
                  );
                  if (context.mounted) Navigator.of(context).pop();
                } else {
                  ToastService.showToast(context,
                      'Please fill all fields correctly', ToastType.error);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
