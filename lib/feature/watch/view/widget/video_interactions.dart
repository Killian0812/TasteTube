import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taste_tube/api.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/feature/watch/view/widget/video_comments.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'video_options_sheet.dart';

class VideoInteractions extends StatelessWidget {
  final Video video;
  final Animation<double> jiggleAnimation;
  final AnimationController jiggleController;

  const VideoInteractions({
    super.key,
    required this.video,
    required this.jiggleAnimation,
    required this.jiggleController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VideoLikes(
          jiggleAnimation: jiggleAnimation,
          jiggleController: jiggleController,
        ),
        const SizedBox(height: 20),
        VideoComments(video: video),
        const SizedBox(height: 20),
        VideoShare(video: video),
        const SizedBox(height: 10),
        VideoSettings(video: video),
      ],
    );
  }
}

class VideoLikes extends StatelessWidget {
  final Animation<double> jiggleAnimation;
  final AnimationController jiggleController;

  const VideoLikes({
    super.key,
    required this.jiggleAnimation,
    required this.jiggleController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SingleVideoCubit, SingleVideoState>(
      listener: (context, state) {
        if (state.interaction.userLiked) {
          jiggleController.forward().then((_) => jiggleController.reset());
        }
      },
      listenWhen: (previous, current) {
        if (previous.interaction.userLiked == current.interaction.userLiked) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        final loading = state is SingleVideoLoading;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            if (loading) return;
            if (state.interaction.userLiked) {
              await context.read<SingleVideoCubit>().unlikeVideo();
            } else {
              await context.read<SingleVideoCubit>().likeVideo();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: jiggleAnimation,
                builder: (context, child) => Transform.rotate(
                  angle: jiggleAnimation.value,
                  child: Transform.scale(
                    scale: 1 + (jiggleAnimation.value * 0.5),
                    child: Icon(
                      FontAwesomeIcons.solidHeart,
                      color: state.interaction.userLiked
                          ? Colors.red
                          : Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              Text(
                state.interaction.totalLikes.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}

class VideoComments extends StatelessWidget {
  final Video video;

  const VideoComments({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final cubit = context.read<SingleVideoCubit>();
        await cubit.fetchComments();
        if (context.mounted) {
          showCommentsBottomSheet(context, cubit);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            FontAwesomeIcons.solidCommentDots,
            color: Colors.white,
            size: 40,
          ),
          BlocBuilder<SingleVideoCubit, SingleVideoState>(
            builder: (context, state) {
              if (state is SingleVideoLoading) {
                return const SizedBox.shrink();
              }
              return Text(
                state.comments.length.toString(),
                style: const TextStyle(color: Colors.white),
              );
            },
          ),
        ],
      ),
    );
  }
}

class VideoShare extends StatelessWidget {
  final Video video;

  const VideoShare({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final box = context.findRenderObject() as RenderBox?;
        context.read<SingleVideoCubit>().shareVideo();
        await Share.shareUri(
          Uri.parse(Api.baseUrl),
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      },
      child: const Icon(
        FontAwesomeIcons.share,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}

class VideoSettings extends StatelessWidget {
  final Video video;

  const VideoSettings({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final cubit = context.read<SingleVideoCubit>();
        showVideoOptionsSheet(context, cubit, video);
      },
      child: const Icon(
        Icons.more_horiz,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
