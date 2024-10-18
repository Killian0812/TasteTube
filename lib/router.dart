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
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => Layout(
        currentIndex: shell.currentIndex,
        shell: shell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/restaurant',
              builder: (context, state) => const RestaurantPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inbox',
              builder: (context, state) => const InboxPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/camera',
      builder: (BuildContext context, GoRouterState state) =>
          CameraPage.provider(),
    ),

    // Auth routes
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
  redirect: (context, state) {
    final authBloc = context.read<AuthBloc>();

    final isAuthenticated = authBloc.state is Authenticated;

    final protectedRoutes = [
      '/home',
      '/profile',
      '/restaurant',
    ];

    if (!isAuthenticated && protectedRoutes.contains(state.path)) {
      return '/login';
    }

    return null;
  },
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
