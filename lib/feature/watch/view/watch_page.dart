import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/quantity_dialog.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/feature/profile/view/profile_page.dart';
import 'package:taste_tube/global_data/watch/comment.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/injection.dart';
import 'package:taste_tube/utils/user_data.util.dart';
import 'package:uuid/uuid.dart';
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
  bool _isDownloading = false; // Track if downloading
  double _downloadProgress = 0.0;

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

  Future<void> downloadVideo(String url) async {
    try {
      setState(() {
        _isDownloading = true;
      });

      Directory directory = await getTemporaryDirectory();
      String filePath = "${directory.path}/${getIt<Uuid>().v4()}.mp4";

      Dio dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          setState(() {
            _downloadProgress = received / total;
          });
        },
      );
      bool? savedToGallery = await GallerySaver.saveVideo(filePath);
      if (savedToGallery != true) throw Exception('Error saving to gallery');
      Fluttertoast.showToast(
          msg: 'Download complete',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP);
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Download failed: $e', gravity: ToastGravity.TOP);
    } finally {
      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });
    }
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
        // actions: [ // TODO: Reimplement this
        //   Padding(
        //     padding: const EdgeInsets.only(right: 20),
        //     child: IconButton(
        //       icon: const Icon(
        //         Icons.download,
        //         color: Colors.white,
        //       ),
        //       onPressed: () async {
        //         await _downloadVideo(widget.videos[currentIndex].url);
        //       },
        //     ),
        //   ),
        // ],
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
          return Stack(alignment: Alignment.center, children: [
            BlocProvider(
              create: (context) => SingleVideoCubit(video)..fetchDependency(),
              child: SingleVideo(video: video),
            ),
            if (_isDownloading) // Top download progress bar
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(10.0),
                  width: CommonSize.screenSize.width / 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromRGBO(0, 0, 0, 0.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: _downloadProgress,
                        backgroundColor: Colors.transparent,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ]);
        },
      ),
    );
  }
}
