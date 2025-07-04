import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/product/category.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/feature/store/domain/product_repo.dart';
import 'package:taste_tube/core/injection.dart';

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

class ProductDeleted extends ProductState {
  final String message;

  ProductDeleted(super.categorizedProducts, this.message);
}

class CreateOrUpdateProductError extends ProductState {
  final String message;

  CreateOrUpdateProductError(super.categorizedProducts, this.message);
}

class CreateOrUpdateProductSuccess extends ProductState {
  final String message;

  CreateOrUpdateProductSuccess(super.categorizedProducts, this.message);
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

  Future<void> addOrEditProduct({
    required String name,
    required double cost,
    required String currency,
    required bool ship,
    required String description,
    required int quantity,
    required String categoryId,
    required List<XFile> images,
    required int? prepTime,
    List<SizeOption> sizes = const [],
    List<ToppingOption> toppings = const [],
    Product? product,
  }) async {
    try {
      emit(ProductLoading(state.categorizedProducts));
      bool isNew = product == null;

      final Either<ApiError, Product> result = isNew
          ? await productRepository.addProduct(
              name: name,
              cost: cost,
              currency: currency,
              ship: ship,
              description: description,
              quantity: quantity,
              categoryId: categoryId,
              images: images,
              prepTime: prepTime,
              sizes: sizes,
              toppings: toppings,
            )
          : await productRepository.updateProduct(
              product,
              name: name,
              cost: cost,
              currency: currency,
              ship: ship,
              description: description,
              quantity: quantity,
              categoryId: categoryId,
              newImages: images,
              prepTime: prepTime,
              sizes: sizes,
              toppings: toppings,
            );

      result.fold(
        (error) => emit(CreateOrUpdateProductError(state.categorizedProducts,
            error.message ?? 'Error creating or updating product')),
        (newProduct) {
          final updatedProducts = [
            ...state.categorizedProducts.values.expand((list) => list),
          ];
          if (isNew) {
            updatedProducts.add(newProduct);
          } else {
            int index =
                updatedProducts.indexWhere((p) => p.id == newProduct.id);
            if (index != -1) {
              updatedProducts[index] = newProduct;
            }
          }
          final categorized = _categorizeProducts(updatedProducts);
          emit(CreateOrUpdateProductSuccess(
              categorized, isNew ? "New product added" : "Product updated"));
        },
      );
    } catch (e) {
      emit(CreateOrUpdateProductError(state.categorizedProducts, e.toString()));
    }
  }

  Future<void> deleteProduct(Product deleteProduct) async {
    try {
      final Either<ApiError, void> result =
          await productRepository.deleteProduct(deleteProduct.id);
      result.fold(
        (error) => emit(ProductError(state.categorizedProducts,
            error.message ?? 'Error deleting product')),
        (_) {
          final updatedProducts = state.categorizedProducts.values
              .expand((list) => list)
              .where((product) => product.id != deleteProduct.id)
              .toList();
          final categorized = _categorizeProducts(updatedProducts);
          emit(ProductDeleted(
              categorized, 'Deleted product ${deleteProduct.name}'));
        },
      );
    } catch (e) {
      emit(ProductError(state.categorizedProducts, e.toString()));
    }
  }

  Future<bool> deleteSingleProductImage(
      String productId, String filename) async {
    try {
      final Either<ApiError, void> result =
          await productRepository.deleteSingleProductImage(productId, filename);
      bool isDeleted = false;
      result.fold(
        (error) => emit(ProductError(state.categorizedProducts,
            error.message ?? 'Error deleting product image')),
        (_) {
          isDeleted = true;
          emit(ProductLoaded(state.categorizedProducts));
        },
      );
      return isDeleted;
    } catch (e) {
      emit(ProductError(state.categorizedProducts, e.toString()));
      return false;
    }
  }
}
