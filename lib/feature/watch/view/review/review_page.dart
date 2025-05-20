import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/home/view/review_cubit.dart';
import 'package:taste_tube/feature/watch/view/widget/video_detail_cubit.dart';
import 'package:taste_tube/feature/watch/view/widget/video_display.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:video_player/video_player.dart';

part 'single_review_page.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  static final Map<String, VideoPlayerController> controllers = {};

  static void pauseVideo(String videoId) {
    if (controllers.containsKey(videoId)) {
      controllers[videoId]!.pause();
    }
  }

  @override
  State<ReviewPage> createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewPage> {
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
    return BlocConsumer<ReviewCubit, ReviewState>(
      listener: (context, state) {
        if (state is ReviewError) {
          ToastService.showToast(context, state.message, ToastType.warning);
        }
      },
      builder: (context, state) {
        if (state is ReviewLoading) {
          return const Center(child: CommonLoadingIndicator.regular);
        }
        if (state is ReviewError || state.videos.isEmpty) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                await context.read<ReviewCubit>().getReviewFeeds();
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
            leading: GoRouterState.of(context).path != '/home'
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
                ReviewPage.pauseVideo(currentPlayingVideoId);
              }
              // Update the currently playing video index
              WidgetsBinding.instance.addPostFrameCallback((_) {
                currentPlayingVideoId = state.videos[index].id;
              });
            },
            itemBuilder: (context, index) {
              return ValueListenableBuilder<String>(
                valueListenable: getIt<ReviewCubit>().currentPlayingVideoId,
                builder: (context, currentPlayingIndex, _) {
                  final video = state.videos[index];
                  return SingleReview.withPrefetch(video);
                },
              );
            },
          ),
        );
      },
    );
  }
}
