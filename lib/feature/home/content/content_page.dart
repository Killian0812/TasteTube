import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/loading.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/home/view/content_cubit.dart';
import 'package:taste_tube/feature/watch/view/watch_page.dart';

class ContentTab extends StatelessWidget {
  const ContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    // if (!kIsWeb) {
    //   return BlocListener<ContentCubitV2, ContentStateV2>(
    //     listener: (context, state) {
    //       if (state is ContentErrorV2) {
    //         ToastService.showToast(context, state.message, ToastType.warning);
    //       }
    //     },
    //     child: WatchPageV2(),
    //   );
    // }
    return BlocConsumer<ContentCubit, ContentState>(
      listener: (context, state) {
        if (state is ContentError) {
          ToastService.showToast(context, state.error, ToastType.warning);
        }
      },
      builder: (context, state) {
        if (state is ContentLoading) {
          return const Center(child: CommonLoadingIndicator.regular);
        }
        return WatchPage(videos: state.videos, initialIndex: 0);
      },
    );
  }
}
