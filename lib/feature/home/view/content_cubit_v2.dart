import 'dart:convert';
import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/home/domain/content_repo.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/injection.dart';

abstract class ContentStateV2 {
  final int currentReelIndex;
  final List<Video> videos;
  final BetterPlayerController? reelsController;

  const ContentStateV2(this.currentReelIndex, this.videos,
      {this.reelsController});
}

class ContentLoadingV2 extends ContentStateV2 {
  const ContentLoadingV2(super.currentReelIndex, super.videos);
}

class ContentLoadedV2 extends ContentStateV2 {
  ContentLoadedV2(
    super.currentReelIndex,
    super.videos, {
    super.reelsController,
  });
}

class ContentErrorV2 extends ContentStateV2 {
  final String message;

  const ContentErrorV2(super.currentReelIndex, super.videos,
      {super.reelsController, required this.message});
}

class ContentCubitV2 extends Cubit<ContentStateV2> {
  final ContentRepository repository = getIt<ContentRepository>();
  final cacheController =
      BetterPlayerController(const BetterPlayerConfiguration());

  ContentCubitV2() : super(ContentLoadingV2(0, []));

  Future<void> getFeeds() async {
    try {
      final result = await repository.getFeeds();
      result.fold(
        (error) => emit(ContentErrorV2(
          state.currentReelIndex,
          state.videos,
          message: error.message ?? 'Error fetching videos',
        )),
        (feedVideos) {
          feedVideos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          if (feedVideos.isNotEmpty) {
            if (feedVideos.length > 1) {
              cacheController.preCache(initDataSource(feedVideos[1].url));
            }
            final reelsController = createReelsController(feedVideos.first);
            emit(ContentLoadedV2(
              0,
              feedVideos,
              reelsController: reelsController,
            ));
          }
        },
      );
    } catch (e) {
      emit(ContentErrorV2(state.currentReelIndex, state.videos,
          message: e.toString()));
    }
  }

  BetterPlayerController createReelsController(Video video) {
    disposeController();

    final betterPlayerDataSource = initDataSource(video.url);
    final reelsController = BetterPlayerController(
      BetterPlayerConfiguration(
        placeholder: Image.memory(
          base64Decode(video.thumbnail ?? ''),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        aspectRatio: 9 / 16,
        fit: BoxFit.cover,
        autoDispose: false,
        autoPlay: true,
        looping: true,
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          controlBarColor: Colors.black26,
          showControls: false,
          enableFullscreen: false,
          enableProgressBar: false,
          loadingWidget: SizedBox(),
        ),
      ),
      betterPlayerDataSource: betterPlayerDataSource,
    );

    reelsController.addEventsListener((event) {
      if (reelsController.isVideoInitialized()! &&
          !reelsController.isPlaying()!) {
        emit(state);
      }
    });

    return reelsController;
  }

  BetterPlayerDataSource initDataSource(String url) {
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 3000,
        maxBufferMs: 10000,
        bufferForPlaybackMs: 1000,
        bufferForPlaybackAfterRebufferMs: 2000,
      ),
      cacheConfiguration: BetterPlayerCacheConfiguration(
        useCache: true,
        preCacheSize: 3 * 1024 * 1024,
        maxCacheSize: 500 * 1024 * 1024,
        maxCacheFileSize: 3 * 1024 * 1024,
        key: Platform.isIOS ? url : null,
      ),
    );
  }

  void onPageChange(int index) async {
    try {
      final reelsController = createReelsController(state.videos[index]);

      if (index < state.videos.length - 1) {
        cacheController.preCache(initDataSource(state.videos[index + 1].url));
      }

      emit(ContentLoadedV2(index, state.videos,
          reelsController: reelsController));
    } catch (e) {
      emit(ContentErrorV2(index, state.videos, message: e.toString()));
    }
  }

  void disposeController() {
    if (state.reelsController != null) {
      state.reelsController?.removeEventsListener((event) {});
      state.reelsController?.dispose(forceDispose: true);
    }
  }

  void playVideo() => state.reelsController?.play();
}
