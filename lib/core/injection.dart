import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/auth/view/oauth/oauth_cubit.dart';
import 'package:taste_tube/feature/home/domain/content_repo.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/payment/domain/payment_repo.dart';
import 'package:taste_tube/feature/shop/domain/order_delivery_repo.dart';
import 'package:taste_tube/feature/store/domain/delivery_option_repo.dart';
import 'package:taste_tube/feature/store/domain/payment_setting_repo.dart';
import 'package:taste_tube/feature/store/domain/product_repo.dart';
import 'package:taste_tube/feature/profile/domain/profile_repo.dart';
import 'package:taste_tube/feature/search/domain/search_repo.dart';
import 'package:taste_tube/feature/shop/domain/address_repo.dart';
import 'package:taste_tube/feature/shop/domain/order_repo.dart';
import 'package:taste_tube/feature/shop/domain/shop_repo.dart';
import 'package:taste_tube/feature/store/domain/voucher_repo.dart';
import 'package:taste_tube/feature/upload/domain/upload_repo.dart';
import 'package:taste_tube/feature/watch/domain/single_video_repo.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/download/download_cubit.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/global_bloc/realtime/realtime_provider.dart';
import 'package:taste_tube/global_repo/cart_repo.dart';
import 'package:taste_tube/core/providers.dart';
import 'package:taste_tube/core/storage.dart';
import 'package:uuid/uuid.dart';

import '../auth/domain/auth_repo.dart';

final getIt = GetIt.instance;

void injectDependencies() {
  // App core instances
  getIt.registerLazySingleton<AppSettings>(() => AppSettings());
  getIt.registerLazySingleton(() => BottomNavigationBarToggleNotifier());
  getIt.registerLazySingleton<Logger>(() => Logger());
  getIt.registerLazySingleton<Dio>(() => Dio(
        BaseOptions(
          baseUrl: '${Api.baseUrl}/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'ngrok-skip-browser-warning': true, // Bypass ngrok warning
          },
        ),
      ));
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage());
  getIt.registerLazySingleton<Uuid>(() => const Uuid());
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(scopes: [
        'email',
        'https://www.googleapis.com/auth/contacts.readonly',
      ]));

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(
        secureStorage: getIt(),
        http: getIt(),
      ));
  getIt.registerLazySingleton<UploadRepository>(
      () => UploadRepository(http: getIt()));
  getIt.registerLazySingleton<UserRepository>(
      () => UserRepository(http: getIt()));
  getIt.registerLazySingleton<ProductRepository>(
      () => ProductRepository(http: getIt()));
  getIt.registerLazySingleton<SingleVideoRepository>(
      () => SingleVideoRepository(http: getIt()));
  getIt.registerLazySingleton<SearchRepository>(
      () => SearchRepository(http: getIt()));
  getIt.registerLazySingleton<AddressRepository>(
      () => AddressRepository(http: getIt()));
  getIt.registerLazySingleton<ShopRepository>(
      () => ShopRepository(http: getIt()));
  getIt.registerLazySingleton<OrderRepository>(
      () => OrderRepository(http: getIt()));
  getIt.registerLazySingleton<CartRepository>(
      () => CartRepository(http: getIt()));
  getIt.registerLazySingleton<ContentRepository>(
      () => ContentRepository(http: getIt()));
  getIt.registerLazySingleton<PaymentRepository>(
      () => PaymentRepository(http: getIt()));
  getIt.registerLazySingleton<PaymentSettingRepository>(
      () => PaymentSettingRepository(http: getIt()));
  getIt.registerLazySingleton<DeliveryOptionRepository>(
      () => DeliveryOptionRepository(http: getIt()));
  getIt.registerLazySingleton<OrderDeliveryRepository>(
      () => OrderDeliveryRepository(http: getIt()));
  getIt.registerLazySingleton<VoucherRepository>(
      () => VoucherRepository(http: getIt()));

  // Global blocs / cubits
  getIt.registerSingleton<AuthBloc>(AuthBloc());
  getIt.registerSingleton<OAuthCubit>(OAuthCubit());
  getIt.registerSingleton<RealtimeProvider>(RealtimeProvider());
  getIt.registerSingleton<CartCubit>(CartCubit());
  getIt.registerSingleton<OrderCubit>(OrderCubit());
  getIt.registerSingleton<ContentCubit>(ContentCubit());
  getIt.registerSingleton<DownloadCubit>(DownloadCubit());
  getIt.registerSingleton<GetstreamCubit>(GetstreamCubit());
}
