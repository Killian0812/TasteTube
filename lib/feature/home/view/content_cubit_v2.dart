import 'dart:convert';
import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:taste_tube/feature/home/domain/content_repo.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/injection.dart';

class VideoPlayerProvider extends ChangeNotifier {
  var currentReelIndex = 0;
  var loading = true;
  final ContentRepository repository = getIt<ContentRepository>();
  BetterPlayerController? reelsController =
      BetterPlayerController(const BetterPlayerConfiguration());
  final cacheController =
      BetterPlayerController(const BetterPlayerConfiguration());
  List<Video> videos = [];

  void fetchReelsFromAPI() async {
    try {
      final result = await repository.getFeeds();
      result.fold(
        (error) => {},
        (videos) {
          videos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          videos = videos;
          if (videos.isNotEmpty) {
            loading = false;
            if (videos.length > 1) {
              cacheController.preCache(initDataSource(videos[1].url));
            }
            createReelsController(videos.first.url);
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  void createReelsController(String url) {
    disposeController();

    BetterPlayerDataSource betterPlayerDataSource = initDataSource(url);
    reelsController = BetterPlayerController(
      BetterPlayerConfiguration(
        placeholder: Image.memory(
          base64Decode(videos[currentReelIndex].thumbnail ?? ''),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        aspectRatio: 9 / 16,
        fit: BoxFit.cover,
        autoDispose: false,
        autoPlay: false,
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

    reelsController?.addEventsListener((event) {
      if (reelsController!.isVideoInitialized()! &&
          !reelsController!.isPlaying()!) {
        notifyListeners();
      }
    });
  }

  playVideo() => reelsController?.play();

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
        preCacheSize: 3 * 1024 * 1024, //It will cache 3MB of the video
        maxCacheSize: 500 *
            1024 *
            1024, //Max cache will be 500MB and when it reaches 500MB it will release the initial cached videos
        maxCacheFileSize: 3 * 1024 * 1024, //Max size for cache
        key: Platform.isIOS ? url : null,
      ),
    );
  }

  onPageChange(int index) async {
    try {
      //The variable currentReelIndex is updated to reflect the index of the current video reel being viewed.
      currentReelIndex = index;

      //A new video controller is created and initialized for the video URL corresponding to the current index.
      createReelsController(videos[currentReelIndex].url);

      //If the current reel is not the last one, the function pre-caches the next video's data and its thumbnail.
      if (currentReelIndex < videos.length - 1) {
        cacheController
            .preCache(initDataSource(videos[currentReelIndex + 1].url));
      }
    } catch (e) {
      rethrow;
    }
  }

  disposeController() {
    if (reelsController != null) {
      reelsController?.removeEventsListener((event) {});
      reelsController?.dispose(forceDispose: true);
      reelsController = null;
    }
  }
}
