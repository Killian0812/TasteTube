import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/login_page.dart';
import 'package:taste_tube/auth/view/register_page.dart';
import 'package:taste_tube/common/color.dart';

import 'auth/view/phone_or_email/login_phone_or_email_page.dart';
import 'common/text.dart';

part 'router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TasteTube',
      routerConfig: _router,
      theme: ThemeData.light().copyWith(
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Ganh'),
          scaffoldBackgroundColor: Colors.white,
          textSelectionTheme:
              const TextSelectionThemeData(cursorColor: Colors.red),
          tabBarTheme: TabBarTheme(
            labelColor: Colors.black,
            unselectedLabelColor: CustomColor.greyOutTextColor,
            labelStyle: CustomTextStyle.bold,
            unselectedLabelStyle: CustomTextStyle.boldItalic,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black),
          )),
    );
  }
}
