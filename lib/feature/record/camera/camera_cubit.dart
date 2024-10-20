import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraCubit extends Cubit<CameraState> {
  late CameraController cameraController;
  Timer? _timer;
  int _recordingDuration = 0; // Track recording duration in seconds
  List<CameraDescription> _cameras = []; // Available cameras
  int _currentCameraIndex = 0;
  bool onFrontCam = false;

  CameraCubit() : super(CameraLoading());

  Future<void> initCamera() async {
    try {
      _cameras = await availableCameras();
      final frontCameraIndex = _cameras
          .indexWhere((cam) => cam.lensDirection == CameraLensDirection.front);
      // Default front cam if available
      _currentCameraIndex = frontCameraIndex != -1 ? frontCameraIndex : 0;
      final camera = _cameras[_currentCameraIndex];
      onFrontCam = camera.lensDirection == CameraLensDirection.front;
      cameraController = CameraController(camera, ResolutionPreset.max);
      await cameraController.initialize();
      emit(CameraInitialized(cameraController));
    } catch (e) {
      emit(CameraError('Failed to initialize camera'));
    }
  }

  Future<void> flipCamera() async {
    try {
      if (_cameras.length < 2) return;
      await cameraController.dispose(); // Dispose old camera controller
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      final camera = _cameras.elementAt(_currentCameraIndex);
      onFrontCam = camera.lensDirection == CameraLensDirection.front;
      cameraController = CameraController(camera, ResolutionPreset.max);
      await cameraController.initialize();
      emit(CameraInitialized(cameraController));
    } catch (e) {
      emit(CameraError('Failed to initialize camera'));
    }
  }

  Future<void> recordVideo() async {
    if (state is CameraRecording) {
      final file = await cameraController.stopVideoRecording();
      _stopTimer();
      emit(CameraStopped(file.path));
    } else {
      await cameraController.prepareForVideoRecording();
      await cameraController.startVideoRecording();
      _startTimer();
      emit(CameraRecording(_recordingDuration));
    }
  }

  void _startTimer() {
    _recordingDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration++;
      emit(CameraRecording(_recordingDuration));
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    cameraController.dispose();
    _timer?.cancel();
    return super.close();
  }
}

abstract class CameraState {}

class CameraLoading extends CameraState {}

class CameraInitialized extends CameraState {
  final CameraController cameraController;
  CameraInitialized(this.cameraController);
}

class CameraRecording extends CameraState {
  final int recordingDuration;
  CameraRecording(this.recordingDuration);
}

class CameraStopped extends CameraState {
  final String filePath;
  CameraStopped(this.filePath);
}

class CameraError extends CameraState {
  final String errorMessage;
  CameraError(this.errorMessage);
}
