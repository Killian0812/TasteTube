import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:taste_tube/auth/view/oauth/oauth_cubit.dart';
import 'package:taste_tube/feature/admin/user_management/user_management_cubit.dart';
import 'package:taste_tube/feature/admin/video_management/video_management_cubit.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
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
    _theme = themeValue == "light" ? ThemeMode.light : ThemeMode.dark;
    final languageValue = await getIt<LocalStorage>().getValue("LANGUAGE");
    if (languageValue == "vi") {
      _currentLanguage = AppLanguage.vi;
    } else {
      _currentLanguage = AppLanguage.en;
    }
    notifyListeners();
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
