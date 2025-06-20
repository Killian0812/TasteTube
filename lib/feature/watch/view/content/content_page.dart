import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/watch/view/widget/video_detail_cubit.dart';
import 'package:taste_tube/feature/watch/view/widget/video_display.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

part 'single_content_page.dart';

class ContentPage extends StatefulWidget {
  const ContentPage({super.key});

  static final Map<String, VideoPlayerController> controllers = {};

  static void pauseAllVideos() {
    for (final controller in controllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  static void playCurrentVideo({String? videoId}) {
    if (videoId != null) {
      currentPlayingVideoId = videoId;
    }
    if (controllers.keys.contains(currentPlayingVideoId)) {
      controllers[currentPlayingVideoId]!.play();
    }
  }

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  late PageController _pageController;
  DateTime? _watchStartTime;

  @override
  void initState() {
    super.initState();
    _watchStartTime = DateTime.now();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('content-page'),
      onVisibilityChanged: (info) {
        if (info.visibleBounds == Rect.zero) {
          // If not visible
          ContentPage.pauseAllVideos();
        } else {
          ContentPage.playCurrentVideo();
        }
      },
      child: BlocConsumer<ContentCubit, ContentState>(
        listener: (context, state) {
          if (state is ContentError) {
            ToastService.showToast(context, state.message, ToastType.warning);
          }
        },
        builder: (context, state) {
          if (state is ContentLoading) {
            return const Center(child: CommonLoadingIndicator.regular);
          }
          if (state is ContentError || state.videos.isEmpty) {
            return Scaffold(
              body: RefreshIndicator(
                onRefresh: () async {
                  await context.read<ContentCubit>().getFeeds();
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
                ContentPage.pauseAllVideos();
                ContentPage.playCurrentVideo(videoId: state.videos[index].id);
              },
              itemBuilder: (context, index) {
                final video = state.videos[index];
                return VisibilityDetector(
                  key: ValueKey(video.id),
                  onVisibilityChanged: (info) {
                    if (info.visibleBounds == Rect.zero) {
                      if (_watchStartTime != null) {
                        final watchDuration = DateTime.now()
                            .difference(_watchStartTime!)
                            .inSeconds;
                        getIt<ContentCubit>()
                            .watchedVideo(video.id, watchDuration);
                      }
                      _watchStartTime = DateTime.now();
                    }
                  },
                  child: SingleContent.provider(
                    video.id,
                    video: video,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
