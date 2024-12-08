import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/feature/product/data/category.dart';
import 'package:taste_tube/feature/product/data/product.dart';
import 'package:taste_tube/feature/shop/domain/shop_repo.dart';
import 'package:taste_tube/injection.dart';
import 'package:url_launcher/url_launcher.dart';

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

  const SingleShopState(this.products, {this.message});
}

class SingleShopInitial extends SingleShopState {
  const SingleShopInitial() : super(const {});
}

class SingleShopLoading extends SingleShopState {
  const SingleShopLoading(super.products);
}

class SingleShopLoaded extends SingleShopState {
  const SingleShopLoaded(super.products);
}

class SingleShopError extends SingleShopState {
  final String error;

  const SingleShopError(super.products, this.error) : super(message: error);
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
      final Either<ApiError, List<Product>> result =
          await shopRepository.getSingleShopProducts(shopId);
      result.fold(
        (error) => emit(SingleShopError(
          state.products,
          error.message ?? 'Error fetching recommeded products',
        )),
        (products) => emit(SingleShopLoaded(_categorizeProducts(products))),
      );
    } catch (e) {
      emit(SingleShopError(state.products, e.toString()));
    }
  }

  Future<void> searchProducts(String keyword) async {
    emit(SingleShopLoading(state.products));
    try {
      final Either<ApiError, List<Product>> result =
          await shopRepository.searchSingleShopProducts(shopId, keyword);
      result.fold(
        (error) => emit(SingleShopError(
          state.products,
          error.message ?? 'Error searching products',
        )),
        (products) => emit(SingleShopLoaded(_categorizeProducts(products))),
      );
    } catch (e) {
      emit(SingleShopError(state.products, e.toString()));
    }
  }

  Future<void> makePhoneCall(String phone) async {
    Uri url = Uri(scheme: "tel", path: phone);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      return;
    }
  }
}
