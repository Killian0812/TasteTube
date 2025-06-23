import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show PlatformDispatcher, kDebugMode, kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/auth/view/phone_or_email/login_phone_or_email_page.dart';
import 'package:taste_tube/auth/view/phone_or_email/register_phone_or_email_page.dart';
import 'package:taste_tube/core/build_config.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/error.dart';
import 'package:taste_tube/common/fallback.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/core/layout/admin_layout.dart';
import 'package:taste_tube/feature/admin/dashboard/admin_dashboard_page.dart';
import 'package:taste_tube/feature/admin/user_management/user_management_page.dart';
import 'package:taste_tube/feature/admin/video_management/video_management_page.dart';
import 'package:taste_tube/feature/inbox/view/chat_page.dart';
import 'package:taste_tube/feature/watch/view/public_videos_page.dart';
import 'package:taste_tube/core/fcm_service.dart';
import 'package:taste_tube/feature/watch/view/content/content_page.dart';
import 'package:taste_tube/feature/profile/view/profile_page.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_page.dart';
import 'package:taste_tube/firebase_options.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/local_notification.dart';
import 'package:taste_tube/core/providers.dart';
import 'package:taste_tube/version.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'admin_router.dart';

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
    return TasteTubeProvider(
      isAdmin: true,
      child: AnimatedBuilder(
        animation: getIt<AppSettings>(),
        builder: (context, snapshot) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'TasteTube Admin',
            builder: (context, child) => StreamChat(
              client: streamClient,
              child: child,
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
      ),
    );
  }
}

