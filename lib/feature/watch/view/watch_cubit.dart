// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:fpdart/fpdart.dart';
// import 'package:taste_tube/common/error.dart';
// import 'package:taste_tube/feature/product/data/product.dart';
// import 'package:taste_tube/feature/profile/data/user.dart';
// import 'package:taste_tube/feature/watch/data/video_comment.dart';
// import 'package:taste_tube/feature/watch/data/video.dart';
// import 'package:taste_tube/injection.dart';

// abstract class WatchState {
//   final int likes;
//   final bool userLiked;
//   final List<Comment> comments;

//   WatchState(this.likes, this.userLiked, this.comments);
// }

// class WatchInitial extends WatchState {
//   WatchInitial(super.likes, super.userLiked, super.comments);
// }

// class WatchLoading extends WatchState {
//   WatchLoading(super.likes, super.userLiked, super.comments);
// }

// class WatchSuccess extends WatchState {
//   final String message;

//   WatchSuccess(super.likes, super.userLiked, super.comments, this.message);
// }

// class WatchLoaded extends WatchState {
//   WatchLoaded(super.likes, super.userLiked, super.comments);
// }

// class WatchError extends WatchState {
//   final String message;

//   WatchError(super.likes, super.userLiked, super.comments, this.message);
// }

// class WatchCubit extends Cubit<WatchState> {
//   final Video video;
//   final User owner;
//   // final WatchRepository watchRepository;

//   WatchCubit(this.owner, this.video)
//       : super(WatchInitial(
//         video.likes,
//         false,
//         []
//       ));

//   Future<void> fetchDependency() async {
//     try {
//       final Either<ApiError, List<Product>> result =
//           await productRepository.fetchProducts(userId);
//       result.fold(
//         (error) => emit(ProductError(state.categorizedProducts,
//             error.message ?? 'Error fetching products')),
//         (products) {
//           final categorized = _categorizeProducts(products);
//           emit(ProductLoaded(categorized));
//         },
//       );
//     } catch (e) {
//       emit(ProductError(state.categorizedProducts, e.toString()));
//     }
//   }
// }
