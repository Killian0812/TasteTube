import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/splash/splash_page.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class ProfileSkeletonPage extends StatelessWidget {
  const ProfileSkeletonPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      if (context.mounted) {
        context.goNamed(
          'profile',
          pathParameters: {'userId': UserDataUtil.getUserId()},
        );
      }
    });

    return const SplashPage();
  }
}
