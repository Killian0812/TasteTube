import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/feature/store/data/shop_analytics.dart';
import 'package:taste_tube/feature/store/domain/analytic_repo.dart';

abstract class ShopAnalyticState {}

class ShopAnalyticInitial extends ShopAnalyticState {}

class ShopAnalyticLoading extends ShopAnalyticState {}

class ShopAnalyticLoaded extends ShopAnalyticState {
  final ShopAnalytics analytics;
  ShopAnalyticLoaded(this.analytics);
}

class ShopAnalyticError extends ShopAnalyticState {
  final String message;
  ShopAnalyticError(this.message);
}

class ShopAnalyticCubit extends Cubit<ShopAnalyticState> {
  final AnalyticRepository analyticRepository = getIt<AnalyticRepository>();
  final String shopId;
  ShopAnalyticCubit({required this.shopId}) : super(ShopAnalyticInitial());

  Future<void> fetchAnalytics() async {
    try {
      emit(ShopAnalyticLoading());
      final response = await analyticRepository.fetchAnalytics(shopId);
      response.fold(
        (error) => emit(ShopAnalyticError(error.message!)),
        (analytics) => emit(ShopAnalyticLoaded(analytics)),
      );
    } catch (e) {
      emit(ShopAnalyticError(e.toString()));
    }
  }
}
