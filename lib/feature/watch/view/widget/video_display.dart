import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:video_player/video_player.dart';
import 'video_controls.dart';
import 'video_interactions.dart';

class VideoContent extends StatelessWidget {
  final Video video;
  final VideoPlayerController videoController;
  final bool isScrubbing;
  final ValueChanged<bool> onScrubbingChanged;
  final Animation<double> jiggleAnimation;
  final AnimationController jiggleController;
  final bool showPlayOverlay;
  final VoidCallback onUserInteracted;

  const VideoContent({
    super.key,
    required this.video,
    required this.videoController,
    required this.isScrubbing,
    required this.onScrubbingChanged,
    required this.jiggleAnimation,
    required this.jiggleController,
    required this.showPlayOverlay,
    required this.onUserInteracted,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        VideoDisplay(videoController: videoController),
        SafeArea(
          child: VideoControls(
            video: video,
            videoController: videoController,
            isScrubbing: isScrubbing,
            onScrubbingChanged: onScrubbingChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: VideoInteractions(
              video: video,
              jiggleAnimation: jiggleAnimation,
              jiggleController: jiggleController,
            ),
          ),
        ),
      ],
    );
  }
}

class VideoThumbnail extends StatelessWidget {
  final String? thumbnail;
  final bool showPlayOverlay;
  final VoidCallback onPlayTapped;

  const VideoThumbnail({
    super.key,
    this.thumbnail,
    required this.showPlayOverlay,
    required this.onPlayTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: thumbnail != null
          ? Stack(
              alignment: Alignment.center,
              children: [
                Image.memory(
                  base64Decode(thumbnail!),
                  fit: BoxFit.contain,
                  height: double.infinity,
                ),
                showPlayOverlay
                    ? GestureDetector(
                        onTap: onPlayTapped,
                        child: Container(
                          color: Colors.black54,
                          child: const Center(
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Color.fromRGBO(255, 255, 255, 0.8),
                              size: 100.0,
                            ),
                          ),
                        ),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ],
            )
          : CommonLoadingIndicator.regular,
    );
  }
}

class VideoDisplay extends StatelessWidget {
  final VideoPlayerController videoController;

  const VideoDisplay({super.key, required this.videoController});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: videoController.value.aspectRatio,
        child: VideoPlayer(videoController),
      ),
    );
  }
}
