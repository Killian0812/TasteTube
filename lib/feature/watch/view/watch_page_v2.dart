import 'dart:convert';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taste_tube/feature/home/view/content_cubit_v2.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Support Mobile only
class WatchPageV2 extends StatelessWidget {
  const WatchPageV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<VideoPlayerProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return PageView.builder(
            physics: const CustomPageViewScrollPhysics(),
            itemCount: provider.videos.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              provider.onPageChange(index);
            },
            itemBuilder: (context, index) {
              return index != provider.currentReelIndex
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 9 / 16,
                          child: Image.memory(
                            base64Decode(
                                provider.videos[index].thumbnail ?? ''),
                            fit: BoxFit.cover,
                            height: 9 / 16,
                          ),
                        ),
                      ],
                    )
                  : provider.reelsController?.videoPlayerController != null &&
                          provider.reelsController!.isVideoInitialized()!
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 9 / 16,
                              child: Stack(
                                children: [
                                  VisibilityDetector(
                                    key: Key(index.toString()),
                                    onVisibilityChanged: (info) {
                                      if (info.visibleFraction == 1.0) {
                                        provider.playVideo();
                                      }
                                    },
                                    child: BetterPlayer(
                                      controller: provider.reelsController!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: 9 / 16,
                              child: Image.memory(
                                base64Decode(
                                    provider.videos[index].thumbnail ?? ''),
                                fit: BoxFit.cover,
                                height: 600,
                              ),
                            ),
                          ],
                        );
            },
          );
        },
      ),
    );
  }
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({super.parent});

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 120,
        stiffness: 120,
        damping: 1,
      );
}
