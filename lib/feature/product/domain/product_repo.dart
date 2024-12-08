import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/product/data/category.dart';
import 'package:taste_tube/feature/product/data/product.dart';

class ProductRepository {
  final Dio http;

  ProductRepository({required this.http});

  Future<Either<ApiError, List<Category>>> fetchCategories() async {
    try {
      final response = await http.get(Api.categoryApi);
      final List<dynamic> data = response.data;

      final categories = data.map((json) => Category.fromJson(json)).toList();
      return Right(categories);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Category>> addCategory(String name) async {
    try {
      final response = await http.post(Api.categoryApi, data: {'name': name});

      final category = Category.fromJson(response.data);
      return Right(category);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Category>> updateCategory(
      String id, String name) async {
    try {
      final response = await http.put('${Api.categoryApi}/$id', data: {
        'name': name,
      });

      final category = Category.fromJson(response.data);
      return Right(category);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, void>> deleteCategory(String id) async {
    try {
      await http.delete('${Api.categoryApi}/$id');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<Product>>> fetchProducts(String userId) async {
    try {
      final response = await http.get(Api.productApi, queryParameters: {
        'userId': userId,
      });
      final List<dynamic> data = response.data;
      final products = data.map((json) => Product.fromJson(json)).toList();
      return Right(products);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Product>> fetchProductById(String productId) async {
    try {
      final response = await http.get('${Api.productApi}/$productId');
      final product = Product.fromJson(response.data);
      return Right(product);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Product>> addProduct(
    String name,
    double cost,
    String currency,
    bool ship,
    String description,
    int quantity,
    String categoryId,
    List<File> images,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'cost': cost,
        'currency': currency,
        'ship': ship,
        'description': description,
        'quantity': quantity,
        'category': categoryId,
        'images': images
            .map((image) => MultipartFile.fromFileSync(image.path))
            .toList(),
      });

      final response = await http.post(Api.productApi, data: formData);
      final product = Product.fromJson(response.data);
      return Right(product);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, Product>> updateProduct(
    Product product,
    String? name,
    double? cost,
    String? currency,
    bool? ship,
    String? description,
    int? quantity,
    String? categoryId,
    List<File>? newImages,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'cost': cost,
        'currency': currency,
        'ship': ship,
        'description': description,
        'quantity': quantity,
        'category': categoryId,
        if (newImages != null)
          'images': newImages
              .map((image) => MultipartFile.fromFileSync(image.path))
              .toList(),
        'reordered_images': product.images
            .map((image) => {
                  'url': image.url,
                  'filename': image.filename,
                })
            .toList()
      });

      final response =
          await http.put('${Api.productApi}/${product.id}', data: formData);
      final updatedProduct = Product.fromJson(response.data);
      return Right(updatedProduct);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, void>> deleteProduct(String productId) async {
    try {
      await http.delete('${Api.productApi}/$productId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, void>> deleteSingleProductImage(
      String productId, String filename) async {
    try {
      await http.delete('${Api.productApi}/$productId/image',
          data: {'filename': filename});
      return const Right(null);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
