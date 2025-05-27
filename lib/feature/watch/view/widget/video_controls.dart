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
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        VideoPauseButton(
          videoController: widget.videoController,
          isScrubbing: widget.isScrubbing,
        ),
        VideoInfo(video: widget.video),
        ReviewTarget(video: widget.video),
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
                if (!value.isInitialized) {
                  return const CircularProgressIndicator();
                }
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

class VideoInfo extends StatefulWidget {
  final Video video;

  const VideoInfo({
    super.key,
    required this.video,
  });

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> {
  bool isDescriptionExpanded = false;

  bool get descriptionExceededLimit {
    final width = MediaQuery.of(context).size.width;
    int limit;
    if (width < 350) {
      limit = 100;
    } else if (width < 500) {
      limit = 150;
    } else {
      limit = 200;
    }
    return widget.video.description != null &&
        widget.video.description!.length > limit;
  }

  void onDescriptionToggled() {
    if (descriptionExceededLimit) {
      setState(() {
        isDescriptionExpanded = !isDescriptionExpanded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.only(right: 60),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final span = TextSpan(
                      text: video.description!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    );

                    final tp = TextPainter(
                      text: span,
                      maxLines: 2,
                      textDirection: TextDirection.ltr,
                    );

                    tp.layout(maxWidth: constraints.maxWidth);
                    final isOverflowing = tp.didExceedMaxLines;

                    return GestureDetector(
                      onTap: () {
                        if (isOverflowing) {
                          setState(() {
                            isDescriptionExpanded = !isDescriptionExpanded;
                          });
                        }
                      },
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
                          if (isOverflowing)
                            Text(
                              isDescriptionExpanded ? "See less" : "See more",
                              style: const TextStyle(
                                color: Color.fromARGB(136, 255, 255, 255),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReviewTarget extends StatefulWidget {
  final Video video;

  const ReviewTarget({super.key, required this.video});

  @override
  State<ReviewTarget> createState() => _ReviewTargetState();
}

class _ReviewTargetState extends State<ReviewTarget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.video.targetUserId == null) return const SizedBox.shrink();

    final collapsedWidth = 56.0;
    final expandedWidth = 250.0;

    return Align(
      alignment: Alignment.bottomRight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: _expanded ? expandedWidth : collapsedWidth,
        margin: const EdgeInsets.only(right: 25, bottom: 50),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          onLongPress: () {
            context.push('/user/${widget.video.targetUserId!}');
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Colors.black54,
            ),
            child: _expanded
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Reviewing:     ',
                          style: CommonTextStyle.bold.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: CircleAvatar(
                            radius: 12,
                            foregroundImage:
                                NetworkImage(widget.video.targetUserImage!),
                          ),
                        ),
                        const WidgetSpan(child: SizedBox(width: 10)),
                        TextSpan(
                          text: widget.video.targetUsername!,
                          style: CommonTextStyle.bold
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                : CircleAvatar(
                    radius: 12,
                    foregroundImage:
                        NetworkImage(widget.video.targetUserImage!),
                  ),
          ),
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
