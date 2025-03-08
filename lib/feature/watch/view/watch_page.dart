import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/shop/view/quantity_dialog.dart';
import 'package:taste_tube/global_bloc/download/download_cubit.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_data/watch/comment.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/utils/user_data.util.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'single_video_page.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({super.key});

  static final Map<String, VideoPlayerController> controllers = {};

  static void pauseVideo(String videoId) {
    if (controllers.containsKey(videoId)) {
      controllers[videoId]!.pause();
    }
  }

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
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
    return BlocConsumer<ContentCubit, ContentState>(
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
              setState(() {});

              if (currentPlayingVideoId != "none") {
                WatchPage.pauseVideo(currentPlayingVideoId);
              }
              // Update the currently playing video index
              currentPlayingVideoId = state.videos[index].id;
            },
            itemBuilder: (context, index) {
              return ValueListenableBuilder<String>(
                valueListenable: getIt<ContentCubit>().currentPlayingVideoId,
                builder: (context, currentPlayingIndex, _) {
                  final video = state.videos[index];
                  return SingleVideo.provider(video);
                },
              );
            },
          ),
        );
      },
    );
  }
}
