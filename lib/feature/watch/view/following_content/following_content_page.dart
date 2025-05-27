import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/home/view/following_content_cubit.dart';
import 'package:taste_tube/feature/watch/view/widget/video_detail_cubit.dart';
import 'package:taste_tube/feature/watch/view/widget/video_display.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:video_player/video_player.dart';

part 'single_following_content_page.dart';

class FollowingContentPage extends StatefulWidget {
  const FollowingContentPage({super.key});

  static final Map<String, VideoPlayerController> controllers = {};

  static void pauseVideo(String videoId) {
    if (controllers.containsKey(videoId)) {
      controllers[videoId]!.pause();
    }
  }

  @override
  State<FollowingContentPage> createState() => FollowingContentPageState();
}

class FollowingContentPageState extends State<FollowingContentPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FollowingContentCubit, FollowingContentState>(
      listener: (context, state) {
        if (state is FollowingContentError) {
          ToastService.showToast(context, state.message, ToastType.warning);
        }
      },
      builder: (context, state) {
        if (state is FollowingContentLoading) {
          return const Center(child: CommonLoadingIndicator.regular);
        }
        if (state is FollowingContentError || state.videos.isEmpty) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                await context
                    .read<FollowingContentCubit>()
                    .getFollowingContentFeeds();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  child: const Center(
                    child: Text('No videos to show'),
                  ),
                ),
              ),
            ),
          );
        }
        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: GoRouterState.of(context).path != '/'
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : null,
          ),
          body: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: state.videos.length,
            onPageChanged: (int index) {
              if (currentPlayingVideoId != "none") {
                FollowingContentPage.pauseVideo(currentPlayingVideoId);
              }
              // Update the currently playing video index
              WidgetsBinding.instance.addPostFrameCallback((_) {
                currentPlayingVideoId = state.videos[index].id;
              });
            },
            itemBuilder: (context, index) {
              return ValueListenableBuilder<String>(
                valueListenable:
                    getIt<FollowingContentCubit>().currentPlayingVideoId,
                builder: (context, currentPlayingIndex, _) {
                  final video = state.videos[index];
                  return SingleFollowingContent.provider(
                    video.id,
                    video: video,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
