import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/watch/view/watch_page.dart';
import 'package:taste_tube/global_data/watch/video.dart';

// TODO: Not working properly, accepted for now
class PublicVideosPage extends StatefulWidget {
  final List<Video> videos;
  final int initialIndex;

  const PublicVideosPage({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  State<PublicVideosPage> createState() => _PublicVideosPageState();
}

class _PublicVideosPageState extends State<PublicVideosPage> {
  late PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: GoRouterState.of(context).path != '/home'
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videos.length,
        onPageChanged: (int index) {
          setState(() {
            currentIndex = index;
          });
          currentPlayingVideoId = widget.videos[index].id;
        },
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return SingleVideo.provider(video);
        },
      ),
    );
  }
}
