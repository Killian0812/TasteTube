import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/injection.dart';
import 'package:uuid/uuid.dart';

class DownloadState {
  final String id;
  final String url;
  final String title;
  final double progress;

  DownloadState({
    required this.id,
    required this.url,
    required this.title,
    this.progress = 0.0,
  });

  DownloadState copyWith({
    double? progress,
  }) {
    return DownloadState(
      id: id,
      url: url,
      title: title,
      progress: progress ?? this.progress,
    );
  }
}

class DownloadCubit extends Cubit<List<DownloadState>> {
  DownloadCubit() : super([]);

  String _getVideoFilename(Video video) {
    try {
      return "${video.title!.replaceAll(' ', '_')}_${video.ownerUsername.replaceAll(' ', '_')}";
    } catch (e) {
      return getIt<Uuid>().v4();
    }
  }

  Future<void> downloadVideo(Video video) async {
    final url = video.url;
    final id = getIt<Uuid>().v4();
    final title = _getVideoFilename(video);

    try {
      emit([...state, DownloadState(id: id, url: url, title: title)]);
      Directory directory = await getTemporaryDirectory();
      String filePath = "${directory.path}/$title.mp4";

      Dio dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          final progress = received / total;
          final updatedState = state.map((downloadState) {
            if (downloadState.id == id) {
              return downloadState.copyWith(progress: progress);
            }
            return downloadState;
          }).toList();
          emit(updatedState);
        },
      );

      bool? savedToGallery = await GallerySaver.saveVideo(filePath);
      if (savedToGallery != true) throw Exception('Error saving to gallery');

      final updatedState = [...state];
      updatedState.removeWhere((downloadState) => downloadState.id == id);
      emit(updatedState);

      Fluttertoast.showToast(
          msg: 'Video saved to gallery', toastLength: Toast.LENGTH_LONG);
    } catch (e) {
      final updatedState = [...state];
      updatedState.removeWhere((downloadState) => downloadState.id == id);
      emit(updatedState);

      Fluttertoast.showToast(msg: 'Download failed: $e');
    }
  }
}
