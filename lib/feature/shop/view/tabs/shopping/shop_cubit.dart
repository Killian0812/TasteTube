import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/shop/data/shop_response.dart';
import 'package:taste_tube/global_data/pagination.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/feature/shop/domain/shop_repo.dart';
import 'package:taste_tube/core/injection.dart';

abstract class ShopState {
  final List<Product> products;
  final String? message;
  final Pagination pagination;

  const ShopState(this.products, {this.message, required this.pagination});
}

class ShopInitial extends ShopState {
  const ShopInitial()
      : super(
          const [],
          pagination: const Pagination(
            totalDocs: 0,
            limit: 10,
            page: 1,
            totalPages: 1,
            hasNextPage: false,
            hasPrevPage: false,
            nextPage: null,
            prevPage: null,
          ),
        );
}

class ShopLoading extends ShopState {
  const ShopLoading(
    super.products, {
    required super.pagination,
  });
}

class ShopLoaded extends ShopState {
  const ShopLoaded(
    super.products, {
    required super.pagination,
  });
}

class ShopError extends ShopState {
  final String error;

  const ShopError(
    super.products,
    this.error, {
    required super.pagination,
  }) : super(message: error);
}

class ShopCubit extends Cubit<ShopState> {
  final ShopRepository shopRepository;

  ShopCubit()
      : shopRepository = getIt<ShopRepository>(),
        super(const ShopInitial());

  Future<void> getRecommendedProducts({
    int page = 1,
    int limit = 10,
    bool loadMore = false,
    ProductOrderBy orderBy = ProductOrderBy.distance,
  }) async {
    emit(ShopLoading(
      loadMore ? state.products : [],
      pagination: state.pagination,
    ));
    try {
      final result = await shopRepository.getRecommendedProducts(
        page: page,
        limit: limit,
        orderBy: orderBy.value,
      );
      result.fold(
        (error) => emit(ShopError(
          state.products,
          error.message ?? 'Error fetching recommended products',
          pagination: state.pagination,
        )),
        (response) => emit(ShopLoaded(
          loadMore
              ? [...state.products, ...response.products]
              : response.products,
          pagination: response.pagination,
        )),
      );
    } catch (e) {
      emit(ShopError(
        state.products,
        e.toString(),
        pagination: state.pagination,
      ));
    }
  }

  Future<void> searchProducts({
    required String keyword,
    int page = 1,
    int limit = 10,
    bool loadMore = false,
    ProductOrderBy orderBy = ProductOrderBy.newest,
  }) async {
    emit(ShopLoading(
      loadMore ? state.products : [],
      pagination: state.pagination,
    ));
    try {
      final result = await shopRepository.searchProducts(
        keyword,
        page: page,
        limit: limit,
        orderBy: orderBy.value,
      );
      result.fold(
        (error) => emit(ShopError(
          state.products,
          error.message ?? 'Error searching products',
          pagination: state.pagination,
        )),
        (response) => emit(ShopLoaded(
          loadMore
              ? [...state.products, ...response.products]
              : response.products,
          pagination: response.pagination,
        )),
      );
    } catch (e) {
      emit(ShopError(
        state.products,
        e.toString(),
        pagination: state.pagination,
      ));
    }
  }
}
