import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/auth/view/oauth/oauth_cubit.dart';
import 'package:taste_tube/feature/admin/user_management/user_management_cubit.dart';
import 'package:taste_tube/feature/admin/video_management/video_management_cubit.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/home/view/following_content_cubit.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/download/download_cubit.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
import 'package:taste_tube/core/storage.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> logApiCallEvent(String apiName) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'api_call',
    parameters: {'api_name': apiName},
  );
}

class AuthRequired extends StatelessWidget {
  final Widget child;
  const AuthRequired({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: getIt<AuthBloc>(),
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
          return SizedBox.shrink();
        }
        return child;
      },
    );
  }
}

class TasteTubeProvider extends StatelessWidget {
  final Widget child;
  final bool isAdmin;
  const TasteTubeProvider(
      {super.key, required this.child, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: getIt<AuthBloc>()..add(CheckAuthEvent()),
        ),
        BlocProvider.value(
          value: getIt<OAuthCubit>(),
        ),
        BlocProvider.value(
          value: getIt<CartCubit>(),
        ),
        BlocProvider.value(
          value: getIt<OrderCubit>(),
        ),
        BlocProvider.value(
          value: getIt<ContentCubit>(),
        ),
        BlocProvider.value(
          value: getIt<FollowingContentCubit>(),
        ),
        BlocProvider.value(
          value: getIt<DownloadCubit>(),
        ),
        BlocProvider.value(
          value: getIt<GetstreamCubit>(),
        ),
        if (isAdmin) ...[
          BlocProvider.value(
            value: getIt<UserManagementCubit>(),
          ),
          BlocProvider.value(
            value: getIt<VideoManagementCubit>(),
          ),
        ]
      ],
      child: child,
    );
  }
}

class AppSettings extends ChangeNotifier {
  ThemeMode _theme;
  AppLanguage _currentLanguage;

  AppSettings()
      : _theme = ThemeMode.dark,
        _currentLanguage = AppLanguage.en {
    _initialize();
  }

  Future<void> _initialize() async {
    final themeValue = await getIt<LocalStorage>().getValue("THEME_MODE");
    final newTheme = themeValue == "light" ? ThemeMode.light : ThemeMode.dark;
    final languageValue = await getIt<LocalStorage>().getValue("LANGUAGE");
    final newLanguage = languageValue == "vi" ? AppLanguage.vi : AppLanguage.en;

    bool changed = false;
    if (_theme != newTheme) {
      _theme = newTheme;
      changed = true;
    }
    if (_currentLanguage != newLanguage) {
      _currentLanguage = newLanguage;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  ThemeMode get getTheme => _theme;

  void setTheme(ThemeMode theme) {
    _theme = theme;
    getIt<LocalStorage>()
        .setValue("THEME_MODE", theme == ThemeMode.dark ? "dark" : "light");
    notifyListeners();
  }

  void flipThemeMode() {
    if (_theme == ThemeMode.light) {
      _theme = ThemeMode.dark;
    } else {
      _theme = ThemeMode.light;
    }
    getIt<LocalStorage>()
        .setValue("THEME_MODE", _theme == ThemeMode.dark ? "dark" : "light");
    notifyListeners();
  }

  AppLanguage get currentLanguage => _currentLanguage;

  Locale get locale {
    switch (_currentLanguage) {
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.vi:
        return const Locale('vi');
    }
  }

  void changeLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      getIt<LocalStorage>()
          .setValue("LANGUAGE", language == AppLanguage.vi ? "vi" : "en");
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}

enum AppLanguage { en, vi }

extension LocalizationContext on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;
}

class BottomNavigationBarToggleNotifier {
  final ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);

  void show() => isVisible.value = true;
  void hide() => isVisible.value = false;
}
