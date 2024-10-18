import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'camera_cubit.dart'; // Import the CameraCubit

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: BlocProvider(
        create: (context) => CameraCubit()..initializeCamera(),
        child: BlocConsumer<CameraCubit, CameraState>(
          listener: (context, state) {
            if (state is CameraError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is CameraReady) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  FutureBuilder<void>(
                    future: state.initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(state.controller);
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  _buildControlButtons(context),
                ],
              );
            } else if (state is CameraRecordingStopped) {
              return _buildVideoPlayer(state.videoController);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    final cubit = context.read<CameraCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.cloud_upload),
          onPressed: () {
            // Implement upload video functionality
          },
        ),
        BlocBuilder<CameraCubit, CameraState>(
          builder: (context, state) {
            final isRecording = cubit.isRecording;
            return IconButton(
              icon: Icon(
                isRecording ? Icons.stop : Icons.videocam,
                color: isRecording ? Colors.red : Colors.white,
              ),
              onPressed: () {
                if (isRecording) {
                  cubit.stopRecording();
                } else {
                  cubit.startRecording();
                }
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {
            // Dummy button action
          },
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(VideoPlayerController videoController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: videoController.value.aspectRatio,
          child: VideoPlayer(videoController),
        ),
        const Text('Video Recorded'),
      ],
    );
  }
}
