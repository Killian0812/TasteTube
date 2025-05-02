import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/shop/domain/feedback_repo.dart';
import 'package:taste_tube/global_data/product/feedback.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/global_data/user/user_basic.dart';
import 'package:taste_tube/utils/user_data.util.dart';

abstract class FeedbackState {
  final List<ProductFeedback> feedbacks;
  final bool hasMore;
  final int currentPage;
  final int totalPages;

  const FeedbackState({
    required this.feedbacks,
    this.hasMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
  });
}

class FeedbackInitial extends FeedbackState {
  FeedbackInitial() : super(feedbacks: [], hasMore: true);
}

class FeedbackLoading extends FeedbackState {
  const FeedbackLoading({
    required super.feedbacks,
    required super.hasMore,
    required super.currentPage,
    required super.totalPages,
  });
}

class FeedbackLoaded extends FeedbackState {
  const FeedbackLoaded({
    required super.feedbacks,
    required super.hasMore,
    required super.currentPage,
    required super.totalPages,
  });
}

class FeedbackSuccess extends FeedbackState {
  final String success;

  const FeedbackSuccess({
    required super.feedbacks,
    required this.success,
    required super.hasMore,
    required super.currentPage,
    required super.totalPages,
  });
}

class FeedbackError extends FeedbackState {
  final String error;

  const FeedbackError({
    required super.feedbacks,
    required this.error,
    required super.hasMore,
    required super.currentPage,
    required super.totalPages,
  });
}

class FeedbackCubit extends Cubit<FeedbackState> {
  final FeedbackRepository repository = getIt<FeedbackRepository>();
  final int _limit = 5;

  FeedbackCubit() : super(FeedbackInitial());

  Future<void> getProductFeedbacks(String productId) async {
    emit(FeedbackLoading(
      feedbacks: [],
      hasMore: true,
      currentPage: 1,
      totalPages: 1,
    ));
    try {
      final result = await repository.getProductFeedbacks(
          productId: productId, page: 1, limit: _limit);
      result.fold(
        (error) => emit(FeedbackError(
          feedbacks: [],
          error: error.message ?? 'Error fetching feedbacks',
          hasMore: false,
          currentPage: 1,
          totalPages: 1,
        )),
        (response) {
          emit(FeedbackLoaded(
            feedbacks: response.docs,
            hasMore: response.hasNextPage,
            currentPage: response.page,
            totalPages: response.totalPages,
          ));
        },
      );
    } catch (e) {
      emit(FeedbackError(
        feedbacks: [],
        error: e.toString(),
        hasMore: false,
        currentPage: 1,
        totalPages: 1,
      ));
    }
  }

  Future<void> loadSpecificPage(String productId, int page) async {
    if (state is FeedbackLoading) return;

    emit(FeedbackLoading(
      feedbacks: state.feedbacks,
      hasMore: state.hasMore,
      currentPage: state.currentPage,
      totalPages: state.totalPages,
    ));

    try {
      final result = await repository.getProductFeedbacks(
        productId: productId,
        page: page,
        limit: _limit,
      );
      result.fold(
        (error) => emit(FeedbackError(
          feedbacks: state.feedbacks,
          error: error.message ?? 'Error fetching page $page',
          hasMore: state.hasMore,
          currentPage: state.currentPage,
          totalPages: state.totalPages,
        )),
        (response) {
          emit(FeedbackLoaded(
            feedbacks: response.docs,
            hasMore: response.hasNextPage,
            currentPage: response.page,
            totalPages: response.totalPages,
          ));
        },
      );
    } catch (e) {
      emit(FeedbackError(
        feedbacks: state.feedbacks,
        error: e.toString(),
        hasMore: state.hasMore,
        currentPage: state.currentPage,
        totalPages: state.totalPages,
      ));
    }
  }

  Future<void> getOrderFeedbacks(String orderId) async {
    emit(FeedbackLoading(
      feedbacks: state.feedbacks,
      hasMore: state.hasMore,
      currentPage: state.currentPage,
      totalPages: state.totalPages,
    ));
    try {
      final result = await repository.getOrderFeedbacks(orderId);
      result.fold(
        (error) => emit(FeedbackError(
          feedbacks: state.feedbacks,
          error: error.message ?? 'Error fetching feedbacks',
          hasMore: state.hasMore,
          currentPage: state.currentPage,
          totalPages: state.totalPages,
        )),
        (feedbacks) {
          emit(FeedbackLoaded(
            feedbacks: feedbacks,
            hasMore: state.hasMore,
            currentPage: state.currentPage,
            totalPages: state.totalPages,
          ));
        },
      );
    } catch (e) {
      emit(FeedbackError(
        feedbacks: state.feedbacks,
        error: e.toString(),
        hasMore: state.hasMore,
        currentPage: state.currentPage,
        totalPages: state.totalPages,
      ));
    }
  }

  Future<void> updateProductFeedback({
    required String productId,
    required String orderId,
    required int rating,
    String? feedback,
  }) async {
    try {
      final result = await repository.updateProductFeedback(ProductFeedback(
        productId: productId,
        orderId: orderId,
        rating: rating,
        feedback: feedback,
        user: UserBasic(
          id: UserDataUtil.getUserId(),
          username: '',
          image: '',
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      result.fold(
        (error) => emit(FeedbackError(
          feedbacks: state.feedbacks,
          error: error.message ?? 'Error updating product feedback',
          hasMore: state.hasMore,
          currentPage: state.currentPage,
          totalPages: state.totalPages,
        )),
        (updatedFeedback) {
          final index = state.feedbacks.indexWhere(
              (f) => f.productId == productId && f.orderId == orderId);
          final updatedFeedbacks = List<ProductFeedback>.from(state.feedbacks);
          if (index == -1) {
            updatedFeedbacks.add(updatedFeedback);
          } else {
            updatedFeedbacks[index] = updatedFeedback;
          }
          emit(FeedbackSuccess(
            feedbacks: updatedFeedbacks,
            success: 'Feedback submitted',
            hasMore: state.hasMore,
            currentPage: state.currentPage,
            totalPages: state.totalPages,
          ));
        },
      );
    } catch (e) {
      emit(FeedbackError(
        feedbacks: state.feedbacks,
        error: e.toString(),
        hasMore: state.hasMore,
        currentPage: state.currentPage,
        totalPages: state.totalPages,
      ));
    }
  }
}
