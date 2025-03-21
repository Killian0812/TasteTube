part of 'main.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  observers: [CommonNavigatorObserver()],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const InitialPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => Layout(
        currentIndex: shell.currentIndex,
        shell: shell,
      ),
      branches: [
        StatefulShellBranch(
          preload: true,
          routes: [
            GoRoute(
              path: '/home',
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
              path: '/inbox',
              builder: (context, state) => const InboxPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/user',
              builder: (context, state) => const OwnerProfilePage(),
            ),
            GoRoute(
              path: '/user/:userId',
              name: 'profile',
              builder: (context, state) =>
                  ProfilePage.provider(state.pathParameters['userId'] ?? ''),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => PaymentPage.provider(),
    ),
    GoRoute(
        path: '/shop/:shopId',
        name: 'single-shop',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SingleShopPage.provider(
            state.pathParameters['shopId'] ?? '',
            extra?['shopImage'] ?? '',
            extra?['shopName'] ?? '',
            extra?['shopPhone'],
          );
        }),
    GoRoute(
      path: '/camera',
      builder: (context, state) =>
          CameraPage.provider(reviewTarget: state.extra as User?),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => SearchPage.provider(),
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
          return const InitialPage();
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
        }),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/register/phone_or_email',
      builder: (context, state) => const RegisterWithPhoneOrEmailPage(),
    ),
  ],
  redirect: (context, state) {
    final authBloc = getIt<AuthBloc>();

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
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // ToastService.hideToast(); // Hide toast when navigating back
    super.didPop(route, previousRoute);
  }
}
