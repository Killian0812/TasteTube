import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class OwnerProfilePage extends StatelessWidget {
  const OwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = UserDataUtil.getUserId();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/user/$userId');
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
