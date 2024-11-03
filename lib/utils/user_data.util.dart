import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/global_bloc/auth/bloc.dart';

class UserDataUtil {
  static String getUserId(BuildContext context) {
    return context.read<AuthBloc>().state.data!.userId;
  }
}
