import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/camera/camera_cubit.alt.dart';
import 'package:video_player/video_player.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraCubit()..initCamera(),
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: BlocConsumer<CameraCubit, CameraState>(
          listener: (context, state) {
            if (state is CameraStopped) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => VideoPage(filePath: state.filePath),
                ),
              ).then((_) {
                context.read<CameraCubit>().initCamera();
              });
            }
          },
          builder: (context, state) {
            final cubit = context.read<CameraCubit>();
            if (state is CameraLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CameraInitialized) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CameraPreview(cubit.cameraController),
                  _buildRecordButton(context),
                ],
              );
            } else if (state is CameraRecording) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CameraPreview(cubit.cameraController),
                  _buildRecordingIndicator(state.recordingDuration),
                  _buildRecordButton(context),
                ],
              );
            } else if (state is CameraError) {
              return Center(child: Text(state.errorMessage));
            }
            return Container();
          },
        ),
      ),
    );
  }

  // Record button logic
  Widget _buildRecordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: FloatingActionButton(
        backgroundColor: Colors.red,
        child: BlocBuilder<CameraCubit, CameraState>(
          builder: (context, state) {
            if (state is CameraRecording) {
              return const Icon(Icons.stop);
            } else {
              return const Icon(Icons.circle);
            }
          },
        ),
        onPressed: () => context.read<CameraCubit>().recordVideo(),
      ),
    );
  }

  // Recording indicator with timer
  Widget _buildRecordingIndicator(int recordingDuration) {
    final minutes = (recordingDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (recordingDuration % 60).toString().padLeft(2, '0');
    return Positioned(
      top: 50,
      left: 20,
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.red),
          const SizedBox(width: 5),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(color: Colors.red, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class VideoPage extends StatefulWidget {
  final String filePath;

  const VideoPage({super.key, required this.filePath});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              print('do something with the file');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return VideoPlayer(_videoPlayerController);
          }
        },
      ),
    );
  }
}
