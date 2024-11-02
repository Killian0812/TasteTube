import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/product/data/category.dart';

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
}
