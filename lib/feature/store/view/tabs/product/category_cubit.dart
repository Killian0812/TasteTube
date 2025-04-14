import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/product/category.dart';
import 'package:taste_tube/feature/store/domain/product_repo.dart';
import 'package:taste_tube/core/injection.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final ProductRepository repository;

  CategoryCubit()
      : repository = getIt<ProductRepository>(),
        super(CategoryState([]));

  Future<void> fetchCategory() async {
    emit(CategoryLoading(state.categories));
    final result = await repository.fetchCategories();
    result.fold(
      (error) => emit(CategoryError(
          state.categories, error.message ?? 'Error fetching categories')),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> addCategory(String name) async {
    emit(CategoryLoading(state.categories));
    final result = await repository.addCategory(name);
    result.fold(
      (error) => emit(CategoryError(
          state.categories, error.message ?? 'Error adding category')),
      (category) {
        final updatedCategories = List<Category>.from(state.categories)
          ..add(category);
        emit(CategoryLoaded(updatedCategories));
      },
    );
  }

  Future<void> editCategory(String id, String name) async {
    emit(CategoryLoading(state.categories));
    final result = await repository.updateCategory(id, name);
    result.fold(
      (error) => emit(CategoryError(
          state.categories, error.message ?? 'Error updating category')),
      (updatedCategory) {
        final updatedCategories = state.categories.map((category) {
          return category.id == id ? updatedCategory : category;
        }).toList();
        emit(CategoryLoaded(updatedCategories));
      },
    );
  }

  Future<void> deleteCategory(Category category) async {
    emit(CategoryLoading(state.categories));
    final result = await repository.deleteCategory(category.id);
    result.fold(
      (error) => emit(CategoryError(
          state.categories, error.message ?? 'Error deleting category')),
      (_) {
        final updatedCategories = List<Category>.from(state.categories)
          ..removeWhere((c) => c.id == category.id);
        emit(CategoryLoaded(updatedCategories));
      },
    );
  }
}

class CategoryState {
  final List<Category> categories;

  CategoryState(this.categories);
}

class CategoryLoading extends CategoryState {
  CategoryLoading(super.categories);
}

class CategoryLoaded extends CategoryState {
  CategoryLoaded(super.categories);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(super.categories, this.message);
}
