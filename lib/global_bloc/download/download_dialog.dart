import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/global_bloc/download/download_cubit.dart';

class DownloadDialog extends StatelessWidget {
  const DownloadDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadCubit, List<DownloadState>>(
      builder: (context, state) {
        if (state.isEmpty) return const SizedBox.shrink();
        return DefaultTextStyle(
          style: CommonTextStyle.regular,
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(10.0),
              width: screenSize.width / 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromRGBO(0, 0, 0, 0.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Downloading ${state.first.title} ...'),
                  const SizedBox(height: 10),
                  CircularProgressIndicator(
                    value: state.first.progress,
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Text('${(state.first.progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
