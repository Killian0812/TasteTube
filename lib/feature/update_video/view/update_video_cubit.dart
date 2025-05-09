import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/watch/domain/single_video_repo.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/feature/store/domain/product_repo.dart';
import 'package:taste_tube/feature/update_video/data/update_video_request.dart';
import 'package:taste_tube/core/injection.dart';

class UpdateVideoCubit extends Cubit<UpdateVideoState> {
  final SingleVideoRepository videoRepository;
  final ProductRepository productRepository;

  UpdateVideoCubit()
      : videoRepository = getIt(),
        productRepository = getIt(),
        super(UpdateVideoInitial());

  Future<void> fetchProducts(String userId) async {
    try {
      emit(UpdateVideoLoading());
      final result = await productRepository.fetchProducts(userId);
      result.fold(
        (error) => emit(
            UpdateVideoFailure(error.message ?? 'Error fetching products')),
        (products) => emit(UpdateVideoLoaded(availableProducts: products)),
      );
    } catch (e) {
      emit(UpdateVideoFailure(e.toString()));
    }
  }

  Future<void> updateVideo({
    required String videoId,
    String? title,
    String? description,
    List<String>? hashtags,
    List<String>? productIds,
    String? visibility,
  }) async {
    try {
      emit(UpdateVideoLoading());
      final result = await videoRepository.updateVideo(
        videoId,
        UpdateVideoRequest(
          title,
          description,
          hashtags,
          productIds,
          visibility,
        ),
      );
      result.fold(
        (error) =>
            emit(UpdateVideoFailure(error.message ?? 'Error updating video')),
        (success) => emit(UpdateVideoSuccess()),
      );
    } catch (e) {
      emit(UpdateVideoFailure(e.toString()));
    }
  }
}

abstract class UpdateVideoState {}

class UpdateVideoInitial extends UpdateVideoState {}

class UpdateVideoLoading extends UpdateVideoState {}

class UpdateVideoLoaded extends UpdateVideoState {
  final List<Product> availableProducts;

  UpdateVideoLoaded({required this.availableProducts});
}

class UpdateVideoSuccess extends UpdateVideoState {}

class UpdateVideoFailure extends UpdateVideoState {
  final String message;

  UpdateVideoFailure(this.message);
}
