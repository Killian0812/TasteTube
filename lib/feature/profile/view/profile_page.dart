import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/profile/data/user.dart';
import 'package:taste_tube/feature/profile/view/profile_cubit.dart';
import 'package:taste_tube/feature/watch/video.dart';

part 'profile_page.ext.dart';

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
        final isOwner = context.read<ProfileCubit>().isOwner;

        if (state is ProfileSuccess) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(state.user.username),
            ),
            body: Column(
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
                  state.user.email ?? state.user.phone ?? 'No contact info',
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProfileStat('Following', state.user.followings ?? 0),
                    const SizedBox(width: 20),
                    _buildProfileStat('Followers', state.user.followers ?? 0),
                  ],
                ),
                const SizedBox(height: 20),
                if (isOwner)
                  Row(
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
                  ),
                const SizedBox(height: 10),
                (state.user.bio == null || state.user.bio!.isEmpty)
                    ? const Text('No bio')
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          state.user.bio ?? '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                const SizedBox(height: 20),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.grid_on)),
                            Tab(icon: Icon(Icons.favorite)),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildVideosTab(state.user.videos, isOwner),
                              _buildLikedVideosTab(state.user.likedVideos),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (state is ProfileLoading) {
          return const Center(
            child: CommonLoadingIndicator.regular,
          );
        }
        return Center(
          child: FloatingActionButton(
            heroTag: 'profile reset',
            onPressed: () {
              final cubit = context.read<ProfileCubit>();
              cubit.init(context);
            },
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
            context.push('/watch',
                extra: {'videos': videos, 'initialIndex': index});
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
}
