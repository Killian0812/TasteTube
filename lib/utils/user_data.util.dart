import 'dart:async';

import 'package:taste_tube/auth/data/login_response.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/injection.dart';

class UserDataUtil {
  static String getUserId() {
    return getIt<AuthBloc>().state.data!.userId;
  }

  static String getUserRole() {
    return getIt<AuthBloc>().state.data!.role;
  }

  static void initUser(LoginResponse response) {
    getIt<AuthBloc>().add(LoginEvent(
      AuthData(
        accessToken: response.accessToken,
        email: response.email,
        username: response.username,
        image: response.image,
        userId: response.userId,
        role: response.role,
      ),
      response.refreshToken,
    ));
  }

  static FutureOr<void> refreshData() async {
    getIt<CartCubit>().getCart();
    getIt<ContentCubit>().getFeeds();
    getIt<OrderCubit>().getOrders();
  }
}
