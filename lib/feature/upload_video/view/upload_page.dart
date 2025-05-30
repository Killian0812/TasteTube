import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/global_data/user/user.dart';
import 'package:taste_tube/feature/upload_video/view/upload_cubit.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class UploadPage extends StatelessWidget {
  final User? reviewTarget;
  const UploadPage({super.key, this.reviewTarget});

  static Widget provider(
    Uint8List thumbnail,
    bool recordedWithFrontCamera,
    User? reviewTarget,
    XFile xfile,
  ) =>
      BlocProvider(
        create: (context) => UploadCubit(
          thumbnail: thumbnail,
          xfile: xfile,
          recordedWithFrontCamera: recordedWithFrontCamera,
          reviewTarget: reviewTarget,
        )..fetchProducts(reviewTarget?.id ?? UserDataUtil.getUserId()),
        child: UploadPage(reviewTarget: reviewTarget),
      );

  @override
  Widget build(BuildContext context) {
    final isReview = reviewTarget != null;
    final cubit = context.read<UploadCubit>();
    return BlocListener<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state is UploadSuccess) {
            ToastService.showToast(
                context, 'Upload successful', ToastType.success);
            if (context.mounted) {
              context.pop();
              context.pop();
            }
          } else if (state is UploadFailure) {
            ToastService.showToast(context, state.message, ToastType.error);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: !isReview
                ? null
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text(
                      "Reviewing:    ",
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 20,
                      foregroundImage: NetworkImage(reviewTarget!.image!),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      reviewTarget!.username,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ]),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) => cubit.setTitle(value),
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.memory(
                              cubit.thumbnail,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                onChanged: (value) =>
                                    cubit.setDescription(value),
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  labelText: 'Description',
                                  helperMaxLines: 3,
                                  helperText:
                                      "Describe your content. A well-crafted description can help attract larger audiences.",
                                  hintStyle: CommonTextStyle.italic
                                      .copyWith(color: Colors.grey),
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.multiline,
                                expands: true,
                                maxLines: null,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<UploadCubit, UploadState>(
                        builder: (context, state) {
                          return Wrap(
                            spacing: 8.0,
                            children: cubit.hashtags
                                .map((hashtag) => Chip(label: Text(hashtag)))
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showVisibilityOptions(context, cubit),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Visibility: '),
                              const Spacer(),
                              BlocBuilder<UploadCubit, UploadState>(
                                builder: (context, state) {
                                  return Text(cubit.selectedVisibility.name);
                                },
                              ),
                              const SizedBox(width: 20),
                              const Icon(Icons.keyboard_arrow_right),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<UploadCubit, UploadState>(
                        bloc: cubit,
                        builder: (context, state) {
                          if (cubit.availableProducts.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return GestureDetector(
                            onTap: () => _showProductSelection(context, cubit),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Attached products: '),
                                  const Spacer(),
                                  BlocBuilder<UploadCubit, UploadState>(
                                    builder: (context, state) {
                                      return Text(cubit
                                          .selectedProductIds.length
                                          .toString());
                                    },
                                  ),
                                  const SizedBox(width: 20),
                                  const Icon(Icons.keyboard_arrow_right),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                BlocBuilder<UploadCubit, UploadState>(
                  builder: (context, state) {
                    return CommonButton(
                      isLoading: (state is UploadLoading),
                      onPressed: () {
                        cubit.uploadVideo(reviewTarget: reviewTarget);
                      },
                      text: "Upload",
                    );
                  },
                )
              ],
            ),
          ),
        ));
  }

  void _showVisibilityOptions(BuildContext context, UploadCubit cubit) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return SizedBox(
          height: screenSize.height * 0.3,
          child: ListView(
            padding: const EdgeInsets.only(top: 30),
            children: VideoVisibility.values.map((visibility) {
              return CheckboxListTile(
                title: Text(visibility.name),
                subtitle: Text(visibility.description),
                value: cubit.selectedVisibility == visibility,
                onChanged: (value) {
                  if (value == true) {
                    cubit.setVisibility(visibility);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showProductSelection(BuildContext context, UploadCubit cubit) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: screenSize.height * 0.4,
          child: BlocProvider.value(
            value: cubit,
            child: ListView(
              padding: const EdgeInsets.only(top: 30),
              children: cubit.availableProducts.map((product) {
                return BlocBuilder<UploadCubit, UploadState>(
                  builder: (context, state) {
                    return CheckboxListTile(
                      title: Row(
                        children: [
                          Image.network(
                            product.images[0].url,
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 25),
                          Text(product.name),
                        ],
                      ),
                      value: cubit.selectedProductIds.contains(product.id),
                      onChanged: (bool? selected) {
                        cubit.toggleProductSelection(
                            product, selected ?? false);
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
