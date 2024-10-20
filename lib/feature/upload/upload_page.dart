import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/upload/upload_cubit.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  static Widget provider(
    Uint8List thumbnail,
    String filePath,
    bool recordedWithFrontCamera,
  ) =>
      BlocProvider(
        create: (context) => UploadCubit(
          thumbnail: thumbnail,
          filePath: filePath,
          recordedWithFrontCamera: recordedWithFrontCamera,
        ),
        child: const UploadPage(),
      );

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UploadCubit>();
    return BlocListener<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state is UploadSuccess) {
            ToastService.showToast(
                context, 'Upload successful', ToastType.success);
          } else if (state is UploadFailure) {
            ToastService.showToast(context, state.message, ToastType.error);
          }
        },
        child: Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Title Input
                  TextField(
                    onChanged: (value) => cubit.setTitle(value),
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      // border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Thumbnail and Description
                  SizedBox(
                    height: 200,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail Image
                        Image.memory(
                          cubit.thumbnail,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 16),

                        Expanded(
                          child: TextField(
                            onChanged: (value) => cubit.setDescription(value),
                            decoration: InputDecoration(
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

                  // Display Hashtags
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
                              return Text(cubit.selectedVisibility);
                            },
                          ),
                          const SizedBox(width: 20),
                          const Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Button to open Product Selection bottom sheet
                  GestureDetector(
                    onTap: () => _showProductSelection(context, cubit),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Attached products: '),
                          const Spacer(),
                          BlocBuilder<UploadCubit, UploadState>(
                            builder: (context, state) {
                              return Text(
                                  cubit.selectedProducts.length.toString());
                            },
                          ),
                          const SizedBox(width: 20),
                          const Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Upload Button
                  CommonButton(
                    onPressed: () {
                      cubit.uploadVideo();
                    },
                    text: "Upload",
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void _showVisibilityOptions(BuildContext context, UploadCubit cubit) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: CommonSize.screenSize.height * 0.3,
          child: ListView(
            padding: const EdgeInsets.only(top: 30),
            children: ['PRIVATE', 'FOLLOWERS_ONLY', 'PUBLIC'].map((visibility) {
              return ListTile(
                title: Text(visibility),
                onTap: () {
                  cubit.setVisibility(visibility);
                  Navigator.pop(context);
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
          height: CommonSize.screenSize.height * 0.4,
          child: BlocProvider.value(
            value: cubit,
            child: ListView(
              padding: const EdgeInsets.only(top: 30),
              children: cubit.availableProducts.map((product) {
                return BlocBuilder<UploadCubit, UploadState>(
                  builder: (context, state) {
                    return CheckboxListTile(
                      title: Text(product),
                      value: cubit.selectedProducts.contains(product),
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
