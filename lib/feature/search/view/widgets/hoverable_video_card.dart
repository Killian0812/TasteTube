import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/global_data/watch/video.dart';

class HoverableVideoCard extends StatefulWidget {
  final Video video;
  final List<Video> videos;

  const HoverableVideoCard({
    super.key,
    required this.video,
    required this.videos,
  });

  @override
  State<HoverableVideoCard> createState() => _HoverableVideoCardState();
}

class _HoverableVideoCardState extends State<HoverableVideoCard> {
  bool _hovering = false;
  Uint8List decodedThumbnail = Uint8List(0);

  @override
  void initState() {
    decodedThumbnail = base64Decode(widget.video.thumbnail ?? '');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _hovering ? 1.05 : 1.0,
        curve: Curves.easeInOut,
        child: GestureDetector(
          onTap: () => context.push(
            '/watch/${widget.video.id}',
            extra: widget.videos,
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
            ),
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.memory(
                            decodedThumbnail,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
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
                                widget.video.views.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(blurRadius: 2, color: Colors.black),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.title ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.video.description ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              foregroundImage:
                                  NetworkImage(widget.video.ownerImage),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.video.ownerUsername,
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
            ),
          ),
        ),
      ),
    );
  }
}
