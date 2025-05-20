part of 'admin_main.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
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
        goRouterState: state,
      ),
      branches: [
        StatefulShellBranch(
          preload: true,
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const AdminDashboardPage(),
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
          preload: true,
          routes: [
            GoRoute(
              path: '/users',
              builder: (context, state) => const UserManagementPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          preload: true,
          routes: [
            GoRoute(
              path: '/videos',
              builder: (context, state) => const VideoManagementPage(),
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
        builder: (context, state) {
          final int initialIndex = state.extra as int? ?? 0;
          return LoginWithPhoneOrEmailPage(initialIndex: initialIndex);
        }),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterWithPhoneOrEmailPage(),
    ),
    GoRoute(
      path: '/version',
      builder: (context, state) => const VersionPage(isAdmin: true),
    ),
  ],
  redirect: (context, state) {
    final authBloc = getIt<AuthBloc>();

    final isAuthenticated = authBloc.state is Authenticated;

    final protectedRoutes = [];

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
