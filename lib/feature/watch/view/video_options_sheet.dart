import 'package:flutter/material.dart';
import 'package:taste_tube/common/dialog.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/feature/watch/view/single_video_cubit.dart';
import 'package:taste_tube/global_bloc/download/download_cubit.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/utils/user_data.util.dart';

void showVideoOptionsSheet(
    BuildContext context, SingleVideoCubit cubit, Video video) {
  final bool isVideoOwner = video.ownerId == UserDataUtil.getUserId();
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: const Color.fromRGBO(31, 31, 31, 1),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isVideoOwner) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Edit Video',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(color: Colors.white30),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text(
                  'Delete Video',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () async {
                  bool? confirmed = await showConfirmDialog(
                    context,
                    title: "Confirm delete video",
                    body: 'Are you sure you want to delete this video?',
                  );
                  if (confirmed != true) {
                    return;
                  }
                  await cubit.deleteVideo(video);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const Divider(color: Colors.white30),
            ],
            ListTile(
              leading: const Icon(Icons.download, color: Colors.white),
              title: const Text(
                'Download',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                getIt<DownloadCubit>().downloadVideo(video);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.white),
              title: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
