import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/product/data/product.dart';
import 'package:taste_tube/feature/product/domain/product_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class ProductState {
  final Map<String, List<Product>> categorizedProducts;

  ProductState(this.categorizedProducts);
}

class ProductInitial extends ProductState {
  ProductInitial() : super({});
}

class ProductLoading extends ProductState {
  ProductLoading(super.categorizedProducts);
}

class ProductLoaded extends ProductState {
  ProductLoaded(super.categorizedProducts);
}

class ProductError extends ProductState {
  final String message;

  ProductError(super.categorizedProducts, this.message);
}

Map<String, List<Product>> _categorizeProducts(List<Product> products) {
  final Map<String, List<Product>> categorizedProducts = {};
  for (var product in products) {
    final categoryId = product.categoryId ?? '';
    if (categorizedProducts.containsKey(categoryId)) {
      categorizedProducts[categoryId]!.add(product);
    } else {
      categorizedProducts[categoryId] = [product];
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

  Future<void> addProduct(
    String name,
    double cost,
    String currency,
    String description,
    int quantity,
    String categoryId,
    List<File> images,
  ) async {
    try {
      final Either<ApiError, Product> result =
          await productRepository.addProduct(
              name, cost, currency, description, quantity, categoryId, images);
      result.fold(
        (error) => emit(ProductError(state.categorizedProducts,
            error.message ?? 'Error creating new product')),
        (newProduct) {
          final updatedProducts = [
            ...state.categorizedProducts.values.expand((list) => list),
            newProduct
          ];
          final categorized = _categorizeProducts(updatedProducts);
          emit(ProductLoaded(categorized));
        },
      );
    } catch (e) {
      emit(ProductError(state.categorizedProducts, e.toString()));
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
