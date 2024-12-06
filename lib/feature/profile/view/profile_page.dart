import 'dart:convert';
import 'dart:io';

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
import 'package:taste_tube/feature/profile/data/user.dart';
import 'package:taste_tube/feature/profile/view/profile_cubit.dart';
import 'package:taste_tube/feature/watch/data/video.dart';
import 'package:taste_tube/global_bloc/auth/bloc.dart';
import 'package:taste_tube/utils/user_data.util.dart';

part 'profile_page.ext.dart';

class _OwnerProfileInteractions extends StatelessWidget {
  final ProfileCubit cubit;
  const _OwnerProfileInteractions({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: cubit,
      builder: (context, state) {
        if (state is ProfileSuccess) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _showEditProfileDialog(context, state.user);
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
        } else {
          return CommonLoadingIndicator.regular;
        }
      },
    );
  }
}

class _GuestProfileInteractions extends StatelessWidget {
  final ProfileCubit cubit;
  const _GuestProfileInteractions({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final currentUserId = UserDataUtil.getUserId(context);
    return BlocBuilder(
        bloc: cubit,
        builder: (context, state) {
          if (state is ProfileSuccess) {
            final followed = state.user.followers.contains(currentUserId);

            if (state.user.role == AccountType.customer.value()) {
              return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    followed == true
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              await context
                                  .read<ProfileCubit>()
                                  .unfollowUser(state.user, currentUserId);
                            },
                            icon: const Icon(Icons.person_remove_rounded),
                            label: const Text('Unfollow'),
                          )
                        : ElevatedButton.icon(
                            onPressed: () async {
                              await context
                                  .read<ProfileCubit>()
                                  .followUser(state.user, currentUserId);
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
                              .unfollowUser(state.user, currentUserId);
                        },
                        icon: const Icon(Icons.person_remove_rounded),
                        label: const Text('Unfollow'),
                      )
                    : ElevatedButton.icon(
                        onPressed: () async {
                          await context
                              .read<ProfileCubit>()
                              .followUser(state.user, currentUserId);
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
                    // TODO: To restaurant products page
                  },
                  icon: const Icon(Icons.food_bank),
                  label: const Text('View product'),
                ),
              ],
            );
          } else {
            return CommonLoadingIndicator.regular;
          }
        });
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Widget provider(String userId) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ProfileCubit(userId)..init(context),
          ),
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

        if (state is ProfileSuccess) {
          final isRestaurant =
              state.user.role == AccountType.restaurant.value();
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(state.user.username),
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
                              final authBloc = context.read<AuthBloc>();
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
                cubit.init(context);
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
                        backgroundImage: state.user.image != null
                            ? NetworkImage(state.user.image!)
                            : null,
                        child: state.user.image == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.user.email ??
                            state.user.phone ??
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
                              'Following', state.user.followings.length),
                          const SizedBox(width: 20),
                          _buildProfileStat(
                              'Followers', state.user.followers.length),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (isOwner) _OwnerProfileInteractions(cubit: cubit),
                      if (!isOwner) _GuestProfileInteractions(cubit: cubit),
                      const SizedBox(height: 10),
                      (state.user.bio == null || state.user.bio!.isEmpty)
                          ? const Text('No bio')
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Text(
                                state.user.bio ?? '',
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
                                        const Tab(icon: Icon(Icons.grid_on)),
                                        const Tab(icon: Icon(Icons.reviews)),
                                        if (isOwner)
                                          const Tab(icon: Icon(Icons.favorite)),
                                      ]
                                    : [
                                        const Tab(icon: Icon(Icons.grid_on)),
                                        if (isOwner)
                                          const Tab(icon: Icon(Icons.favorite)),
                                      ],
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildVideosTab(
                                        state.user.videos.reversed.toList(),
                                        isOwner,
                                        state.user),
                                    if (isRestaurant)
                                      _buildReviewsTab(
                                          []), // TODO: Fetch reviews
                                    if (isOwner)
                                      _buildLikedVideosTab(
                                          []), // TODO: Fetch liked videos
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
        }
        if (state is ProfileLoading) {
          return const Center(
            child: CommonLoadingIndicator.regular,
          );
        }
        return Center(
          child: Column(
            children: [
              const Text('Unexpected error'),
              const SizedBox(height: 20),
              FloatingActionButton.extended(
                heroTag: 'Profile reset',
                label: const Text('Try again'),
                onPressed: () {
                  cubit.init(context);
                },
              ),
            ],
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

  Widget _buildVideosTab(List<Video> videos, bool isOwner, User owner) {
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
              'owner': owner,
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

  Widget _buildLikedVideosTab(List<Video> likedVideos) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: likedVideos.length,
      itemBuilder: (context, index) {
        return Image.memory(base64Decode(likedVideos[index].thumbnail ?? ''),
            fit: BoxFit.cover);
      },
    );
  }

  Widget _buildReviewsTab(List<Video> reviews) {
    // TODO: May change model
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        return Image.memory(base64Decode(reviews[index].thumbnail ?? ''),
            fit: BoxFit.cover);
      },
    );
  }
}
