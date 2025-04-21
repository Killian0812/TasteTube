part of 'watch_page.dart';

class SingleVideo extends StatefulWidget {
  final Video video;
  const SingleVideo({super.key, required this.video});

  static Widget provider(Video video) => BlocProvider(
        create: (context) => SingleVideoCubit(video)
          ..fetchDependency()
          ..fetchComments(),
        child: SingleVideo(video: video),
      );

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

  late FocusNode? _focusNode;

  String get videoId => widget.video.id;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentPlayingVideoId = videoId;
    });

    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.video.url))
          ..initialize().then((_) {
            setState(() {});
            if (currentPlayingVideoId == videoId) {
              _videoController.play();
              _videoController.setLooping(true);
            }
          });

    WatchPage.controllers[videoId] = _videoController;
  }

  @override
  void dispose() {
    WatchPage.controllers.remove(videoId);
    _videoController.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SingleVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.video.id == currentPlayingVideoId) {
      _videoController.play();
    } else {
      _videoController.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<SingleVideoCubit, SingleVideoState>(
      listener: _handleStateChanges,
      child: Center(
        child: _videoController.value.isInitialized
            ? _buildVideoContent()
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, SingleVideoState state) {
    if (state is DeleteVideoSuccess) {
      Navigator.of(context).pop();
    } else if (state is DeleteVideoError) {
      ToastService.showToast(context, state.message, ToastType.error);
    }
  }

  Widget _buildVideoContent() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _buildVideoDisplay(),
        SafeArea(child: _buildVideoControls()),
        _videoLikes(),
        _videoComments(),
        _videoShare(),
        _videoSettings(),
      ],
    );
  }

  Widget _buildVideoDisplay() {
    return Align(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: VideoPlayer(_videoController),
      ),
    );
  }

  Widget _buildVideoControls() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _videoPauseButton(),
        _videoInfo(),
        _reviewTarget(),
        _videoScrubber(),
        if (_isScrubbing || !_videoController.value.isPlaying) _timeIndicator(),
      ],
    );
  }

  Widget _reviewTarget() => Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: const EdgeInsets.only(right: 25, bottom: 50),
          child: widget.video.targetUserId == null
              ? const SizedBox.shrink()
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.push('/user/${widget.video.targetUserId!}');
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
                          foregroundImage:
                              NetworkImage(widget.video.targetUserImage!),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.video.targetUsername!,
                          style: CommonTextStyle.bold
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      );

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
              // Attached products
              if (widget.video.products.isNotEmpty)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _showAttachedProduct(context, widget.video.products);
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
                          'Attached products: ${widget.video.products.length.toString()}',
                          style: CommonTextStyle.bold
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

              // Owner info
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (widget.video.ownerId == UserDataUtil.getUserId()) {
                      Navigator.of(context).pop();
                      return;
                    }
                    context.push('/user/${widget.video.ownerId}');
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

  void _showAttachedProduct(BuildContext context, List<Product> products) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int currentIndex = 0;
        return BlocListener<CartCubit, CartState>(
          listener: (context, state) {
            if (state is CartError) {
              ToastService.showToast(context, state.error, ToastType.warning);
            }
            if (state is CartSuccess) {
              ToastService.showToast(context, state.success, ToastType.success);
            }
            if (state is AddedToCartAndReadyToPay) {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(builder: (context) => PaymentPage.provider()),
              );
            }
          },
          child: FractionallySizedBox(
            heightFactor: 0.6,
            child: StatefulBuilder(
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (products.length > 1)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: currentIndex > 0
                                    ? Colors.white
                                    : Colors.transparent,
                              ),
                              onPressed: () {
                                if (currentIndex > 0) {
                                  snapshot(() {
                                    currentIndex--;
                                  });
                                }
                              },
                            ),
                            Text(
                              'Product ${currentIndex + 1} of ${products.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: currentIndex < products.length - 1
                                    ? Colors.white
                                    : Colors.transparent,
                              ),
                              onPressed: () {
                                if (currentIndex < products.length - 1) {
                                  snapshot(() {
                                    currentIndex++;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      Expanded(
                        child: PageView.builder(
                          itemCount: products.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final product = products[currentIndex];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Swappable product images
                                Expanded(
                                  child: PageView(
                                    children: product.images.map((image) {
                                      return Image.network(image.url,
                                          fit: BoxFit.cover);
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Product Info
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (product.description != null &&
                                    product.description!.isNotEmpty)
                                  Text(
                                    product.description!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                Text(
                                  CurrencyUtil.amountWithCurrency(
                                      product.cost, product.currency),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.green),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    context.pushNamed('single-shop',
                                        pathParameters: {
                                          'shopId': product.userId,
                                        },
                                        extra: {
                                          'shopImage': product.userImage,
                                          'shopName': product.username,
                                          'shopPhone': product.userPhone,
                                        });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(product.userImage),
                                        radius: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        product.username,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Action Buttons
                                if (product.ship)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            int? quantity =
                                                await showDialog<int>(
                                              context: context,
                                              builder: (context) =>
                                                  const QuantityInputDialog(),
                                            );

                                            if (context.mounted &&
                                                quantity != null) {
                                              context
                                                  .read<CartCubit>()
                                                  .addToCart(product, quantity);
                                            }
                                          },
                                          style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: CommonColor
                                                      .activeBgColor)),
                                          child: const Text(
                                            'Add to Cart',
                                            style: TextStyle(
                                                color:
                                                    CommonColor.activeBgColor),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            int? quantity =
                                                await showDialog<int>(
                                              context: context,
                                              builder: (context) =>
                                                  const QuantityInputDialog(),
                                            );
                                            if (!context.mounted ||
                                                quantity == null ||
                                                quantity < 1) {
                                              return;
                                            }
                                            context
                                                .read<CartCubit>()
                                                .addToCartAndPayImmediate(
                                                    product, quantity);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                CommonColor.activeBgColor,
                                          ),
                                          child: const Text(
                                            'Buy Now',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

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

  Widget _timeIndicator() => ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: _videoController,
        builder: (context, value, child) => Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 10),
            child: Text(
              "${_formatDuration(_videoController.value.position)} / ${_formatDuration(_videoController.value.duration)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
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
              if (loading) return;
              if (state.interaction.userLiked) {
                await context.read<SingleVideoCubit>().unlikeVideo();
              } else {
                await context.read<SingleVideoCubit>().likeVideo();
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.solidHeart,
                  color:
                      state.interaction.userLiked ? Colors.red : Colors.white,
                  size: 40,
                ),
                Text(
                  state.interaction.totalLikes.toString(),
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
                    state.comments.length.toString(),
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
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
      child: BlocBuilder<SingleVideoCubit, SingleVideoState>(
        bloc: cubit,
        builder: (context, state) => Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: commentController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: state.replyingComment != null
                      ? 'Replying to ${state.replyingComment!.username}'
                      : "Add a comment...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: state.replyingComment != null
                      ? IconButton(
                          onPressed: () {
                            cubit.setReplyToComment(null);
                            commentController.clear();
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                        )
                      : null,
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
      ),
    );
  }

  Widget _buildCommentTile(Comment comment, SingleVideoCubit cubit) {
    final String relativeTime =
        timeago.format(comment.createdAt, allowFromNow: true);
    final expansionTileController = ExpansionTileController();

    return GestureDetector(
      onLongPress: () async {
        bool? confirmed = await showConfirmDialog(
          context,
          title: "Confirm delete comment",
          body: 'Are you sure you want to delete this comment?',
        );
        if (confirmed != true) {
          return;
        }
        await cubit.deleteComment(comment);
      },
      child: ExpansionTile(
        controller: expansionTileController,
        tilePadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
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
            Row(
              children: [
                Text(
                  relativeTime,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 30),
                if (comment.replies.isNotEmpty)
                  Text(
                    '${comment.replies.length} replies',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(width: 30),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    cubit.setReplyToComment(comment);
                    expansionTileController.expand();
                    _focusNode?.requestFocus();
                  },
                  child: Text(
                    'Reply',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const SizedBox.shrink(),
        childrenPadding: const EdgeInsets.only(left: 30),
        children: [
          for (Comment reply in comment.replies.reversed)
            _buildReplyTile(reply, cubit)
        ],
      ),
    );
  }

  Widget _buildReplyTile(Comment reply, SingleVideoCubit cubit) {
    final String relativeTime = timeago.format(reply.createdAt);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () async {
        bool? confirmed = await showConfirmDialog(
          context,
          title: "Confirm delete comment",
          body: 'Are you sure you want to delete this comment?',
        );
        if (confirmed != true) {
          return;
        }
        await cubit.deleteComment(reply);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 40.0, right: 10.0),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(reply.avatar),
        ),
        title: Text(
          reply.username,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reply.text,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              relativeTime,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoShare() => Align(
        alignment: const Alignment(0.9, 0.27),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final box = context.findRenderObject() as RenderBox?;
            context.read<SingleVideoCubit>().shareVideo();
            await Share.shareUri(
              // TODO: Update to current video url
              Uri.parse(Api.baseUrl),
              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
            );
          },
          child: const Icon(
            FontAwesomeIcons.share,
            color: Colors.white,
            size: 30,
          ),
        ),
      );

  Widget _videoSettings() => Align(
        alignment: const Alignment(0.9, 0.39),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final cubit = context.read<SingleVideoCubit>();
            _showVideoOptions(context, cubit);
          },
          child: const Icon(
            Icons.more_horiz,
            color: Colors.white,
            size: 30,
          ),
        ),
      );

  void _showVideoOptions(BuildContext context, SingleVideoCubit cubit) {
    final bool isVideoOwner = widget.video.ownerId == UserDataUtil.getUserId();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isVideoOwner) ...[
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text(
                    'Edit Video',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const Divider(color: Colors.white30),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: const Text(
                    'Delete Video',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () async {
                    bool? confirmed = await showConfirmDialog(
                      context,
                      title: "Confirm delete video",
                      body: 'Are you sure you want to delete this video?',
                    );
                    if (confirmed != true) {
                      return;
                    }
                    await cubit.deleteVideo(widget.video);
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                const Divider(color: Colors.white30),
              ],
              ListTile(
                leading: const Icon(Icons.download, color: Colors.white),
                title: const Text(
                  'Download',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  getIt<DownloadCubit>().downloadVideo(widget.video);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.white),
                title: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  bool get wantKeepAlive => true;
}
