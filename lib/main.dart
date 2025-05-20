import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show PlatformDispatcher, kDebugMode, kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/auth/view/login_page.dart';
import 'package:taste_tube/auth/view/register_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_phone_or_email_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/register_phone_or_email_page.dart';
import 'package:taste_tube/core/build_config.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/common/fallback.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/home/view/following_content_cubit.dart';
import 'package:taste_tube/feature/profile/view/owner_profile_page.dart';
import 'package:taste_tube/feature/record/camera/camera_page.dart';
import 'package:taste_tube/feature/shop/view/cart_page.dart';
import 'package:taste_tube/feature/shop/view/shop_page.dart';
import 'package:taste_tube/feature/watch/view/public_videos_page.dart';
import 'package:taste_tube/core/fcm_service.dart';
import 'package:taste_tube/feature/watch/view/content/content_page.dart';
import 'package:taste_tube/global_bloc/download/download_dialog.dart';
import 'package:taste_tube/feature/home/view/home_page.dart';
import 'package:taste_tube/feature/inbox/view/chat_page.dart';
import 'package:taste_tube/feature/profile/view/profile_page.dart';
import 'package:taste_tube/feature/store/view/store_page.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_page.dart';
import 'package:taste_tube/firebase_options.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/local_notification.dart';
import 'package:taste_tube/core/providers.dart';
import 'package:taste_tube/splash/initial_page.dart';
import 'package:taste_tube/version.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Api(BuildConfig.environment);

  await Fallback.prepareFallback();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((firebaseApp) {
    getIt.registerSingleton<FirebaseApp>(firebaseApp);
    getIt.registerSingleton<FirebaseAnalytics>(
        FirebaseAnalytics.instance..logAppOpen());
  });
  if (!kIsWeb) {
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  FCMService.setupFirebaseMessaging();
  LocalNotification.setupLocalNotifications();

  injectDependencies();

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

    return AnimatedBuilder(
      animation: getIt<AppSettings>(),
      builder: (context, snapshot) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'TasteTube',
          builder: (context, child) => TasteTubeProvider(
            child: StreamChat(
              client: streamClient,
              child: child ?? SizedBox.shrink(),
            ),
          ),
          routerConfig: _router,
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.black,
            hintColor: Colors.amber[300],
            textTheme: lightTextTheme,
            primaryTextTheme: lightTextTheme,
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
              selectedLabelStyle: CommonTextStyle.bold,
              unselectedLabelStyle: CommonTextStyle.regular,
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
            textTheme: darkTextTheme,
            primaryTextTheme: darkTextTheme,
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
              selectedLabelStyle: CommonTextStyle.bold,
              unselectedLabelStyle: CommonTextStyle.regular,
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
          locale: getIt<AppSettings>().locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('vi'),
          ],
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
    );
  }
}

class Layout extends StatelessWidget {
  final int currentIndex;
  final StatefulNavigationShell shell;
  final GoRouterState goRouterState;

  const Layout({
    super.key,
    required this.currentIndex,
    required this.shell,
    required this.goRouterState,
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
          final currentRoute = goRouterState.matchedLocation;
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
              bottomNavigationBar: ValueListenableBuilder<bool>(
                valueListenable:
                    getIt<BottomNavigationBarToggleNotifier>().isVisible,
                builder: (context, isVisible, child) {
                  if (!isVisible) return const SizedBox.shrink();
                  return AnimatedBottomNavigationBar.builder(
                    backgroundColor: Theme.of(context)
                        .bottomNavigationBarTheme
                        .backgroundColor,
                    activeIndex: currentIndex,
                    gapLocation:
                        fabHidden ? GapLocation.none : GapLocation.center,
                    notchSmoothness: NotchSmoothness.softEdge,
                    onTap: (index) {
                      if (index != 0) {
                        getIt<ContentCubit>().pauseContent();
                        getIt<FollowingContentCubit>().pauseContent();
                      } else {
                        getIt<ContentCubit>().resumeContent();
                        getIt<FollowingContentCubit>().resumeContent();
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
                          ? ['Home', 'Shop', 'Chat', 'Profile']
                          : ['Home', 'Store', 'Chat', 'Profile'];
                      final icons = isCustomer
                          ? [
                              Icons.home,
                              Icons.shopping_basket_rounded,
                              Icons.inbox,
                              Icons.person
                            ]
                          : [
                              Icons.home,
                              Icons.store,
                              Icons.inbox,
                              Icons.person
                            ];

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
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
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
