import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
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
  final bool recordedWithFrontCamera;
  final User? reviewTarget;
  final XFile xfile;
  final Uint8List? bytes;

  const ReplayPage({
    super.key,
    required this.recordedWithFrontCamera,
    this.reviewTarget,
    required this.xfile,
    this.bytes,
  });

  @override
  State<ReplayPage> createState() => _ReplayPageState();
}

class _ReplayPageState extends State<ReplayPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = kIsWeb
        ? VideoPlayerController.networkUrl(Uri.parse(widget.xfile.path))
        : VideoPlayerController.file(File(widget.xfile.path));
    _videoPlayerController.initialize().then((_) {
      setState(() {});
      _videoPlayerController.setLooping(true);
      _videoPlayerController.play();
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
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
          _videoPlayerController.value.isInitialized
              ? Transform.flip(
                  flipX: widget.recordedWithFrontCamera,
                  child: VideoPlayer(_videoPlayerController),
                )
              : const Center(child: CommonLoadingIndicator.regular),
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
                        widget.recordedWithFrontCamera,
                        widget.reviewTarget,
                        widget.xfile,
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
                      foregroundImage:
                          NetworkImage(widget.reviewTarget!.image!),
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
      if (kIsWeb) {
        final xfile = await VideoThumbnail.thumbnailFile(
          video: (widget.bytes == null
                  ? Uri.parse(widget.xfile.path)
                  : Uri.dataFromBytes(widget.bytes!, mimeType: 'video/mp4'))
              .toString(),
          imageFormat: ImageFormat.JPEG,
          maxWidth: 100,
          maxHeight: 200,
          quality: 80,
        );
        return xfile.readAsBytes();
      }
      return await VideoThumbnail.thumbnailData(
          video: widget.xfile.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 100,
          maxHeight: 200,
          quality: 80);
    } catch (e) {
      return Fallback.fallbackImageBytes;
    }
  }
}
