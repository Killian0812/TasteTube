part of 'watch_page.dart';

// Wrap in cubit & use BlocBuilder
class SingleVideo extends StatefulWidget {
  final Video video;
  const SingleVideo({super.key, required this.video});

  @override
  State<SingleVideo> createState() => _SingleVideoState();
}

class _SingleVideoState extends State<SingleVideo> {
  late VideoPlayerController _videoController;
  bool _isScrubbing = false;
  bool _isDescriptionExpanded = false;

  bool get _descriptionExceededLimit =>
      widget.video.description != null &&
      widget.video.description!.length > 100;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(widget.video.url);
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..addListener(() {
        if (!_isScrubbing) {
          setState(() {}); // Update position if not scrubbing
        }
      })
      ..initialize().then((_) {
        setState(() {}); // Refresh after initialization
        _videoController.play();
        _videoController.setLooping(true);
      });
  }

  @override
  void dispose() {
    _videoController.removeListener(() {});
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _videoController.value.isInitialized
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Video display
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ),
                _videoInfo(),
                // Center play/pause icon
                _videoPauseButton(),
                // Video Scrub
                _videoScrubber(),
                // Time indicator
                if (_isScrubbing || !_videoController.value.isPlaying)
                  _timeIndicator(),
                // Video interactions
                _videoLikes(),
                _videoComments(),
                _videoShare(),
              ],
            )
          : const CircularProgressIndicator(color: Colors.white),
    );
  }

  Widget _videoInfo() => Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          padding: const EdgeInsets.only(right: 30),
          margin: EdgeInsets.only(
              left: 30, bottom: _isDescriptionExpanded ? 100 : 70),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owner info
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        foregroundImage: NetworkImage(widget.video.ownerImage),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.video.ownerUsername,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 10),
              // Title
              if (widget.video.title != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    widget.video.title!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Description
              if (widget.video.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.description!,
                          maxLines: _isDescriptionExpanded ? null : 2,
                          overflow: _isDescriptionExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (_descriptionExceededLimit)
                          Text(
                            _isDescriptionExpanded ? "See less" : "See more",
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

  Widget _videoPauseButton() => Align(
        alignment: Alignment.center,
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              setState(() {
                _videoController.value.isPlaying
                    ? _videoController.pause()
                    : _videoController.play();
              });
            },
            child: SizedBox(
              height: CommonSize.screenSize.height / 2,
              width: CommonSize.screenSize.width,
              child: Align(
                alignment: Alignment.center,
                child: Visibility(
                  visible: !_videoController.value.isPlaying && !_isScrubbing,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                    size: 100.0,
                  ),
                ),
              ),
            )),
      );

  Widget _videoScrubber() => GestureDetector(
        onHorizontalDragStart: (details) {
          setState(() {
            _isScrubbing = true;
          });
        },
        onHorizontalDragUpdate: (details) {
          final newPosition = _videoController.value.duration *
              (details.localPosition.dx / CommonSize.screenSize.width);
          _videoController.seekTo(newPosition);
        },
        onHorizontalDragEnd: (details) {
          setState(() {
            _isScrubbing = false;
          });
          _videoController.play();
        },
        child: VideoProgressIndicator(
          _videoController,
          allowScrubbing: true,
          padding: const EdgeInsets.only(bottom: 40),
          colors: const VideoProgressColors(playedColor: Colors.white),
        ),
      );

  Widget _timeIndicator() => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          "${_formatDuration(_videoController.value.position)} / ${_formatDuration(_videoController.value.duration)}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      );

  Widget _videoLikes() => Align(
        alignment: const Alignment(0.9, 0.0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Like
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.solidHeart,
                color: widget.video.userLiked ? Colors.red : Colors.white,
                size: 40,
              ),
              Text(
                widget.video.likes.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

  Widget _videoComments() => Align(
        alignment: const Alignment(0.9, 0.15),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // Comment
            // Fetch comments
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FontAwesomeIcons.solidCommentDots,
                color: Colors.white,
                size: 40,
              ),
              Text(
                widget.video.comments.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );

  Widget _videoShare() => Align(
        alignment: const Alignment(0.9, 0.27),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            // TODO: Share
          },
          child: const Icon(
            FontAwesomeIcons.share,
            color: Colors.white,
            size: 30,
          ),
        ),
      );

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
