import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/feature/shop/domain/shop_repo.dart';
import 'package:taste_tube/injection.dart';

abstract class ShopState {
  final List<Product> products;
  final String? message;

  const ShopState(this.products, {this.message});
}

class ShopInitial extends ShopState {
  const ShopInitial() : super(const []);
}

class ShopLoading extends ShopState {
  const ShopLoading(super.products);
}

class ShopLoaded extends ShopState {
  const ShopLoaded(super.products);
}

class ShopError extends ShopState {
  final String error;

  const ShopError(super.products, this.error) : super(message: error);
}

class ShopCubit extends Cubit<ShopState> {
  final ShopRepository shopRepository;

  ShopCubit()
      : shopRepository = getIt<ShopRepository>(),
        super(const ShopInitial());

  Future<void> getRecommendedProducts() async {
    emit(const ShopLoading([]));
    try {
      final Either<ApiError, List<Product>> result =
          await shopRepository.getRecommendedProducts();
      result.fold(
        (error) => emit(ShopError(
          state.products,
          error.message ?? 'Error fetching recommeded products',
        )),
        (products) => emit(ShopLoaded(products)),
      );
    } catch (e) {
      emit(ShopError(state.products, e.toString()));
    }
  }

  Future<void> searchProducts(String keyword) async {
    emit(ShopLoading(state.products));
    try {
      final Either<ApiError, List<Product>> result =
          await shopRepository.searchProducts(keyword);
      result.fold(
        (error) => emit(ShopError(
          state.products,
          error.message ?? 'Error searching products',
        )),
        (products) => emit(ShopLoaded(products)),
      );
    } catch (e) {
      emit(ShopError(state.products, e.toString()));
    }
  }
}
