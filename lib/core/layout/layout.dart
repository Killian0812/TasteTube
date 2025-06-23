import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/providers.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/home/view/following_content_cubit.dart';
import 'package:taste_tube/feature/record/camera/camera_page.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/download/download_dialog.dart';
import 'package:taste_tube/splash/initial_page.dart';

class Layout extends StatelessWidget {
  final int currentIndex;
  final StatefulNavigationShell shell;
  final GoRouterState goRouterState;

  const Layout({
    super.key,
    required this.currentIndex,
    required this.shell,
    required this.goRouterState,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
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
          final currentRoute = goRouterState.matchedLocation;
          return InitialPage(redirect: currentRoute);
        }

        final isCustomer = state.data.role == "CUSTOMER";
        final fabHidden = currentIndex == 1 || currentIndex == 2;

        final labels = isCustomer
            ? ['Home', 'Shop', 'Chat', 'Profile']
            : ['Home', 'Store', 'Chat', 'Profile'];
        final icons = isCustomer
            ? [
                Icons.home,
                Icons.shopping_basket_rounded,
                Icons.inbox,
                Icons.person,
              ]
            : [
                Icons.home,
                Icons.store,
                Icons.inbox,
                Icons.person,
              ];

        final isWebWide = kIsWeb && MediaQuery.of(context).size.width >= 800;

        final navItems = List.generate(4, (index) {
          final isActive = index == currentIndex;
          final icon = Icon(
            icons[index],
            color: isActive
                ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                : Theme.of(context)
                    .bottomNavigationBarTheme
                    .unselectedItemColor,
          );
          final label = Text(
            labels[index],
            style: TextStyle(
              color: isActive
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
            ),
          );
          return NavigationRailDestination(
            icon: icon,
            selectedIcon: icon,
            label: label,
          );
        });

        Widget navWidget = ValueListenableBuilder<bool>(
          valueListenable: getIt<BottomNavigationBarToggleNotifier>().isVisible,
          builder: (context, isVisible, child) {
            if (!isVisible) return const SizedBox.shrink();

            return isWebWide
                ? NavigationRail(
                    selectedIndex: currentIndex,
                    onDestinationSelected: (index) {
                      if (index != 0) {
                        getIt<ContentCubit>().pauseContent();
                        getIt<FollowingContentCubit>().pauseContent();
                      } else {
                        getIt<ContentCubit>().resumeContent();
                        getIt<FollowingContentCubit>().resumeContent();
                      }
                      if (index == 1 && isCustomer) {
                        context.go('/shop');
                        return;
                      }
                      shell.goBranch(index);
                    },
                    labelType: NavigationRailLabelType.all,
                    destinations: navItems,
                    backgroundColor: Theme.of(context)
                        .bottomNavigationBarTheme
                        .backgroundColor,
                  )
                : AnimatedBottomNavigationBar.builder(
                    backgroundColor: Theme.of(context)
                        .bottomNavigationBarTheme
                        .backgroundColor,
                    activeIndex: currentIndex,
                    gapLocation:
                        fabHidden ? GapLocation.none : GapLocation.center,
                    notchSmoothness: NotchSmoothness.softEdge,
                    onTap: (index) {
                      if (index != 0) {
                        getIt<ContentCubit>().pauseContent();
                        getIt<FollowingContentCubit>().pauseContent();
                      } else {
                        getIt<ContentCubit>().resumeContent();
                        getIt<FollowingContentCubit>().resumeContent();
                      }
                      if (index == 1 && isCustomer) {
                        context.go('/shop');
                        return;
                      }
                      shell.goBranch(index);
                    },
                    itemCount: 4,
                    tabBuilder: (int index, bool isActive) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icons[index],
                            size: 24,
                            color: isActive
                                ? Theme.of(context)
                                    .bottomNavigationBarTheme
                                    .selectedItemColor
                                : Theme.of(context)
                                    .bottomNavigationBarTheme
                                    .unselectedItemColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[index],
                            style: TextStyle(
                              color: isActive
                                  ? Theme.of(context)
                                      .bottomNavigationBarTheme
                                      .selectedItemColor
                                  : Theme.of(context)
                                      .bottomNavigationBarTheme
                                      .unselectedItemColor,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  );
          },
        );

        return Stack(
          alignment: Alignment.center,
          children: [
            isWebWide
                ? Row(
                    children: [
                      navWidget,
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: Scaffold(
                          resizeToAvoidBottomInset: false,
                          body: shell,
                          extendBody: true,
                          extendBodyBehindAppBar: true,
                          floatingActionButton: fabHidden
                              ? null
                              : FloatingActionButton(
                                  onPressed: () =>
                                      Navigator.of(context, rootNavigator: true)
                                          .push(MaterialPageRoute(
                                    builder: (context) => CameraPage.provider(),
                                  )),
                                  mini: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  child: const Icon(Icons.add),
                                ),
                        ),
                      ),
                    ],
                  )
                : Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: shell,
                    extendBody: true,
                    extendBodyBehindAppBar: true,
                    bottomNavigationBar: navWidget,
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.centerDocked,
                    floatingActionButton: fabHidden
                        ? null
                        : FloatingActionButton(
                            onPressed: () =>
                                Navigator.of(context, rootNavigator: true)
                                    .push(MaterialPageRoute(
                              builder: (context) => CameraPage.provider(),
                            )),
                            mini: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: const Icon(Icons.add),
                          ),
                  ),
            DownloadDialog(),
          ],
        );
      },
    );
  }
}
