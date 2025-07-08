import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/search/view/search_cubit.dart';
import 'package:taste_tube/feature/search/view/widgets/hoverable_video_card.dart';

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
            childAspectRatio: 1 / 1.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return HoverableVideoCard(video: video, videos: videos);
          },
        );
      },
    );
  }
}
