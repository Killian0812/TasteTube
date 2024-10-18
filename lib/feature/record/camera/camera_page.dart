import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/theme.dart';
import 'package:taste_tube/feature/record/camera/camera_cubit.dart';

import '../replay/replay_page.dart';

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  static Widget provider() => BlocProvider(
        create: (_) => CameraCubit()..initCamera(),
        child: const CameraPage(),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CameraCubit>();

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: CommonThemeData.contrastIconThemeData,
        actionsIconTheme: CommonThemeData.contrastIconThemeData,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 15),
            icon: const Icon(Icons.flip_camera_android_outlined),
            onPressed: () {
              cubit.flipCamera();
            },
          ),
        ],
      ),
      body: BlocConsumer<CameraCubit, CameraState>(
        listener: (context, state) {
          if (state is CameraStopped) {
            Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => ReplayPage(
                  filePath: state.filePath,
                  recordedWithFrontCamera: cubit.onFrontCam,
                ),
              ),
            ).then((_) {
              context.read<CameraCubit>().initCamera();
            });
          }
        },
        builder: (context, state) {
          if (state is CameraLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CameraInitialized) {
            return Stack(
              fit: StackFit.expand, // Non-positioned child takes fullsize
              alignment: Alignment.bottomCenter,
              children: [
                _cameraPreview(context),
                _recordButton(context),
              ],
            );
          } else if (state is CameraRecording) {
            return Stack(
              fit: StackFit.expand,
              alignment: Alignment.bottomCenter,
              children: [
                _cameraPreview(context),
                _recordingIndicator(state.recordingDuration),
                _recordButton(context),
              ],
            );
          } else if (state is CameraError) {
            return Center(child: Text(state.errorMessage));
          }
          return Container();
        },
      ),
    );
  }

  Widget _cameraPreview(BuildContext context) {
    final cameraController = context.read<CameraCubit>().cameraController;
    return CameraPreview(cameraController);
  }

  Widget _recordButton(BuildContext context) {
    return Positioned(
      bottom: 50,
      child: BlocBuilder<CameraCubit, CameraState>(
        builder: (context, state) {
          bool isRecording = state is CameraRecording;

          return FloatingActionButton(
            backgroundColor: Colors.transparent,
            onPressed: () {
              context.read<CameraCubit>().recordVideo();
            },
            shape: const CircleBorder(
              side: BorderSide(
                color: Colors.white,
                width: 5,
              ),
            ),
            child: isRecording
                ? const Icon(
                    size: 35,
                    Icons.stop_rounded,
                    color: Colors.red,
                  )
                : Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _recordingIndicator(int recordingDuration) {
    final minutes = (recordingDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (recordingDuration % 60).toString().padLeft(2, '0');
    return Positioned(
      bottom: 120,
      child: Row(
        children: [
          Text(
            '$minutes:$seconds',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
