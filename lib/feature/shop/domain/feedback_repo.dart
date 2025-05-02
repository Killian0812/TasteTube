import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/product/feedback.dart';

class FeedbackResponse {
  final List<ProductFeedback> docs;
  final int page;
  final int totalPages;
  final int totalDocs;
  final bool hasNextPage;

  FeedbackResponse({
    required this.docs,
    required this.page,
    required this.totalPages,
    required this.totalDocs,
    required this.hasNextPage,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      docs: (json['docs'] as List)
          .map((feedback) => ProductFeedback.fromJson(feedback))
          .toList(),
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
      totalDocs: json['totalDocs'] as int,
      hasNextPage: json['hasNextPage'] as bool,
    );
  }
}

class FeedbackRepository {
  final Dio http;

  FeedbackRepository({required this.http});

  Future<Either<ApiError, ProductFeedback>> updateProductFeedback(
    ProductFeedback feedback,
  ) async {
    try {
      final response =
          await http.put(Api.productRatingFeedback, data: feedback.toJson());
      return Right(ProductFeedback.fromJson(response.data));
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, List<ProductFeedback>>> getOrderFeedbacks(
    String orderId,
  ) async {
    try {
      final response = await http.get(
        Api.orderFeedbacks.replaceFirst(':orderId', orderId),
      );
      final List<ProductFeedback> feedbacks = (response.data as List)
          .map((feedback) => ProductFeedback.fromJson(feedback))
          .toList();
      return Right(feedbacks);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }

  Future<Either<ApiError, FeedbackResponse>> getProductFeedbacks({
    required String productId,
    int page = 1,
    int limit = 5,
  }) async {
    try {
      final response = await http.get(
        Api.productFeedbacks.replaceFirst(':productId', productId),
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      final feedbackResponse = FeedbackResponse.fromJson(response.data);
      return Right(feedbackResponse);
    } on DioException catch (e) {
      return Left(ApiError.fromDioException(e));
    } catch (e) {
      return Left(ApiError(500, e.toString()));
    }
  }
}
