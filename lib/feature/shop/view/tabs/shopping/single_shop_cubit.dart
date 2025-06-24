import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/global_data/product/category.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/feature/shop/domain/shop_repo.dart';
import 'package:taste_tube/core/injection.dart';

Map<Category, List<Product>> _categorizeProducts(List<Product> products) {
  final Map<Category, List<Product>> categorizedProducts = {};
  for (var product in products) {
    final category = Category(
        id: product.categoryId ?? '', name: product.categoryName ?? '');
    if (categorizedProducts.containsKey(category)) {
      categorizedProducts[category]!.add(product);
    } else {
      categorizedProducts[category] = [product];
    }
  }
  return categorizedProducts;
}

abstract class SingleShopState {
  final Map<Category, List<Product>> products;
  final String? message;
  final Address? shopAddress;
  final double? distance;

  const SingleShopState(this.products,
      {this.shopAddress, this.message, this.distance});

  String get shopImage =>
      products.values.isNotEmpty ? products.values.first.first.userImage : '';
  String get shopName =>
      products.values.isNotEmpty ? products.values.first.first.username : '';
  String? get shopPhone =>
      products.values.isNotEmpty ? products.values.first.first.userPhone : null;
}

class SingleShopInitial extends SingleShopState {
  const SingleShopInitial() : super(const {});
}

class SingleShopLoading extends SingleShopState {
  const SingleShopLoading(super.products, {super.shopAddress, super.distance});
}

class SingleShopLoaded extends SingleShopState {
  const SingleShopLoaded(super.products, {super.shopAddress, super.distance});
}

class SingleShopError extends SingleShopState {
  final String error;

  const SingleShopError(super.products, this.error,
      {super.shopAddress, super.distance});
}

class SingleShopCubit extends Cubit<SingleShopState> {
  final String shopId;
  final ShopRepository shopRepository;

  SingleShopCubit(this.shopId)
      : shopRepository = getIt<ShopRepository>(),
        super(const SingleShopInitial());

  Future<void> getProducts() async {
    emit(const SingleShopLoading({}));
    try {
      final result = await shopRepository.getSingleShopProducts(shopId);
      result.fold(
        (error) => emit(SingleShopError(
          state.products,
          shopAddress: state.shopAddress,
          distance: state.distance,
          error.message ?? 'Error fetching recommended products',
        )),
        (response) => emit(SingleShopLoaded(
          _categorizeProducts(response.products),
          shopAddress: response.shopAddress,
          distance: response.distance,
        )),
      );
    } catch (e) {
      emit(SingleShopError(
        state.products,
        shopAddress: state.shopAddress,
        distance: state.distance,
        e.toString(),
      ));
    }
  }

  Future<void> searchProducts(String keyword) async {
    emit(SingleShopLoading(state.products, shopAddress: state.shopAddress));
    try {
      final result =
          await shopRepository.searchSingleShopProducts(shopId, keyword);
      result.fold(
        (error) => emit(SingleShopError(
          state.products,
          shopAddress: state.shopAddress,
          distance: state.distance,
          error.message ?? 'Error searching products',
        )),
        (products) => emit(SingleShopLoaded(
          _categorizeProducts(products),
          shopAddress: state.shopAddress,
          distance: state.distance,
        )),
      );
    } catch (e) {
      emit(SingleShopError(
        state.products,
        shopAddress: state.shopAddress,
        distance: state.distance,
        e.toString(),
      ));
    }
  }
}
