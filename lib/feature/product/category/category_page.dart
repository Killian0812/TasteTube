import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/product/category/category_cubit.dart';
import 'package:taste_tube/feature/product/data/category.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          final categories = state.categories;
          return Column(
            children: [
              FloatingActionButton.extended(
                icon: const Icon(Icons.add_card),
                label: const Text("New category"),
                onPressed: () {
                  _showEditOrCreateDialog(context);
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(category.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () {
                                _showEditOrCreateDialog(context,
                                    category: category);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_outlined),
                              onPressed: () {
                                _showDeleteDialog(context, category);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
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