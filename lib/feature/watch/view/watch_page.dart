
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/quantity_dialog.dart';
import 'package:taste_tube/global_bloc/download/download_cubit.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_data/watch/comment.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/utils/user_data.util.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'single_video_page.dart';

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
        },
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          return BlocProvider(
            create: (context) => SingleVideoCubit(video)..fetchDependency(),
            child: SingleVideo(video: video),
          );
        },
      ),
    );
  }
}
