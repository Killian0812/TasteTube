import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/upload/domain/upload_repo.dart';
import 'package:taste_tube/injection.dart';

import 'data/upload_video_request.dart';

class UploadCubit extends Cubit<UploadState> {
  final UploadRepository uploadRepository;
  final Uint8List thumbnail;
  final String filePath;
  final bool recordedWithFrontCamera;
  String title = '';
  String description = '';
  String selectedVisibility = 'PUBLIC';
  List<String> hashtags = [];
  Set<String> selectedProducts = {};
  List<String> availableProducts = [
    // TODO: change to Product model
    'Product1',
    'Product2',
    'Product3',
    'Product4',
    'Product5',
    'Product6',
    'Product7',
    'Product8',
    'Product9',
    'Product10',
  ];
  UploadCubit({
    required this.thumbnail,
    required this.filePath,
    required this.recordedWithFrontCamera,
  })  : uploadRepository = getIt(),
        super(UploadInitialized());

  void setTitle(String value) {
    title = value;
  }

  void setDescription(String value) {
    description = value;
    hashtags = description
        .split(' ')
        .where((word) => word.startsWith('#'))
        .map((word) => word.trim())
        .toList();
    emit(UploadInitialized());
  }

  void setVisibility(String visibility) {
    selectedVisibility = visibility;
    emit(UploadInitialized());
  }

  void toggleProductSelection(String product, bool selected) {
    if (selected) {
      selectedProducts.add(product);
    } else {
      selectedProducts.remove(product);
    }
    emit(UploadInitialized());
  }

  Future<void> uploadVideo() async {
    try {
      emit(UploadLoading());
      await uploadRepository.upload(
          filePath,
          UploadVideoRequest(
            title,
            description,
            hashtags,
            recordedWithFrontCamera ? 'FRONT' : 'BACK',
            base64Encode(thumbnail),
            [],
            selectedVisibility,
          ));
      emit(UploadSuccess());
    } catch (e) {
      emit(UploadFailure(e.toString()));
    }
  }
}

abstract class UploadState {}

class UploadInitialized extends UploadState {}

class UploadLoading extends UploadState {}

class UploadSuccess extends UploadState {}

class UploadFailure extends UploadState {
  final String message;
  UploadFailure(this.message);
}
