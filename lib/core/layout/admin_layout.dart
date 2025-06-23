import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/global_bloc/download/download_dialog.dart';
import 'package:taste_tube/splash/initial_page.dart';

class AdminLayout extends StatelessWidget {
  final int currentIndex;
  final StatefulNavigationShell shell;
  final GoRouterState goRouterState;

  const AdminLayout({
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
        final labels = ['Dashboard', 'Chat', 'Users', 'Videos'];

        final icons = [
          Icons.dashboard,
          Icons.inbox,
          Icons.face,
          Icons.video_camera_front
        ];

        return Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    shell.goBranch(index);
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: List.generate(
                    labels.length,
                    (index) => NavigationRailDestination(
                      icon: Icon(icons[index]),
                      label: Text(labels[index]),
                    ),
                  ),
                  backgroundColor: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 15),
                    child: Image.asset(AssetPath.tastetubeInverted, height: 50),
                  ),
                  trailing: LogoutButton(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    body: shell,
                    extendBody: true,
                    extendBodyBehindAppBar: true,
                  ),
                ),
              ],
            ),
            DownloadDialog(),
          ],
        );
      },
    );
  }
}
