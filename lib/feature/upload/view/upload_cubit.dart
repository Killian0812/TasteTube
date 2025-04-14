import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/feature/store/domain/product_repo.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/feature/upload/domain/upload_repo.dart';
import 'package:taste_tube/core/injection.dart';

import '../data/upload_video_request.dart';

class UploadCubit extends Cubit<UploadState> {
  final UploadRepository uploadRepository;
  final ProductRepository productRepository;
  final Uint8List thumbnail;
  final String filePath;
  final XFile? xfile;
  final bool recordedWithFrontCamera;
  final User? reviewTarget;
  String title = '';
  String description = '';
  String selectedVisibility = 'PUBLIC';
  List<String> hashtags = [];
  Set<String> selectedProductIds = {};
  List<Product> availableProducts = [];

  UploadCubit({
    required this.thumbnail,
    required this.filePath,
    required this.recordedWithFrontCamera,
    this.xfile,
    this.reviewTarget,
  })  : uploadRepository = getIt(),
        productRepository = getIt(),
        super(UploadInitialized());

  void setTitle(String value) {
    title = value;
  }

  void setDescription(String value) {
    description = value;
    hashtags = description
        .split(RegExp(r'[\s\n]'))
        .where((word) => word.startsWith('#'))
        .map((word) => word.trim())
        .toList();
    emit(UploadInitialized());
  }

  void setVisibility(String visibility) {
    selectedVisibility = visibility;
    emit(UploadInitialized());
  }

  Future<void> fetchProducts(String userId) async {
    try {
      final result = await productRepository.fetchProducts(userId);
      result.fold(
        (error) =>
            emit(UploadFailure(error.message ?? 'Error fetching products')),
        (products) {
          availableProducts = products;
          emit(UploadInitialized());
        },
      );
    } catch (e) {
      emit(UploadFailure(e.toString()));
    }
  }

  void toggleProductSelection(Product product, bool selected) {
    if (selected) {
      selectedProductIds.add(product.id);
    } else {
      selectedProductIds.remove(product.id);
    }
    emit(UploadInitialized());
  }

  Future<void> uploadVideo({User? reviewTarget}) async {
    try {
      emit(UploadLoading());
      final result = await uploadRepository.upload(
          filePath,
          xfile,
          UploadVideoRequest(
              title,
              description,
              hashtags,
              recordedWithFrontCamera ? 'FRONT' : 'BACK',
              base64Encode(thumbnail),
              selectedProductIds.toList(),
              selectedVisibility,
              reviewTarget?.id));
      result.fold(
        (error) =>
            emit(UploadFailure(error.message ?? 'Error uploading video')),
        (products) {
          emit(UploadSuccess());
        },
      );
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
