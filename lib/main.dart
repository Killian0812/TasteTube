import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/login_page.dart';
import 'package:taste_tube/auth/view/register_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_phone_or_email_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/register_phone_or_email_page.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/fallback.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/feature/profile/view/owner_profile_page.dart';
import 'package:taste_tube/feature/shop/view/cart_page.dart';
import 'package:taste_tube/feature/shop/view/shop_page.dart';
import 'package:taste_tube/global_bloc/download/download_dialog.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/feature/record/camera/camera_page.dart';
import 'package:taste_tube/feature/home/view/home_page.dart';
import 'package:taste_tube/feature/inbox/view/inbox_page.dart';
import 'package:taste_tube/feature/profile/view/profile_page.dart';
import 'package:taste_tube/feature/store/view/store_page.dart';
import 'package:taste_tube/feature/search/view/search_page.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_page.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/view/watch_page.dart';
import 'package:taste_tube/firebase_options.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/providers.dart';
import 'package:taste_tube/splash/initial_page.dart';
import 'package:taste_tube/splash/splash_page.dart';

part 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  injectDependencies();

  await Fallback.prepareFallback();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((firebaseApp) {
    getIt.registerSingleton<FirebaseApp>(firebaseApp);
  });

  if (kIsWeb) {
    // Initialize the Facebook javascript SDK on web
    // can test using http but only usable on https
    await FacebookAuth.instance.webAndDesktopInitialize(
      appId: "1491676648196782",
      cookie: true,
      xfbml: true,
      version: "v21.0", // API version Acquired from Meta Developers
    );
  }

  // Must have for route push() to reflect defined url
  GoRouter.optionURLReflectsImperativeAPIs = true;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    CommonSize.initScreenSize(context);

    return TasteTubeProvider(
      child: AnimatedBuilder(
        animation: getIt<AppSettings>(),
        builder: (context, snapshot) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
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
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              textTheme: Theme.of(context)
                  .textTheme
                  .apply(fontFamily: 'Ganh', bodyColor: Colors.white),
              scaffoldBackgroundColor: Colors.black,
              textSelectionTheme:
                  const TextSelectionThemeData(cursorColor: Colors.white),
              tabBarTheme: const TabBarTheme(
                labelColor: Colors.white,
                unselectedLabelColor: CommonColor.greyOutTextColor,
                labelStyle: CommonTextStyle.bold,
                unselectedLabelStyle: CommonTextStyle.boldItalic,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                unselectedItemColor: Colors.white,
                selectedItemColor: CommonColor.activeBgColor,
                selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Color.fromARGB(255, 20, 18, 24),
              ),
            ),
            themeMode: getIt<AppSettings>().getTheme,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown
              },
            ),
          );
        },
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
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        }
      },
      builder: (context, state) {
        if (state is! Authenticated) {
          final currentRoute = GoRouterState.of(context).matchedLocation;
          return InitialPage(redirect: currentRoute);
        }
        final isCustomer = state.data.role == "CUSTOMER";
        return Stack(
          alignment: Alignment.center,
          children: [
            Scaffold(
                resizeToAvoidBottomInset: false,
                body: shell,
                bottomNavigationBar: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    final appSettings = getIt<AppSettings>();
                    if (index == 0 && appSettings.getTheme != ThemeMode.dark) {
                      appSettings.setTheme(ThemeMode.dark);
                    } else if (appSettings.getTheme != ThemeMode.light) {
                      appSettings.setTheme(ThemeMode.light);
                    }

                    if (index == 1 && isCustomer) {
                      context.go('/shop');
                      return;
                    }
                    shell.goBranch(index);
                  },
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    isCustomer
                        ? const BottomNavigationBarItem(
                            icon: Icon(Icons.shopping_basket_rounded),
                            label: 'Shopping',
                          )
                        : const BottomNavigationBarItem(
                            icon: Icon(Icons.store),
                            label: 'Store',
                          ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.inbox),
                      label: 'Inbox',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: FloatingActionButton(
                      onPressed: () {
                        context.push('/camera');
                      },
                      shape: RoundedRectangleBorder(
                        side:
                            const BorderSide(color: CommonColor.activeBgColor),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: const Icon(Icons.add,
                          color: CommonColor.activeBgColor),
                    ))),
            DownloadDialog(),
          ],
        );
      },
    );
  }
}
