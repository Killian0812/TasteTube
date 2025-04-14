import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/record/camera/camera_page.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/feature/profile/view/profile_cubit.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/providers.dart';
import 'package:taste_tube/utils/user_data.util.dart';

part 'profile_page.ext.dart';
part 'profile_page.ext2.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Widget provider(String userId) => MultiBlocProvider(
        key: ValueKey(userId),
        providers: [
          BlocProvider(
            create: (context) => ProfileCubit(userId)..init(),
          ),
        ],
        child: const ProfilePage(),
      );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final cubit = context.read<ProfileCubit>();
        final isOwner = cubit.isOwner;
        final appSettings = getIt<AppSettings>();

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: state is! ProfileLoading && state is! ProfileFailure
                ? Text(state.user!.username)
                : const Text('Profile'),
            actions: [
              if (isOwner &&
                  state is! ProfileLoading &&
                  state is! ProfileFailure)
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.menu),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(appSettings.getTheme == ThemeMode.dark
                                ? Icons.light_mode
                                : Icons.dark_mode),
                            const SizedBox(width: 8),
                            Text(appSettings.getTheme == ThemeMode.dark
                                ? 'Light'
                                : 'Dark'),
                          ],
                        ),
                        onTap: () {
                          appSettings.flipThemeMode();
                        },
                      ),
                      PopupMenuItem<String>(
                        value: 'Logout',
                        child: const Text('Logout'),
                        onTap: () async {
                          bool? confirmed = await showConfirmDialog(
                            context,
                            title: "Confirm logout",
                            body: 'Are you sure you want to logout?',
                          );
                          if (confirmed != true) {
                            return;
                          }
                          if (context.mounted) {
                            final authBloc = getIt<AuthBloc>();
                            authBloc.add(LogoutEvent());
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body: _buildBody(context, state, cubit, isOwner),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state,
      ProfileCubit cubit, bool isOwner) {
    if (state is ProfileLoading) {
      return const Center(
        child: CommonLoadingIndicator.regular,
      );
    }
    if (state is ProfileFailure) {
      return RefreshIndicator(
        onRefresh: () async {
          cubit.init();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(state.message),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isRestaurant = state.user!.role == AccountType.restaurant.value();

    return RefreshIndicator(
      onRefresh: () async {
        cubit.init();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: CommonSize.screenSize.height -
              CommonSize.appBarHeight -
              CommonSize.bottomNavBarHeight -
              30,
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: state.user!.image != null
                    ? NetworkImage(state.user!.image!)
                    : null,
                child: state.user!.image == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
              const SizedBox(height: 10),
              Text(
                state.user!.email ?? state.user!.phone ?? 'No contact info',
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProfileStat('Following', state.user!.followings.length),
                  const SizedBox(width: 20),
                  _buildProfileStat('Followers', state.user!.followers.length),
                ],
              ),
              const SizedBox(height: 20),
              if (isOwner) _OwnerProfileInteractions(cubit: cubit),
              if (!isOwner) _GuestProfileInteractions(cubit: cubit),
              const SizedBox(height: 10),
              (state.user!.bio == null || state.user!.bio!.isEmpty)
                  ? const Text('No bio')
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        state.user!.bio ?? '',
                        textAlign: TextAlign.center,
                      ),
                    ),
              const SizedBox(height: 20),
              Expanded(
                child: DefaultTabController(
                  length: (isRestaurant ? 2 : 1) + (isOwner ? 1 : 0),
                  child: Column(
                    children: [
                      TabBar(
                        tabs: isRestaurant
                            ? [
                                const Tab(icon: Icon(Icons.grid_view)),
                                const Tab(icon: Icon(Icons.reviews)),
                                if (isOwner)
                                  const Tab(icon: Icon(Icons.favorite)),
                              ]
                            : [
                                const Tab(icon: Icon(Icons.grid_view)),
                                if (isOwner)
                                  const Tab(icon: Icon(Icons.favorite)),
                              ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: isRestaurant
                              ? [
                                  _buildVideosTab(
                                    state.user!.videos.reversed.toList(),
                                    isOwner,
                                  ),
                                  _buildReviewsTab(),
                                  if (isOwner) _buildLikedVideosTab(),
                                ]
                              : [
                                  _buildVideosTab(
                                    state.user!.videos.reversed.toList(),
                                    isOwner,
                                  ),
                                  if (isOwner) _buildLikedVideosTab(),
                                ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildVideosTab(List<Video> videos, bool isOwner) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            context.push('/watch/${videos[index].id}', extra: videos);
          },
          child: Stack(
            children: [
              Image.memory(
                base64Decode(videos[index].thumbnail ?? ''),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              if (isOwner)
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: _buildVisibilityIcon(videos[index].visibility),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVisibilityIcon(String visibility) {
    IconData iconData;
    switch (visibility) {
      case 'PRIVATE':
        iconData = Icons.lock;
        break;
      case 'FOLLOWERS_ONLY':
        iconData = Icons.group;
        break;
      case 'PUBLIC':
        iconData = Icons.public;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Icon(
      iconData,
      color: Colors.white,
      size: 20,
    );
  }

  Widget _buildLikedVideosTab() {
    return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: state.likedVideos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    context.push(
                      '/watch/${state.likedVideos[index].id}',
                      extra: state.likedVideos,
                    );
                  },
                  child: Stack(
                    children: [
                      Image.memory(
                        base64Decode(state.likedVideos[index].thumbnail ?? ''),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ],
                  ),
                );
              },
            ));
  }

  Widget _buildReviewsTab() {
    return BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) => GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: state.reviews.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    context.push(
                      '/watch/${state.reviews[index].id}',
                      extra: state.reviews,
                    );
                  },
                  child: Stack(
                    children: [
                      Image.memory(
                        base64Decode(state.reviews[index].thumbnail ?? ''),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ],
                  ),
                );
              },
            ));
  }
}
