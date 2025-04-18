import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/feature/store/domain/discount_repo.dart';
import 'package:taste_tube/global_data/discount/discount.dart';
import 'package:taste_tube/utils/user_data.util.dart';

abstract class DiscountState {
  final List<Discount> discounts;
  DiscountState({required this.discounts});
}

class DiscountInitial extends DiscountState {
  DiscountInitial({required super.discounts});
}

class DiscountLoading extends DiscountState {
  DiscountLoading({required super.discounts});
}

class DiscountLoaded extends DiscountState {
  final String? message;

  DiscountLoaded(List<Discount> discounts, {this.message})
      : super(discounts: discounts);
}

class DiscountError extends DiscountState {
  final String message;

  DiscountError(List<Discount> discounts, this.message)
      : super(discounts: discounts);
}

class DiscountCubit extends Cubit<DiscountState> {
  final DiscountRepository repository = getIt<DiscountRepository>();

  DiscountCubit() : super(DiscountInitial(discounts: []));

  Future<void> fetchDiscounts() async {
    emit(DiscountLoading(discounts: state.discounts));
    final shopId = UserDataUtil.getUserId();
    final result = await repository.fetchDiscounts(shopId);
    result.fold(
      (error) => emit(DiscountError(
          state.discounts, error.message ?? 'Error loading discounts')),
      (discounts) => emit(DiscountLoaded(discounts)),
    );
  }

  Future<void> createDiscount(Discount discount) async {
    emit(DiscountLoading(discounts: state.discounts));
    final result = await repository.createDiscount(discount);
    result.fold(
      (error) => emit(DiscountError(
          state.discounts, error.message ?? 'Error creating discount')),
      (createdDiscount) async {
        await fetchDiscounts(); // Refresh discount list
        emit(DiscountLoaded(
          (state as DiscountLoaded?)?.discounts ?? [],
          message: 'Discount created successfully',
        ));
      },
    );
  }

  Future<void> updateDiscount(String discountId, Discount discount) async {
    emit(DiscountLoading(discounts: state.discounts));
    final result = await repository.updateDiscount(discountId, discount);
    result.fold(
      (error) => emit(DiscountError(
          state.discounts, error.message ?? 'Error updating discount')),
      (updatedDiscount) async {
        await fetchDiscounts(); // Refresh discount list
        emit(DiscountLoaded(
          (state as DiscountLoaded?)?.discounts ?? [],
          message: 'Discount updated successfully',
        ));
      },
    );
  }

  Future<void> deleteDiscount(String discountId) async {
    emit(DiscountLoading(discounts: state.discounts));
    final result = await repository.deleteDiscount(discountId);
    result.fold(
      (error) => emit(DiscountError(
          state.discounts, error.message ?? 'Error deleting discount')),
      (_) async {
        await fetchDiscounts(); // Refresh discount list
        emit(DiscountLoaded(
          (state as DiscountLoaded?)?.discounts ?? [],
          message: 'Discount deleted successfully',
        ));
      },
    );
  }

  Future<void> fetchAvailableDiscountsForCustomer(String shopId) async {
    emit(DiscountLoading(discounts: state.discounts));
    final result = await repository.fetchAvailableDiscountsForCustomer(shopId);
    result.fold(
      (error) => emit(DiscountError(
          state.discounts, error.message ?? 'Error loading discounts')),
      (discounts) => emit(DiscountLoaded(discounts)),
    );
  }

  Future<void> checkCouponDiscount(String shopId, String coupon) async {
    emit(DiscountLoading(discounts: state.discounts));
    final result = await repository.checkCouponDiscount(shopId, coupon);
    result.fold(
      (error) => emit(DiscountError(
          state.discounts, error.message ?? 'Error loading discounts')),
      (discount) => emit(DiscountLoaded([...state.discounts, discount])),
    );
  }
}
