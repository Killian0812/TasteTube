import 'package:taste_tube/global_bloc/auth/bloc.dart';
import 'package:taste_tube/injection.dart';

class UserDataUtil {
  static String getUserId() {
    return getIt<AuthBloc>().state.data!.userId;
  }

  static String getUserRole() {
    return getIt<AuthBloc>().state.data!.role;
  }
}
