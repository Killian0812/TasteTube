part of 'watch_page.dart';

class SingleVideo extends StatefulWidget {
  final Video video;
  const SingleVideo({super.key, required this.video});

  @override
  State<SingleVideo> createState() => _SingleVideoState();
}

class _SingleVideoState extends State<SingleVideo>
    with AutomaticKeepAliveClientMixin {
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
    super.build(context);
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
            onDoubleTap: () async {
              await context.read<SingleVideoCubit>().likeVideo();
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
      child: BlocBuilder<SingleVideoCubit, SingleVideoState>(
        builder: (context, state) {
          final loading = state is SingleVideoLoading;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              if (!state.video.userLiked) {
                await context.read<SingleVideoCubit>().likeVideo();
              } else {
                await context.read<SingleVideoCubit>().unlikeVideo();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.solidHeart,
                  color: (loading || !state.video.userLiked)
                      ? Colors.white
                      : Colors.red,
                  size: 40,
                ),
                if (!loading)
                  Text(
                    state.video.likes.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
          );
        },
      ));

  Widget _videoComments() => Align(
        alignment: const Alignment(0.9, 0.15),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final cubit = context.read<SingleVideoCubit>();
            await cubit.fetchComments();
            if (mounted) _showCommentsBottomSheet(context, cubit);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FontAwesomeIcons.solidCommentDots,
                color: Colors.white,
                size: 40,
              ),
              BlocBuilder<SingleVideoCubit, SingleVideoState>(
                builder: (context, state) {
                  if (state is SingleVideoLoading) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    state.video.comments.toString(),
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),
            ],
          ),
        ),
      );

  void _showCommentsBottomSheet(BuildContext context, SingleVideoCubit cubit) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.6,
          child: LayoutBuilder(
            builder: (context, constraints) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "Comments",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  Expanded(
                    child: BlocBuilder<SingleVideoCubit, SingleVideoState>(
                      bloc: cubit,
                      builder: (context, state) {
                        final comments = state.comments.reversed.toList();

                        if (comments.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text(
                                "Be the first to comment!",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.only(top: 30),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return _buildCommentTile(comment, cubit);
                          },
                        );
                      },
                    ),
                  ),
                  _buildCommentInputField(context, commentController, cubit),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentInputField(BuildContext context,
      TextEditingController commentController, SingleVideoCubit cubit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Add a comment...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              if (commentController.text.isNotEmpty) {
                cubit.postComment(commentController.text);
                commentController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment, SingleVideoCubit cubit) {
    final String formattedDate =
        DateFormat.yMMMd().add_jm().format(comment.createdAt);

    return ListTile(
      onLongPress: () async {
        bool? confirmed = await showConfirmDialog(
          context,
          title: "Confirm delete comment",
          body: 'Are you sure you want to delete this comment?',
          contrast: true,
        );
        if (confirmed != true) {
          return;
        }
        await cubit.deleteComment(comment.id);
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(comment.avatar),
      ),
      title: Text(
        comment.username,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.text,
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            formattedDate,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

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

  @override
  bool get wantKeepAlive => true;
}
