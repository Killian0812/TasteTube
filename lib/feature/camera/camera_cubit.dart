import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class CameraCubit extends Cubit<CameraState> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late VideoPlayerController _videoController;
  bool isRecording = false;
  String? videoPath;

  CameraCubit() : super(CameraInitial());

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(cameras.first, ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize();
      emit(CameraReady(_controller, _initializeControllerFuture));
    } catch (e) {
      emit(CameraError('Error initializing camera: $e'));
    }
  }

  Future<void> startRecording() async {
    try {
      await _initializeControllerFuture;

      final Directory dir = await getApplicationDocumentsDirectory();
      videoPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';

      await _controller.startVideoRecording();
      isRecording = true;
      emit(CameraRecordingStarted());
    } catch (e) {
      emit(CameraError('Error starting video recording: $e'));
    }
  }

  Future<void> stopRecording() async {
    try {
      await _controller.stopVideoRecording();
      isRecording = false;

      _videoController = VideoPlayerController.file(File(videoPath!))
        ..initialize().then((_) {
          emit(CameraRecordingStopped(_videoController));
        });
    } catch (e) {
      emit(CameraError('Error stopping video recording: $e'));
    }
  }

  void disposeControllers() {
    _controller.dispose();
    _videoController.dispose();
  }
}

abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraReady extends CameraState {
  final CameraController controller;
  final Future<void> initializeControllerFuture;

  CameraReady(this.controller, this.initializeControllerFuture);
}

class CameraRecordingStarted extends CameraState {}

class CameraRecordingStopped extends CameraState {
  final VideoPlayerController videoController;

  CameraRecordingStopped(this.videoController);
}

class CameraError extends CameraState {
  final String message;

  CameraError(this.message);
}
