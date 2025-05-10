import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/feature/admin/video_management/video_management_cubit.dart';
import 'package:taste_tube/feature/admin/video_management/video_management_state.dart';

class VideoManagementPage extends StatefulWidget {
  const VideoManagementPage({super.key});

  @override
  State<VideoManagementPage> createState() => _VideoManagementPageState();
}

class _VideoManagementPageState extends State<VideoManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _visibilityFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    context.read<VideoManagementCubit>().fetchVideos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<VideoManagementCubit>().fetchVideos(
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
          visibilityFilter: _visibilityFilter,
          statusFilter: _statusFilter,
        );
  }

  void _onFilterChanged({String? visibility, String? status}) {
    setState(() {
      _visibilityFilter = visibility;
      _statusFilter = status;
    });
    context.read<VideoManagementCubit>().fetchVideos(
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
          visibilityFilter: _visibilityFilter,
          statusFilter: _statusFilter,
        );
  }

  void _goToPage(int? page) {
    if (page == null) return;
    context.read<VideoManagementCubit>().fetchVideos(
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
          visibilityFilter: _visibilityFilter,
          statusFilter: _statusFilter,
          page: page,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _visibilityFilter = null;
                _statusFilter = null;
              });
              context.read<VideoManagementCubit>().resetFilters();
              context.read<VideoManagementCubit>().fetchVideos();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by title or description',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _onSearchChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  hint: const Text('Visibility'),
                  value: _visibilityFilter,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Visibilities'),
                    ),
                    ...['PUBLIC', 'PRIVATE', 'FOLLOWERS_ONLY']
                        .map((visibility) => DropdownMenuItem(
                              value: visibility,
                              child: Text(visibility),
                            ))
                  ].toList(),
                  onChanged: (value) => _onFilterChanged(
                      visibility: value, status: _statusFilter),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  hint: const Text('Status'),
                  value: _statusFilter,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...['PENDING', 'ACTIVE', 'REMOVED']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                  ].toList(),
                  onChanged: (value) => _onFilterChanged(
                      visibility: _visibilityFilter, status: value),
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<VideoManagementCubit, VideoManagementState>(
                builder: (context, state) {
                  if (state is VideoManagementLoading && state.isFirstFetch) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is VideoManagementError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  if (state is VideoManagementLoaded) {
                    final currentPage = state.page;
                    final totalPages = state.totalPages;
                    final pagesToShow = <int>[];
                    const maxPages = 4;

                    int startPage =
                        (currentPage - (maxPages ~/ 2)).clamp(1, totalPages);
                    int endPage =
                        (startPage + maxPages - 1).clamp(1, totalPages);

                    if (endPage - startPage + 1 < maxPages) {
                      startPage = (endPage - maxPages + 1).clamp(1, totalPages);
                    }

                    for (int i = startPage; i <= endPage; i++) {
                      pagesToShow.add(i);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Total Videos: ${state.totalDocs}'),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Title')),
                                  DataColumn(label: Text('Owner')),
                                  DataColumn(label: Text('Views')),
                                  DataColumn(label: Text('Visibility')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Created At')),
                                ],
                                rows: state.videos
                                    .map((video) => DataRow(cells: [
                                          DataCell(
                                            GestureDetector(
                                              onTap: () {
                                                context
                                                    .push('/watch/${video.id}');
                                              },
                                              child: Text(
                                                video.id,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationThickness: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(video.title ?? '')),
                                          DataCell(
                                            GestureDetector(
                                              onTap: () {
                                                context.push(
                                                    '/user/${video.ownerId}');
                                              },
                                              child: Text(
                                                video.ownerUsername,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationThickness: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                              Text(video.views.toString())),
                                          DataCell(Tooltip(
                                            message: _getVisibilityDescription(
                                                video.visibility),
                                            child: Text(video.visibility),
                                          )),
                                          DataCell(
                                            DropdownButton<String>(
                                              value: video.status,
                                              items: [
                                                'PENDING',
                                                'ACTIVE',
                                                'REMOVED'
                                              ]
                                                  .map((status) =>
                                                      DropdownMenuItem(
                                                        value: status,
                                                        child: Tooltip(
                                                          message:
                                                              _getStatusDescription(
                                                                  status),
                                                          child: Text(
                                                            status,
                                                            style: TextStyle(
                                                              color:
                                                                  _getStatusColor(
                                                                      status),
                                                            ),
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                              onChanged: (newStatus) {
                                                if (newStatus == null) return;
                                                context
                                                    .read<
                                                        VideoManagementCubit>()
                                                    .updateVideoStatus(
                                                        video.id, newStatus);
                                              },
                                            ),
                                          ),
                                          DataCell(
                                              Text(video.createdAt.toString())),
                                        ]))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => _goToPage(state.prevPage),
                                child: const Text('Previous'),
                              ),
                              const SizedBox(width: 8),
                              for (int i in pagesToShow)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: TextButton(
                                    onPressed: () => _goToPage(i),
                                    style: TextButton.styleFrom(
                                      backgroundColor: state.page == i
                                          ? CommonColor.activeBgColor
                                          : null,
                                      foregroundColor:
                                          state.page == i ? Colors.white : null,
                                    ),
                                    child: Text('$i'),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => _goToPage(state.nextPage),
                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: Text('No videos found'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _getVisibilityDescription(String visibility) {
  switch (visibility) {
    case 'PUBLIC':
      return 'Visible to everyone.';
    case 'PRIVATE':
      return 'Visible only to the owner.';
    case 'FOLLOWERS_ONLY':
      return 'Visible to specific users.';
    default:
      return 'Unknown visibility.';
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'PENDING':
      return Colors.blueGrey;
    case 'ACTIVE':
      return Colors.green;
    case 'REMOVED':
      return Colors.red;
    default:
      return Colors.blue;
  }
}

String _getStatusDescription(String status) {
  switch (status) {
    case 'PENDING':
      return 'Video is in temporary pending status.';
    case 'ACTIVE':
      return 'Video is active and accessible.';
    case 'REMOVED':
      return 'Video is removed from TasteTube.';
    default:
      return 'Unknown status.';
  }
}
