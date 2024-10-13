part of 'main.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  observers: [CommonNavigatorObserver()],
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const SplashPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) => Center(
        child: ElevatedButton(
            onPressed: () {
              context.go('/login');
            },
            child: const Text('LOGIN')),
      ),
    ),
    // auth related routes
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
        path: '/login/phone_or_email',
        builder: (BuildContext context, GoRouterState state) {
          final int initialIndex = state.extra as int? ?? 0;
          return LoginWithPhoneOrEmailPage(initialIndex: initialIndex);
        }),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) =>
          const RegisterPage(),
    ),
    GoRoute(
      path: '/register/phone_or_email',
      builder: (BuildContext context, GoRouterState state) =>
          const RegisterWithPhoneOrEmailPage(),
    ),
  ],
);

class CommonNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    ToastService.hideToast(); // Hide toast when navigating to a new page
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    ToastService.hideToast(); // Hide toast when navigating back
    super.didPop(route, previousRoute);
  }
}
