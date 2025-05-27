import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/button.dart';
import 'package:taste_tube/common/size.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/common/constant.dart';
import 'package:taste_tube/feature/update_video/view/update_video_cubit.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_data/watch/video.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class UpdateVideoPage extends StatefulWidget {
  final Video video;

  const UpdateVideoPage({super.key, required this.video});

  static Widget provider(Video video) => BlocProvider(
        create: (context) =>
            UpdateVideoCubit()..fetchProducts(UserDataUtil.getUserId()),
        child: UpdateVideoPage(video: video),
      );

  @override
  UpdateVideoPageState createState() => UpdateVideoPageState();
}

class UpdateVideoPageState extends State<UpdateVideoPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<String> _hashtags;
  late VideoVisibility _selectedVisibility;
  late Set<String> _selectedProductIds;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.video.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.video.description ?? '');
    _hashtags = widget.video.hashtags ?? [];
    _selectedVisibility = VideoVisibility.values.firstWhere(
      (v) => v.value == widget.video.visibility,
      orElse: () => VideoVisibility.public,
    );
    _selectedProductIds = widget.video.products.map((e) => e.id).toSet();

    // Update hashtags when description changes, without setState
    _descriptionController.addListener(() {
      final newHashtags = _descriptionController.text
          .split(RegExp(r'[\s\n]'))
          .where((word) => word.startsWith('#'))
          .map((word) => word.trim())
          .toList();
      if (!listEquals(newHashtags, _hashtags)) {
        setState(() {
          _hashtags = newHashtags;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UpdateVideoCubit>();
    return BlocListener<UpdateVideoCubit, UpdateVideoState>(
      listener: (context, state) {
        if (state is UpdateVideoSuccess) {
          ToastService.showToast(
              context, 'Update successful', ToastType.success);
          if (context.mounted) {
            context.pop();
          }
        } else if (state is UpdateVideoFailure) {
          ToastService.showToast(context, state.message, ToastType.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Update Video",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<UpdateVideoCubit, UpdateVideoState>(
            builder: (context, state) {
              if (state is UpdateVideoLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              final List<Product> availableProducts =
                  state is UpdateVideoLoaded ? state.availableProducts : [];
              return Column(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
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
                              widget.video.thumbnail != null
                                  ? Image.memory(
                                      base64Decode(widget.video.thumbnail!),
                                      height: 200,
                                      fit: BoxFit.contain,
                                    )
                                  : Container(
                                      height: 200,
                                      width: 150,
                                      color: Colors.grey[300],
                                      child:
                                          const Icon(Icons.videocam, size: 50),
                                    ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _descriptionController,
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
                        Wrap(
                          spacing: 8.0,
                          children: _hashtags
                              .map((hashtag) => Chip(label: Text(hashtag)))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _showVisibilityOptions(context),
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
                                Text(_selectedVisibility.name),
                                const SizedBox(width: 20),
                                const Icon(Icons.keyboard_arrow_right),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () =>
                              _showProductSelection(context, availableProducts),
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
                                Text(_selectedProductIds.length.toString()),
                                const SizedBox(width: 20),
                                const Icon(Icons.keyboard_arrow_right),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  CommonButton(
                    isLoading: state is UpdateVideoLoading,
                    onPressed: () {
                      cubit.updateVideo(
                        videoId: widget.video.id,
                        title: _titleController.text.isNotEmpty
                            ? _titleController.text
                            : null,
                        description: _descriptionController.text.isNotEmpty
                            ? _descriptionController.text
                            : null,
                        hashtags: _hashtags.isNotEmpty ? _hashtags : null,
                        productIds: _selectedProductIds.isNotEmpty
                            ? _selectedProductIds.toList()
                            : null,
                        visibility: _selectedVisibility.value,
                      );
                    },
                    text: "Update",
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showVisibilityOptions(BuildContext context) {
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
                value: _selectedVisibility == visibility,
                onChanged: (value) {
                  if (value == true) {
                    setState(() {
                      _selectedVisibility = visibility;
                    });
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

  void _showProductSelection(
      BuildContext context, List<Product> availableProducts) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: screenSize.height * 0.4,
              child: ListView(
                padding: const EdgeInsets.only(top: 30),
                children: availableProducts.map((product) {
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
                    value: _selectedProductIds.contains(product.id),
                    onChanged: (bool? selected) {
                      setModalState(() {
                        setState(() {
                          if (selected == true) {
                            _selectedProductIds.add(product.id);
                          } else {
                            _selectedProductIds.remove(product.id);
                          }
                        });
                      });
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}
