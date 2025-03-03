import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/feature/profile/view/profile_cubit.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/utils/user_data.util.dart';

part 'profile_page.ext.dart';

class _OwnerProfileInteractions extends StatelessWidget {
  final ProfileCubit cubit;
  const _OwnerProfileInteractions({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      bloc: cubit,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _showEditProfileDialog(context, state.user!);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit profile'),
            ),
            const SizedBox(width: 5),
            ElevatedButton.icon(
              onPressed: () {
                _showChangePasswordDialog(context);
              },
              icon: const Icon(Icons.password_rounded),
              label: const Text('Change password'),
            ),
          ],
        );
      },
    );
  }
}

class _GuestProfileInteractions extends StatelessWidget {
  final ProfileCubit cubit;
  const _GuestProfileInteractions({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final currentUserId = UserDataUtil.getUserId();
    return BlocBuilder<ProfileCubit, ProfileState>(
        bloc: cubit,
        builder: (context, state) {
          final followed = state.user!.followers.contains(currentUserId);

          if (state.user!.role == AccountType.customer.value()) {
            return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              followed == true
                  ? ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .read<ProfileCubit>()
                            .unfollowUser(state.user!, currentUserId);
                      },
                      icon: const Icon(Icons.person_remove_rounded),
                      label: const Text('Unfollow'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .read<ProfileCubit>()
                            .followUser(state.user!, currentUserId);
                      },
                      icon: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Follow',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor: CommonColor.activeBgColor),
                    ),
            ]);
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              followed == true
                  ? ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .read<ProfileCubit>()
                            .unfollowUser(state.user!, currentUserId);
                      },
                      icon: const Icon(Icons.person_remove_rounded),
                      label: const Text('Unfollow'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () async {
                        await context
                            .read<ProfileCubit>()
                            .followUser(state.user!, currentUserId);
                      },
                      icon: const Icon(
                        Icons.add_business,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Follow',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor: CommonColor.activeBgColor),
                    ),
              const SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/camera', extra: state.user);
                },
                icon: const Icon(Icons.reviews),
                label: const Text('Send review'),
              ),
              const SizedBox(width: 5),
              ElevatedButton.icon(
                onPressed: () {
                  context.pushNamed('single-shop', pathParameters: {
                    'shopId': state.user!.id,
                  }, extra: {
                    'shopImage': state.user!.image,
                    'shopName': state.user!.username,
                    'shopPhone': state.user!.phone,
                  });
                },
                icon: const Icon(Icons.food_bank),
                label: const Text('Products'),
              ),
            ],
          );
        });
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Widget provider(String userId) => MultiBlocProvider(
        key: ValueKey(userId),
        providers: [
          BlocProvider(create: (context) => ProfileCubit(userId)..init()),
          BlocProvider(
            create: (context) => PasswordCubit(userId),
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

        if (state is ProfileLoading) {
          return const Center(
            child: CommonLoadingIndicator.regular,
          );
        }
        if (state is ProfileFailure) {
          return Center(
            child: Column(
              children: [
                Text(state.message),
                const SizedBox(height: 20),
                FloatingActionButton.extended(
                  heroTag: 'Profile reset',
                  label: const Text('Try again'),
                  onPressed: () {
                    cubit.init();
                  },
                ),
              ],
            ),
          );
        }
        final isRestaurant = state.user!.role == AccountType.restaurant.value();
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(state.user!.username),
            actions: [
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.menu),
                    onSelected: (result) async {
                      switch (result) {
                        case 'Logout':
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
                            context.go('/login');
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'Logout',
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body: RefreshIndicator(
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
                      state.user!.email ??
                          state.user!.phone ??
                          'No contact info',
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildProfileStat(
                            'Following', state.user!.followings.length),
                        const SizedBox(width: 20),
                        _buildProfileStat(
                            'Followers', state.user!.followers.length),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isOwner) _OwnerProfileInteractions(cubit: cubit),
                    if (!isOwner) _GuestProfileInteractions(cubit: cubit),
                    const SizedBox(height: 10),
                    (state.user!.bio == null || state.user!.bio!.isEmpty)
                        ? const Text('No bio')
                        : Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
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
          ),
        );
      },
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

  // TODO: May separate fetch request from User
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
            context.push('/watch', extra: {
              'videos': videos,
              'initialIndex': index,
            });
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
                    context.push('/watch', extra: {
                      'videos': state.likedVideos,
                      'initialIndex': index,
                    });
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
                    context.push('/watch', extra: {
                      'videos': state.reviews,
                      'initialIndex': index,
                    });
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
