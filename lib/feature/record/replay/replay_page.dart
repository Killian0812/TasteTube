import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taste_tube/common/theme.dart';
import 'package:video_player/video_player.dart';

class ReplayPage extends StatefulWidget {
  final String filePath;
  final bool recordedWithFrontCamera;

  const ReplayPage(
      {super.key,
      required this.filePath,
      required this.recordedWithFrontCamera});

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
                return const Center(child: CircularProgressIndicator());
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
              backgroundColor: Colors.red,
              onPressed: () {
                // To upload page
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
        ],
      ),
    );
  }
}
