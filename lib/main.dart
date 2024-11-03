import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/login_page.dart';
import 'package:taste_tube/auth/view/register_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_phone_or_email_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/register_phone_or_email_page.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/fallback.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/feature/record/camera/camera_page.dart';
import 'package:taste_tube/feature/home/view/home_page.dart';
import 'package:taste_tube/feature/inbox/view/inbox_page.dart';
import 'package:taste_tube/feature/profile/view/profile_page.dart';
import 'package:taste_tube/feature/product/view/product_page.dart';
import 'package:taste_tube/feature/watch/video.dart';
import 'package:taste_tube/feature/watch/watch_page.dart';
import 'package:taste_tube/firebase_options.dart';
import 'package:taste_tube/global_bloc/auth/bloc.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/splash/splash_page.dart';

part 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  injectDependencies();
  await Fallback.prepareFallback();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((firebaseApp) {});
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    CommonSize.initScreenSize(context);

    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp.router(
        title: 'TasteTube',
        routerConfig: _router,
        theme: ThemeData.light().copyWith(
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Ganh'),
          scaffoldBackgroundColor: Colors.white,
          textSelectionTheme:
              const TextSelectionThemeData(cursorColor: Colors.black),
          tabBarTheme: const TabBarTheme(
            labelColor: Colors.black,
            unselectedLabelColor: CommonColor.greyOutTextColor,
            labelStyle: CommonTextStyle.bold,
            unselectedLabelStyle: CommonTextStyle.boldItalic,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            unselectedItemColor: Colors.black,
            selectedItemColor: CommonColor.activeBgColor,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class Layout extends StatelessWidget {
  final int currentIndex;
  final StatefulNavigationShell shell;

  const Layout({
    super.key,
    required this.currentIndex,
    required this.shell,
  });

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).fullPath;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: shell,
        bottomNavigationBar: noBottomNavBarRoutes.contains(path)
            ? null
            : BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  shell.goBranch(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.restaurant_menu),
                    label: 'Product',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inbox),
                    label: 'Inbox',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
            margin: const EdgeInsets.only(top: 20),
            child: FloatingActionButton(
              onPressed: () {
                context.push('/camera');
              },
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: CommonColor.activeBgColor),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: const Icon(Icons.add, color: CommonColor.activeBgColor),
            )));
  }
}

const List<String> noBottomNavBarRoutes = [
  '/camera',
];
