import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/search/view/search_cubit.dart';

class SearchVideoTab extends StatelessWidget {
  const SearchVideoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchCubit, SearchState>(
      listener: (context, state) {
        if (state is SearchError) {
          ToastService.showToast(context, state.message, ToastType.warning);
        }
      },
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SearchInitial) {
          return const Center(child: Text('Type to search for videos'));
        }
        final videos = state.videos;

        if (videos.isEmpty) {
          return const Center(child: Text('No videos found'));
        }

        return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 1 / 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];

              return GestureDetector(
                onTap: () {
                  context.push(
                    '/watch/${video.id}',
                    extra: videos,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Stack(
                        children: [
                          Image.memory(
                            base64Decode(video.thumbnail ?? ''),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            bottom: 5,
                            left: 5,
                            child: Row(
                              children: [
                                const Icon(Icons.visibility,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 5),
                                Text(
                                  video.views.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(blurRadius: 2, color: Colors.black)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Video title
                          Text(
                            video.title ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          // Video description
                          Text(
                            video.description ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          // Owner
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 10,
                                foregroundImage: NetworkImage(video.ownerImage),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                video.ownerUsername,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            });
      },
    );
  }
}
