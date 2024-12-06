import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/theme.dart';
import 'package:taste_tube/feature/profile/data/user.dart';
import 'package:taste_tube/feature/record/camera/camera_cubit.dart';
import 'package:taste_tube/injection.dart';

import '../replay/replay_page.dart';

class CameraPage extends StatelessWidget {
  final User? reviewTarget;
  const CameraPage({super.key, this.reviewTarget});

  static Widget provider({
    User? reviewTarget,
  }) =>
      BlocProvider(
        create: (_) => CameraCubit()..initCamera(),
        child: CameraPage(reviewTarget: reviewTarget),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CameraCubit>();

    return Scaffold(
      backgroundColor: Colors.black,
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
                  reviewTarget: reviewTarget,
                ),
              ),
            ).then((_) {
              context.read<CameraCubit>().initCamera();
            });
          }
        },
        builder: (context, state) {
          if (state is CameraLoading) {
            return const Center(child: CommonLoadingIndicator.regular);
          } else if (state is CameraInitialized) {
            return Stack(
              fit: StackFit.expand, // Non-positioned child takes fullsize
              alignment: Alignment.bottomCenter,
              children: [
                _cameraPreview(context),
                _recordButton(context),
                _uploadButton(context),
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
            heroTag: 'Record',
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
                    color: CommonColor.activeBgColor,
                  )
                : Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: CommonColor.activeBgColor,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _uploadButton(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 50,
      child: BlocBuilder<CameraCubit, CameraState>(
        builder: (context, state) {
          return FloatingActionButton(
            heroTag: 'Upload',
            onPressed: () async {
              try {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.video,
                );

                if (result != null && result.files.single.path != null) {
                  String filePath = result.files.single.path!;

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => ReplayPage(
                            filePath: filePath, recordedWithFrontCamera: false),
                      ),
                    );
                  }
                }
              } catch (e) {
                getIt<Logger>().e("Error picking file", error: e);
                return;
              }
            },
            child: const Icon(Icons.upload),
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
