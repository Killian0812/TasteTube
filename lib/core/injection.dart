import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/auth/view/oauth/oauth_cubit.dart';
import 'package:taste_tube/core/http_client.dart';
import 'package:taste_tube/feature/admin/user_management/user_management_cubit.dart';
import 'package:taste_tube/feature/admin/video_management/video_management_cubit.dart';
import 'package:taste_tube/feature/home/domain/content_repo.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/home/view/following_content_cubit.dart';
import 'package:taste_tube/feature/inbox/domain/chat_channel_repo.dart';
import 'package:taste_tube/feature/payment/domain/payment_repo.dart';
import 'package:taste_tube/feature/shop/domain/feedback_repo.dart';
import 'package:taste_tube/feature/shop/domain/order_delivery_repo.dart';
import 'package:taste_tube/feature/store/domain/analytic_repo.dart';
import 'package:taste_tube/feature/store/domain/delivery_option_repo.dart';
import 'package:taste_tube/feature/store/domain/payment_setting_repo.dart';
import 'package:taste_tube/feature/store/domain/product_repo.dart';
import 'package:taste_tube/feature/profile/domain/user_repo.dart';
import 'package:taste_tube/feature/shop/domain/address_repo.dart';
import 'package:taste_tube/feature/shop/domain/order_repo.dart';
import 'package:taste_tube/feature/shop/domain/shop_repo.dart';
import 'package:taste_tube/feature/store/domain/discount_repo.dart';
import 'package:taste_tube/feature/upload_video/domain/upload_repo.dart';
import 'package:taste_tube/feature/watch/domain/video_repo.dart';
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
  getIt.registerLazySingleton<Dio>(getHttpClient);
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
  getIt.registerLazySingleton<VideoRepository>(
      () => VideoRepository(http: getIt()));
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
  getIt.registerLazySingleton<DiscountRepository>(
      () => DiscountRepository(http: getIt()));
  getIt.registerLazySingleton<FeedbackRepository>(
      () => FeedbackRepository(http: getIt()));
  getIt.registerLazySingleton<AnalyticRepository>(
      () => AnalyticRepository(http: getIt()));
  getIt.registerLazySingleton<ChatChannelRepository>(
      () => ChatChannelRepository(http: getIt()));

  // Global blocs / cubits
  getIt
      .registerLazySingleton<AuthBloc>(() => AuthBloc()..add(CheckAuthEvent()));
  getIt.registerLazySingleton<OAuthCubit>(() => OAuthCubit());
  getIt.registerLazySingleton<RealtimeProvider>(() => RealtimeProvider());
  getIt.registerLazySingleton<CartCubit>(() => CartCubit());
  getIt.registerLazySingleton<OrderCubit>(() => OrderCubit());
  getIt.registerLazySingleton<ContentCubit>(() => ContentCubit());
  getIt.registerLazySingleton<FollowingContentCubit>(
      () => FollowingContentCubit());
  getIt.registerLazySingleton<DownloadCubit>(() => DownloadCubit());
  getIt.registerLazySingleton<GetstreamCubit>(() => GetstreamCubit());
  getIt.registerLazySingleton<UserManagementCubit>(() => UserManagementCubit());
  getIt.registerLazySingleton<VideoManagementCubit>(
      () => VideoManagementCubit());
}
