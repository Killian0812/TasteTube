part of 'review_page.dart';

class SingleReviewPage extends StatelessWidget {
  const SingleReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoDetailCubit, VideoDetailState>(
      builder: (context, state) {
        if (state is VideoDetailError) {
          return Center(child: Text(state.message));
        }
        if (state is VideoDetailLoaded) {
          return BlocProvider(
              create: (context) => SingleVideoCubit(state.video)
                ..fetchDependency()
                ..fetchComments(),
              child: SingleReview(video: state.video));
        }
        return Center(child: CommonLoadingIndicator.regular);
      },
    );
  }
}

class SingleReview extends StatefulWidget {
  final Video video;
  const SingleReview({super.key, required this.video});

  static Widget provider(String videoId) => BlocProvider(
        create: (context) => VideoDetailCubit(videoId)..fetchDependency(),
        child: const SingleReviewPage(),
      );

  static Widget withPrefetch(Video video) => BlocProvider(
        create: (context) => SingleVideoCubit(video)
          ..fetchDependency()
          ..fetchComments(),
        child: SingleReview(video: video),
      );

  @override
  State<SingleReview> createState() => _SingleVideoState();
}

class _SingleVideoState extends State<SingleReview>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _jiggleController;
  late Animation<double> _jiggleAnimation;
  bool _isScrubbing = false;
  bool _useManifestUrl = true;
  bool _hasUserInteracted = false;
  bool _showPlayOverlay = kIsWeb;

  String get videoId => widget.video.id;
  String? get manifestUrl => widget.video.manifestUrl;
  String get url => widget.video.url;

  @override
  void initState() {
    super.initState();
    _jiggleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _jiggleAnimation = Tween<double>(begin: 0, end: 0.3).animate(
      CurvedAnimation(
        parent: _jiggleController,
        curve: Curves.elasticIn,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentPlayingVideoId = videoId;
    });

    _initializeVideoController();
  }

  void _initializeVideoController() {
    final videoUrl =
        _useManifestUrl && manifestUrl != null ? manifestUrl! : url;
    _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
      ..initialize().then((_) {
        if (currentPlayingVideoId == videoId) {
          if (kIsWeb) {
            _tryAutoPlay();
          } else {
            _videoController.play();
            _videoController.setLooping(true);
          }
        }
        setState(() {});
      }).catchError((e) {
        getIt<Logger>().e("Error initializing video", error: e);
        if (_useManifestUrl && manifestUrl != null) {
          setState(() {
            _useManifestUrl = false;
          });
          _videoController.dispose().then((_) {
            _initializeVideoController();
          });
        }
      });

    ReviewPage.controllers[videoId] = _videoController;
  }

  void _tryAutoPlay() async {
    if (_hasUserInteracted) {
      await _videoController.initialize();
      await _videoController.play();
      await _videoController.setLooping(true);
      setState(() {
        _showPlayOverlay = false;
      });
    } else {
      await _videoController.play();
      await _videoController.setLooping(true);
      if (_videoController.value.errorDescription == null) {
        setState(() {
          _showPlayOverlay = false;
        });
      }
    }
  }

  @override
  void dispose() {
    ReviewPage.controllers.remove(videoId);
    _videoController.dispose();
    _jiggleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SingleReview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (videoId == currentPlayingVideoId) {
      _videoController.play();
    } else {
      _videoController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      child: BlocListener<SingleVideoCubit, SingleVideoState>(
        listener: (context, state) {
          if (state is DeleteVideoSuccess) {
            Navigator.of(context).pop();
          } else if (state is DeleteVideoError) {
            ToastService.showToast(context, state.message, ToastType.error);
          }
        },
        child: _videoController.value.isInitialized
            ? VideoContent(
                video: widget.video,
                videoController: _videoController,
                isScrubbing: _isScrubbing,
                onScrubbingChanged: (value) =>
                    setState(() => _isScrubbing = value),
                jiggleAnimation: _jiggleAnimation,
                jiggleController: _jiggleController,
                showPlayOverlay: _showPlayOverlay,
                onUserInteracted: () {
                  setState(() {
                    _hasUserInteracted = true;
                    _tryAutoPlay();
                  });
                },
              )
            : VideoThumbnail(
                thumbnail: widget.video.thumbnail,
                showPlayOverlay: _showPlayOverlay,
                onPlayTapped: () {
                  setState(() {
                    _hasUserInteracted = true;
                    _tryAutoPlay();
                  });
                },
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
