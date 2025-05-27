part of 'main.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  observers: [CommonNavigatorObserver()],
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => Layout(
        currentIndex: shell.currentIndex,
        shell: shell,
        goRouterState: state,
      ),
      branches: [
        StatefulShellBranch(
          preload: true,
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          preload: true,
          routes: [
            GoRoute(
              path: '/store',
              builder: (context, state) => const StorePage(),
            ),
            GoRoute(
              path: '/shop',
              builder: (context, state) => ShopPage.provider(),
            ),
          ],
        ),
        StatefulShellBranch(
          preload: true,
          routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const OwnerProfilePage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/user/:userId',
      builder: (context, state) =>
          ProfilePage.provider(state.pathParameters['userId'] ?? ''),
    ),
    GoRoute(
      path: '/shop/:shopId',
      builder: (context, state) {
        return AuthRequired(
          child: SingleShopPage.provider(state.pathParameters['shopId'] ?? ''),
        );
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/watch/:videoId',
      builder: (context, state) {
        final videoId = state.pathParameters['videoId']!;
        final videos = state.extra as List<Video>?;
        final initialIndex = videos?.indexWhere((e) => e.id == videoId);

        if (videos == null || initialIndex == null) {
          return SingleContent.provider(videoId);
        }

        return PublicVideosPage(
          videos: videos,
          initialIndex: initialIndex,
        );
      },
    ),

    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/login/phone_or_email',
      builder: (context, state) {
        final int initialIndex = state.extra as int? ?? 0;
        return LoginWithPhoneOrEmailPage(initialIndex: initialIndex);
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/register/phone_or_email',
      builder: (context, state) => const RegisterWithPhoneOrEmailPage(),
    ),
    GoRoute(
      path: '/version',
      builder: (context, state) => const VersionPage(),
    ),
  ],
  redirect: (context, state) {
    final authBloc = getIt<AuthBloc>();

    final isAuthenticated = authBloc.state is Authenticated;

    final protectedRoutes = [
      '/profile',
      '/store',
      '/chat',
    ];

    if (!isAuthenticated && protectedRoutes.contains(state.path)) {
      return '/login';
    }

    return null;
  },
  errorBuilder: (context, state) => ErrorPage(exception: state.error),
);

class CommonNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // ToastService.hideToast(); // Hide toast when navigating back
    super.didPop(route, previousRoute);
  }
}
