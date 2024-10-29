import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/feature/profile/view/profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Widget provider(String userId) => BlocProvider<ProfileCubit>(
        create: (context) => ProfileCubit(userId)..init(),
        child: const ProfilePage(),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileSuccess) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(state.user.username),
            ),
          );
        }
        return Center(child: FloatingActionButton(onPressed: () {
          final cubit = context.read<ProfileCubit>();
          cubit.init();
        }));
        // return const Center(child: CommonLoadingIndicator.regular);
      },
    );
  }
}
