import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:taste_tube/auth/view/oauth/oauth_cubit.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/download/download_cubit.dart';
import 'package:taste_tube/global_bloc/getstream/getstream_cubit.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_bloc/order/order_cubit.dart';
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
  const TasteTubeProvider({super.key, required this.child});

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
      ],
      child: child,
    );
  }
}

class AppSettings extends ChangeNotifier {
  ThemeMode _theme = ThemeMode.dark;
  ThemeMode get getTheme => _theme;

  void setTheme(ThemeMode theme) {
    _theme = theme;
    notifyListeners();
  }

  void flipThemeMode() {
    if (_theme == ThemeMode.light) {
      _theme = ThemeMode.dark;
    } else {
      _theme = ThemeMode.light;
    }
    notifyListeners();
  }

  AppLanguage _currentLanguage = AppLanguage.en;
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
  AppLocalizations get localization => AppLocalizations.of(this)!;
}

class BottomNavigationBarToggleNotifier {
  final ValueNotifier<bool> isVisible = ValueNotifier<bool>(true);

  void show() => isVisible.value = true;
  void hide() => isVisible.value = false;
}
