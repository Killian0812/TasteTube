// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:logger/logger.dart';
// import 'package:taste_tube/auth/domain/auth_repo.dart';
// import 'package:taste_tube/common/toast.dart';
// import 'package:taste_tube/global_bloc/auth/bloc.dart';
// import 'package:taste_tube/injection.dart';

// import '../../../data/login_request.dart';

// class ProfileCubit extends Cubit<ProfileState> {
//   final AuthRepository repository;

//   ProfileCubit()
//       : repository = getIt<AuthRepository>(),
//         super(ProfileState(
//           fullname,
//           username,
//           bio,
//         ));

//   Future<void> fetchProducts(BuildContext context) async {
//     final request = LoginRequest(state.email, state.password);
//     final result = await repository.login(request);
//     result.match(
//       (apiError) {
//         ToastService.showToast(context, apiError.message!,
//             apiError.statusCode < 500 ? ToastType.warning : ToastType.error,
//             duration: const Duration(seconds: 4));
//         logger.e('Login failed: ${apiError.message}');
//       },
//       (response) {
//         ToastService.showToast(
//             context,
//             "Login successfully! Redirecting to home page...",
//             ToastType.success,
//             duration: const Duration(seconds: 4));
//         context.read<AuthBloc>().add(LoginEvent(AuthData(
//               accessToken: response.accessToken,
//               email: response.email,
//               username: response.username,
//               image: response.image,
//               userId: response.userId,
//             )));
//         context.go('/profile');
//         logger.i('Login successfully: ${response.accessToken}');
//       },
//     );
//   }
// }

// abstract class ProductState {}

// class ProductLoading extends ProductState {}

// class ProductInitialized extends ProductState {}

// class ProductError extends ProductState {
//   final String errorMessage;
//   ProductError(this.errorMessage);
// }
