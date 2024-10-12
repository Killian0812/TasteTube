import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/login_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/register_phone_or_email_page.dart';
import 'package:taste_tube/auth/view/register_page.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/injection.dart';

part 'router.dart';

void main() {
  injectDependencies();
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
            unselectedLabelColor: CommonColor.greyOutTextColor,
            labelStyle: CommonTextStyle.bold,
            unselectedLabelStyle: CommonTextStyle.boldItalic,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black),
          )),
    );
  }
}
