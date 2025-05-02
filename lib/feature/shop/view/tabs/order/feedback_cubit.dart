import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/shop/domain/feedback_repo.dart';
import 'package:taste_tube/global_data/order/feedback.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/utils/user_data.util.dart';

abstract class FeedbackState {
  final List<Feedback> feedbacks;

  const FeedbackState({required this.feedbacks});
}

class FeedbackInitial extends FeedbackState {
  FeedbackInitial() : super(feedbacks: []);
}

class FeedbackLoading extends FeedbackState {
  const FeedbackLoading(List<Feedback> feedbacks) : super(feedbacks: feedbacks);
}

class FeedbackLoaded extends FeedbackState {
  const FeedbackLoaded(List<Feedback> feedbacks) : super(feedbacks: feedbacks);
}

class FeedbackSuccess extends FeedbackState {
  final String success;

  const FeedbackSuccess(List<Feedback> feedbacks, this.success)
      : super(feedbacks: feedbacks);
}

class FeedbackError extends FeedbackState {
  final String error;

  const FeedbackError(List<Feedback> feedbacks, this.error)
      : super(feedbacks: feedbacks);
}

class FeedbackCubit extends Cubit<FeedbackState> {
  final FeedbackRepository repository = getIt<FeedbackRepository>();

  FeedbackCubit() : super(FeedbackInitial());

  Future<void> getOrderFeedbacks(String orderId) async {
    emit(FeedbackLoading(state.feedbacks));
    try {
      final result = await repository.getOrderFeedbacks(orderId);
      result.fold(
        (error) => emit(FeedbackError(
          state.feedbacks,
          error.message ?? 'Error fetching feedbacks',
        )),
        (feedbacks) {
          emit(FeedbackLoaded(feedbacks));
        },
      );
    } catch (e) {
      emit(FeedbackError(state.feedbacks, e.toString()));
    }
  }

  Future<void> updateProductFeedback({
    required String productId,
    required String orderId,
    required int rating,
    String? feedback,
  }) async {
    try {
      final result = await repository.updateProductFeedback(Feedback(
        productId: productId,
        orderId: orderId,
        rating: rating,
        feedback: feedback,
        userId: UserDataUtil.getUserId(),
      ));
      result.fold(
        (error) => emit(FeedbackError(
          state.feedbacks,
          error.message ?? 'Error updating product feedback',
        )),
        (updatedFeedback) {
          final index =
              state.feedbacks.indexWhere((f) => f.productId == productId);
          if (index == -1) {
            state.feedbacks.add(updatedFeedback);
          } else {
            state.feedbacks[index] = updatedFeedback;
          }
          emit(FeedbackSuccess(state.feedbacks, 'Feedback submitted'));
        },
      );
    } catch (e) {
      emit(FeedbackError(state.feedbacks, e.toString()));
    }
  }
}
