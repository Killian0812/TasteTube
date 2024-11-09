import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/feature/watch/video.dart';
import 'package:taste_tube/injection.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class WatchPage extends StatefulWidget {
  final List<Video> videos;
  final int initialIndex;

  const WatchPage({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late PageController _pageController;
  late VideoPlayerController _videoController;
  late int currentIndex;
  bool _isScrubbing = false; // Track if scrubbing

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
    _initializeVideoPlayer(widget.videos[currentIndex].url);
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
    _videoController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
      _videoController.removeListener(() {});
      _videoController.dispose(); // Dispose old one, aync
      _initializeVideoPlayer(
          widget.videos[currentIndex].url); // Play the new one
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(
                Icons.download,
                color: Colors.white,
              ),
              onPressed: () async {
                await _downloadVideo(widget.videos[currentIndex].url);
              },
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return _buildVideoPage(video);
        },
      ),
    );
  }

  Future<void> _downloadVideo(String videoUrl) async {
    try {
      final uuid = getIt<Uuid>().v4();
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$uuid';

      final dio = Dio();
      await dio.download(
        videoUrl,
        filePath,
      );

      Fluttertoast.showToast(
        msg: "Video downloaded successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to download video: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildVideoPage(Video video) {
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
                // Center play/pause icon
                Align(
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
                            visible: !_videoController.value.isPlaying &&
                                !_isScrubbing,
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color.fromRGBO(255, 255, 255, 0.8),
                              size: 100.0,
                            ),
                          ),
                        ),
                      )),
                ),
                // Video Scrub
                GestureDetector(
                  onHorizontalDragStart: (details) {
                    setState(() {
                      _isScrubbing = true;
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    final newPosition = _videoController.value.duration *
                        (details.localPosition.dx /
                            CommonSize.screenSize.width);
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
                    colors:
                        const VideoProgressColors(playedColor: Colors.white),
                  ),
                ),
                // Time indicator
                if (_isScrubbing || !_videoController.value.isPlaying)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      "${_formatDuration(_videoController.value.position)} / ${_formatDuration(_videoController.value.duration)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            )
          : const CircularProgressIndicator(
              color: Colors.white,
            ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
