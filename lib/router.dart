part of 'main.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/login',
  observers: [CommonNavigatorObserver()],
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const Placeholder(),
    ),
    // auth related routes
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: '/login/phone_or_email',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginWithPhoneOrEmailPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) =>
          const RegisterPage(),
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
