import 'package:flutter/material.dart';
import 'package:taste_tube/feature/profile/view/profile_page.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class OwnerProfilePage extends StatelessWidget {
  const OwnerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = UserDataUtil.getUserId();

    return ProfilePage.provider(userId);
  }
}
