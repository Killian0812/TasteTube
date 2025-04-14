import 'dart:async';

import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/core/injection.dart';

class UserDataUtil {
  static AuthData? getUserData() {
    return getIt<AuthBloc>().state.data;
  }

  static String getUserId() {
    return getIt<AuthBloc>().state.data!.userId;
  }

  static String getUserRole() {
    return getIt<AuthBloc>().state.data!.role;
  }

  static String getCurrency() {
    return getIt<AuthBloc>().state.data!.currency;
  }

  static FutureOr<void> refreshData() async {
    getIt<CartCubit>().getCart();
    getIt<ContentCubit>().getFeeds();
    getIt<OrderCubit>().getOrders();
  }
}
