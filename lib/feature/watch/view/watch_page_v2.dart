import 'dart:convert';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/home/view/content_cubit_v2.dart';
import 'package:visibility_detector/visibility_detector.dart';

class WatchPageV2 extends StatelessWidget {
  const WatchPageV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ContentCubitV2, ContentStateV2>(
        builder: (context, state) {
          if (state is ContentLoadingV2) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return PageView.builder(
            physics: const CustomPageViewScrollPhysics(),
            itemCount: state.videos.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              context.read<ContentCubitV2>().onPageChange(index);
            },
            itemBuilder: (context, index) {
              // Other videos
              if (index != state.currentReelIndex) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: 9 / 16,
                      child: Image.memory(
                        base64Decode(state.videos[index].thumbnail ?? ''),
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),
                  ],
                );
              }
              return state.reelsController?.videoPlayerController != null &&
                      state.reelsController!.isVideoInitialized()!
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
                                    context.read<ContentCubitV2>().playVideo();
                                  }
                                },
                                child: BetterPlayer(
                                  controller: state.reelsController!,
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
                            base64Decode(state.videos[index].thumbnail ?? ''),
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
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
