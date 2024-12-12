import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/fallback.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/theme.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/feature/upload/view/upload_page.dart';
import 'package:video_player/video_player.dart';

class ReplayPage extends StatefulWidget {
  final String filePath;
  final bool recordedWithFrontCamera;
  final User? reviewTarget;

  const ReplayPage({
    super.key,
    required this.filePath,
    required this.recordedWithFrontCamera,
    this.reviewTarget,
  });

  @override
  State<ReplayPage> createState() => _ReplayPageState();
}

class _ReplayPageState extends State<ReplayPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: CommonThemeData.contrastIconThemeData,
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          FutureBuilder(
            future: _initVideoPlayer(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CommonLoadingIndicator.regular);
              } else {
                return Transform.flip(
                    flipX: widget.recordedWithFrontCamera,
                    child: VideoPlayer(_videoPlayerController));
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: FloatingActionButton(
              heroTag: 'Proceed video',
              backgroundColor: CommonColor.activeBgColor,
              onPressed: () async {
                final thumbnail = await _createThumbnail();
                await _videoPlayerController.pause();
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadPage.provider(
                        thumbnail,
                        widget.filePath,
                        widget.recordedWithFrontCamera,
                        widget.reviewTarget,
                      ),
                    ),
                  ).then((_) async => await _videoPlayerController.play());
                }
              },
              shape: const CircleBorder(
                side: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                size: 35,
                Icons.check,
                color: Colors.white,
              ),
            ),
          ),
          if (widget.reviewTarget != null)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Reviewing:    ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 20,
                      foregroundImage: NetworkImage(widget.reviewTarget!.image!),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.reviewTarget!.username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Future<Uint8List> _createThumbnail() async {
    try {
      return await VideoThumbnail.thumbnailData(
          video: widget.filePath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 100,
          maxHeight: 200,
          quality: 50);
    } catch (e) {
      return Fallback.fallbackImageBytes;
    }
  }
}
