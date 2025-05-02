import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart' as fpdart;
import 'package:taste_tube/api.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/order/feedback.dart';

class FeedbackRepository {
  final Dio http;

  FeedbackRepository({required this.http});

  Future<fpdart.Either<ApiError, Feedback>> updateProductFeedback(
    Feedback feedback,
  ) async {
    try {
      final response =
          await http.put(Api.productRatingFeedback, data: feedback.toJson());
      return fpdart.Right(Feedback.fromJson(response.data));
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }

  Future<fpdart.Either<ApiError, List<Feedback>>> getOrderFeedbacks(
    String orderId,
  ) async {
    try {
      final response = await http.get(
        Api.orderFeedbacks.replaceFirst(':orderId', orderId),
      );
      final List<Feedback> feedbacks = (response.data as List)
          .map((feedback) => Feedback.fromJson(feedback))
          .toList();
      return fpdart.Right(feedbacks);
    } on DioException catch (e) {
      return fpdart.Left(ApiError.fromDioException(e));
    } catch (e) {
      return fpdart.Left(ApiError(500, e.toString()));
    }
  }
}
