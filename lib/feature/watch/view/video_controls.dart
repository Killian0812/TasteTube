import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/utils/user_data.util.dart';
import 'package:video_player/video_player.dart';
import 'attached_products_sheet.dart';

class VideoControls extends StatefulWidget {
  final Video video;
  final VideoPlayerController videoController;
  final bool isScrubbing;
  final ValueChanged<bool> onScrubbingChanged;

  const VideoControls({
    super.key,
    required this.video,
    required this.videoController,
    required this.isScrubbing,
    required this.onScrubbingChanged,
  });

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  bool _isDescriptionExpanded = false;

  bool get _descriptionExceededLimit =>
      widget.video.description != null &&
      widget.video.description!.length > 100;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        VideoPauseButton(
          videoController: widget.videoController,
          isScrubbing: widget.isScrubbing,
        ),
        VideoInfo(
          video: widget.video,
          isDescriptionExpanded: _isDescriptionExpanded,
          onDescriptionToggled: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          descriptionExceededLimit: _descriptionExceededLimit,
        ),
        ReviewTarget(video: widget.video),
        VideoPlayspeed(videoController: widget.videoController),
        VideoScrubber(
          videoController: widget.videoController,
          isScrubbing: widget.isScrubbing,
          onScrubbingChanged: widget.onScrubbingChanged,
        ),
        TimeIndicator(
            videoController: widget.videoController,
            isScrubbing: widget.isScrubbing),
      ],
    );
  }
}

class VideoPauseButton extends StatelessWidget {
  final VideoPlayerController videoController;
  final bool isScrubbing;

  const VideoPauseButton({
    super.key,
    required this.videoController,
    required this.isScrubbing,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          videoController.value.isPlaying
              ? videoController.pause()
              : videoController.play();
        },
        onDoubleTap: () async {
          await context.read<SingleVideoCubit>().likeVideo();
        },
        child: SizedBox(
          height: CommonSize.screenSize.height / 2,
          width: CommonSize.screenSize.width,
          child: Align(
            alignment: Alignment.center,
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: videoController,
              builder: (context, value, child) {
                return Visibility(
                  visible: !value.isPlaying && !isScrubbing,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                    size: 100.0,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class VideoInfo extends StatelessWidget {
  final Video video;
  final bool isDescriptionExpanded;
  final VoidCallback onDescriptionToggled;
  final bool descriptionExceededLimit;

  const VideoInfo({
    super.key,
    required this.video,
    required this.isDescriptionExpanded,
    required this.onDescriptionToggled,
    required this.descriptionExceededLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.only(right: 30),
        margin:
            EdgeInsets.only(left: 30, bottom: isDescriptionExpanded ? 100 : 70),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (video.products.isNotEmpty)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  showAttachedProductsSheet(context, video.products);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black54,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        FontAwesomeIcons.bagShopping,
                        size: 16,
                        color: CommonColor.activeBgColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Attached products: ${video.products.length.toString()}',
                        style:
                            CommonTextStyle.bold.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (video.ownerId == UserDataUtil.getUserId()) {
                  Navigator.of(context).pop();
                  return;
                }
                context.push('/user/${video.ownerId}');
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    foregroundImage: NetworkImage(video.ownerImage),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    video.ownerUsername,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (video.title != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  video.title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (video.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: GestureDetector(
                  onTap: onDescriptionToggled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.description!,
                        maxLines: isDescriptionExpanded ? null : 2,
                        overflow: isDescriptionExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 5),
                      if (descriptionExceededLimit)
                        Text(
                          isDescriptionExpanded ? "See less" : "See more",
                          style: const TextStyle(
                              color: Color.fromARGB(136, 255, 255, 255),
                              fontSize: 16,
                              fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReviewTarget extends StatelessWidget {
  final Video video;

  const ReviewTarget({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        margin: const EdgeInsets.only(right: 25, bottom: 50),
        child: video.targetUserId == null
            ? const SizedBox.shrink()
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  context.push('/user/${video.targetUserId!}');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black54,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Reviewing:     ',
                        style: CommonTextStyle.bold.copyWith(
                            fontStyle: FontStyle.italic, color: Colors.white),
                      ),
                      CircleAvatar(
                        radius: 12,
                        foregroundImage: NetworkImage(video.targetUserImage!),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        video.targetUsername!,
                        style:
                            CommonTextStyle.bold.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class VideoPlayspeed extends StatelessWidget {
  final VideoPlayerController videoController;

  const VideoPlayspeed({super.key, required this.videoController});

  static const List<double> _playbackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: PopupMenuButton<double>(
        initialValue: videoController.value.playbackSpeed,
        tooltip: 'Playback speed',
        onSelected: (double speed) {
          videoController.setPlaybackSpeed(speed);
        },
        itemBuilder: (BuildContext context) {
          return <PopupMenuItem<double>>[
            for (final double speed in _playbackRates)
              PopupMenuItem<double>(
                value: speed,
                child: Text('${speed}x'),
              )
          ];
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          child: Text('${videoController.value.playbackSpeed}x'),
        ),
      ),
    );
  }
}

class VideoScrubber extends StatelessWidget {
  final VideoPlayerController videoController;
  final bool isScrubbing;
  final ValueChanged<bool> onScrubbingChanged;

  const VideoScrubber({
    super.key,
    required this.videoController,
    required this.isScrubbing,
    required this.onScrubbingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        onScrubbingChanged(true);
      },
      onHorizontalDragUpdate: (details) {
        final newPosition = videoController.value.duration *
            (details.localPosition.dx / CommonSize.screenSize.width);
        videoController.seekTo(newPosition);
      },
      onHorizontalDragEnd: (details) {
        onScrubbingChanged(false);
        videoController.play();
      },
      child: VideoProgressIndicator(
        videoController,
        allowScrubbing: false,
        padding: const EdgeInsets.only(bottom: 40),
        colors: const VideoProgressColors(playedColor: Colors.white),
      ),
    );
  }
}

class TimeIndicator extends StatelessWidget {
  final VideoPlayerController videoController;
  final bool isScrubbing;

  const TimeIndicator({
    super.key,
    required this.videoController,
    required this.isScrubbing,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: videoController,
      builder: (context, value, child) {
        if (value.isPlaying && !isScrubbing) {
          return SizedBox.shrink();
        }
        return Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10),
            child: Text(
              "${_formatDuration(videoController.value.position)} / ${_formatDuration(videoController.value.duration)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.isNegative ? 0 : duration.inHours);
    final minutes =
        twoDigits(duration.isNegative ? 0 : duration.inMinutes.remainder(60));
    final seconds =
        twoDigits(duration.isNegative ? 0 : duration.inSeconds.remainder(60));
    return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }
}
