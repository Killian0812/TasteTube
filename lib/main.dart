import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/auth/view/login_page.dart';
import 'package:taste_tube/auth/view/register_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_phone_or_email_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/register_phone_or_email_page.dart';
import 'package:taste_tube/build_config.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/fallback.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/profile/view/owner_profile_page.dart';
import 'package:taste_tube/feature/record/camera/camera_page.dart';
import 'package:taste_tube/feature/shop/view/cart_page.dart';
import 'package:taste_tube/feature/shop/view/shop_page.dart';
import 'package:taste_tube/feature/watch/view/public_videos_page.dart';
import 'package:taste_tube/global_bloc/download/download_dialog.dart';
import 'package:taste_tube/feature/home/view/home_page.dart';
import 'package:taste_tube/feature/inbox/view/inbox_page.dart';
import 'package:taste_tube/feature/profile/view/profile_page.dart';
import 'package:taste_tube/feature/store/view/store_page.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_page.dart';
import 'package:taste_tube/firebase_options.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/providers.dart';
import 'package:taste_tube/splash/initial_page.dart';

part 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Api(BuildConfig.environment);
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
  // Remove '#' from web url
  setUrlStrategy(PathUrlStrategy());

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
              primaryColor: Colors.black,
              hintColor: Colors.amber[300],
              textTheme: ThemeData.light()
                  .textTheme
                  .apply(fontFamily: 'Ganh')
                  .copyWith(
                    bodyMedium: const TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    bodyLarge: const TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    titleLarge: const TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                    // Add other styles if needed
                  ),
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
                backgroundColor: CommonColor.lightGrey,
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
                backgroundColor: CommonColor.activeBgColor,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.white,
              textTheme:
                  ThemeData.dark().textTheme.apply(fontFamily: 'Ganh').copyWith(
                        bodyMedium: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                        bodyLarge: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                        titleLarge: const TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                        // Add other styles if needed
                      ),
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
                backgroundColor: CommonColor.darkGrey,
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
                backgroundColor: CommonColor.activeBgColor,
                foregroundColor: Colors.white,
              ),
            ),
            themeMode: getIt<AppSettings>().getTheme,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown,
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
      buildWhen: (previous, current) =>
          previous is Authenticated && current is! Authenticated ||
          previous is! Authenticated && current is Authenticated,
      builder: (context, state) {
        if (state is! Authenticated) {
          final currentRoute = GoRouterState.of(context).matchedLocation;
          return InitialPage(redirect: currentRoute);
        }
        final isCustomer = state.data.role == "CUSTOMER";
        final fabHidden = currentIndex == 1 || currentIndex == 2;

        return Stack(
          alignment: Alignment.center,
          children: [
            Scaffold(
              resizeToAvoidBottomInset: false,
              body: shell,
              extendBody: true,
              extendBodyBehindAppBar: true,
              bottomNavigationBar: AnimatedBottomNavigationBar.builder(
                backgroundColor:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                activeIndex: currentIndex,
                gapLocation: fabHidden ? GapLocation.none : GapLocation.center,
                notchSmoothness: NotchSmoothness.softEdge,
                onTap: (index) {
                  if (index != 0) {
                    getIt<ContentCubit>().pauseContent();
                  } else {
                    getIt<ContentCubit>().resumeContent();
                  }
                  if (index == 1 && isCustomer) {
                    context.go('/shop');
                    return;
                  }
                  shell.goBranch(index);
                },
                itemCount: 4,
                tabBuilder: (int index, bool isActive) {
                  final labels = isCustomer
                      ? ['Home', 'Shop', 'Inbox', 'Profile']
                      : ['Home', 'Store', 'Inbox', 'Profile'];
                  final icons = isCustomer
                      ? [
                          Icons.home,
                          Icons.shopping_basket_rounded,
                          Icons.inbox,
                          Icons.person
                        ]
                      : [Icons.home, Icons.store, Icons.inbox, Icons.person];

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 24,
                        color: isActive
                            ? Theme.of(context)
                                .bottomNavigationBarTheme
                                .selectedItemColor
                            : Theme.of(context)
                                .bottomNavigationBarTheme
                                .unselectedItemColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: isActive
                              ? Theme.of(context)
                                  .bottomNavigationBarTheme
                                  .selectedItemColor
                              : Theme.of(context)
                                  .bottomNavigationBarTheme
                                  .unselectedItemColor,
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerDocked,
              floatingActionButton: fabHidden
                  ? null
                  : FloatingActionButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => CameraPage.provider(),
                        ),
                      ),
                      mini: true,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
            ),
            DownloadDialog(),
          ],
        );
      },
    );
  }
}
