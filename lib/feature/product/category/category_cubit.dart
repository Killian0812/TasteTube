import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/feature/product/data/category.dart';

// TODO: Call APIs
class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(CategoryState([]));

  FutureOr<void> fetchCategory() async {
    final List<Category> categories = [
      Category("01", "category 01"),
      Category("02", "category 02"),
      Category("03", "category 03"),
      Category("04", "category 04"),
      Category("05", "category 05"),
      Category("06", "category 06"),
      Category("07", "category 07"),
    ];
    emit(CategoryLoaded(categories));
  }

  FutureOr<void> addCategory(String name) async {
    final newCategory = Category(Random().nextInt(100).toString(), name);
    final List<Category> updatedCategories = List.from(state.categories)
      ..add(newCategory);
    emit(CategoryLoaded(updatedCategories));
  }

  FutureOr<void> editCategory(String id, String name) async {
    final index = state.categories.indexWhere((e) => e.id == id);
    if (index == -1) {
      emit(CategoryError(state.categories));
      return;
    }
    state.categories[index] = Category(id, name);
    emit(CategoryLoaded(state.categories));
  }

  void deleteCategory(Category category) async {
    final newCategories = state.categories.delete(category).toList();
    emit(CategoryLoaded(newCategories));
  }
}

class CategoryState {
  final List<Category> categories;

  CategoryState(this.categories);
}

class CategoryLoaded extends CategoryState {
  CategoryLoaded(super.categories);
}

class CategoryError extends CategoryState {
  CategoryError(super.categories);
}
