import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/product/data/category.dart';
import 'package:taste_tube/feature/product/data/product.dart';
import 'package:taste_tube/feature/product/domain/product_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class ProductState {
  final Map<Category, List<Product>> categorizedProducts;

  ProductState(this.categorizedProducts);
}

class ProductInitial extends ProductState {
  ProductInitial() : super({});
}

class ProductLoading extends ProductState {
  ProductLoading(super.categorizedProducts);
}

class ProductSuccess extends ProductState {
  final String message;

  ProductSuccess(super.categorizedProducts, this.message);
}

class ProductLoaded extends ProductState {
  ProductLoaded(super.categorizedProducts);
}

class ProductError extends ProductState {
  final String message;

  ProductError(super.categorizedProducts, this.message);
}

class CreateProductError extends ProductState {
  final String message;

  CreateProductError(super.categorizedProducts, this.message);
}

Map<Category, List<Product>> _categorizeProducts(List<Product> products) {
  final Map<Category, List<Product>> categorizedProducts = {};
  for (var product in products) {
    final category = Category(
        id: product.categoryId ?? '', name: product.categoryName ?? '');
    if (categorizedProducts.containsKey(category)) {
      categorizedProducts[category]!.add(product);
    } else {
      categorizedProducts[category] = [product];
    }
  }
  return categorizedProducts;
}

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository productRepository;

  ProductCubit()
      : productRepository = getIt<ProductRepository>(),
        super(ProductInitial());

  Future<void> fetchProducts(String userId) async {
    try {
      final Either<ApiError, List<Product>> result =
          await productRepository.fetchProducts(userId);
      result.fold(
        (error) => emit(ProductError(state.categorizedProducts,
            error.message ?? 'Error fetching products')),
        (products) {
          final categorized = _categorizeProducts(products);
          emit(ProductLoaded(categorized));
        },
      );
    } catch (e) {
      emit(ProductError(state.categorizedProducts, e.toString()));
    }
  }

  Future<bool> addProduct(
    String name,
    double cost,
    String currency,
    String description,
    int quantity,
    String categoryId,
    List<File> images,
  ) async {
    try {
      emit(ProductLoading(state.categorizedProducts));
      final Either<ApiError, Product> result =
          await productRepository.addProduct(
              name, cost, currency, description, quantity, categoryId, images);
      bool success = false;
      result.fold(
        (error) => emit(CreateProductError(state.categorizedProducts,
            error.message ?? 'Error creating new product')),
        (newProduct) {
          success = true;
          final updatedProducts = [
            ...state.categorizedProducts.values.expand((list) => list),
            newProduct
          ];
          final categorized = _categorizeProducts(updatedProducts);
          emit(ProductSuccess(categorized, "New product added"));
        },
      );
      return success;
    } catch (e) {
      emit(CreateProductError(state.categorizedProducts, e.toString()));
      return false;
    }
  }

  Future<void> updateProduct(
    String productId,
    String name,
    double? cost,
    String? currency,
    String? description,
    int? quantity,
    String? categoryId,
    List<File>? newImages,
    List<String>? removeImageFilenames,
  ) async {
    try {
      final Either<ApiError, Product> result =
          await productRepository.updateProduct(
        productId,
        name,
        cost,
        currency,
        description,
        quantity,
        categoryId,
        newImages,
        removeImageFilenames,
      );
      result.fold(
        (error) => emit(ProductError(state.categorizedProducts,
            error.message ?? 'Error updating product')),
        (updatedProduct) {
          final updatedProducts = state.categorizedProducts.values
              .expand((list) => list)
              .map((p) => p.id == updatedProduct.id ? updatedProduct : p)
              .toList();
          final categorized = _categorizeProducts(updatedProducts);
          emit(ProductLoaded(categorized));
        },
      );
    } catch (e) {
      emit(ProductError(state.categorizedProducts, e.toString()));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      final Either<ApiError, void> result =
          await productRepository.deleteProduct(productId);
      result.fold(
        (error) => emit(ProductError(state.categorizedProducts,
            error.message ?? 'Error deleting product')),
        (_) {
          final updatedProducts = state.categorizedProducts.values
              .expand((list) => list)
              .where((product) => product.id != productId)
              .toList();
          final categorized = _categorizeProducts(updatedProducts);
          emit(ProductLoaded(categorized));
        },
      );
    } catch (e) {
      emit(ProductError(state.categorizedProducts, e.toString()));
    }
  }
}
