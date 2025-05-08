import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/feature/admin/user_management/user_management_cubit.dart';
import 'package:taste_tube/feature/admin/user_management/user_management_state.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _roleFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    context.read<UserManagementCubit>().fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<UserManagementCubit>().fetchUsers(
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
          roleFilter: _roleFilter,
          statusFilter: _statusFilter,
        );
  }

  void _onFilterChanged({String? role, String? status}) {
    setState(() {
      _roleFilter = role;
      _statusFilter = status;
    });
    context.read<UserManagementCubit>().fetchUsers(
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
          roleFilter: _roleFilter,
          statusFilter: _statusFilter,
        );
  }

  void _goToPage(int? page) {
    if (page == null) return;
    context.read<UserManagementCubit>().fetchUsers(
          searchQuery:
              _searchController.text.isEmpty ? null : _searchController.text,
          roleFilter: _roleFilter,
          statusFilter: _statusFilter,
          page: page,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _roleFilter = null;
                _statusFilter = null;
              });
              context.read<UserManagementCubit>().resetFilters();
              context.read<UserManagementCubit>().fetchUsers();
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
                      labelText: 'Search by username, email, or phone',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _onSearchChanged(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  hint: const Text('Role'),
                  value: _roleFilter,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Roles'),
                    ),
                    ...['CUSTOMER', 'RESTAURANT']
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            ))
                  ].toList(),
                  onChanged: (value) =>
                      _onFilterChanged(role: value, status: _statusFilter),
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
                    ...['ACTIVE', 'SUSPENDED', 'BANNED']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                  ].toList(),
                  onChanged: (value) =>
                      _onFilterChanged(role: _roleFilter, status: value),
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<UserManagementCubit, UserManagementState>(
                builder: (context, state) {
                  if (state is UserManagementLoading && state.isFirstFetch) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is UserManagementError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  if (state is UserManagementLoaded) {
                    final currentPage = state.page;
                    final totalPages = state.totalPages;
                    final pagesToShow = <int>[];
                    const maxPages = 4;

                    // Determine start and end page numbers
                    int startPage =
                        (currentPage - (maxPages ~/ 2)).clamp(1, totalPages);
                    int endPage =
                        (startPage + maxPages - 1).clamp(1, totalPages);

                    // Adjust startPage if endPage exceeds totalPages
                    if (endPage - startPage + 1 < maxPages) {
                      startPage = (endPage - maxPages + 1).clamp(1, totalPages);
                    }

                    // Add relevant pages
                    for (int i = startPage; i <= endPage; i++) {
                      pagesToShow.add(i);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Total Users: ${state.totalDocs}'),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('ID')),
                                  DataColumn(label: Text('Username')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Phone')),
                                  DataColumn(label: Text('Role')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows: state.users
                                    .map((user) => DataRow(cells: [
                                          DataCell(
                                            GestureDetector(
                                              onTap: () {
                                                context
                                                    .push('/user/${user.id}');
                                              },
                                              child: Text(
                                                user.id,
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationThickness: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(user.username)),
                                          DataCell(Text(user.email ?? '')),
                                          DataCell(Text(user.phone ?? '')),
                                          DataCell(Text(user.role ?? '')),
                                          DataCell(
                                            DropdownButton<String>(
                                              value: user.status,
                                              items: [
                                                'ACTIVE',
                                                'SUSPENDED',
                                                'BANNED'
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
                                                    .read<UserManagementCubit>()
                                                    .updateUserStatus(
                                                        user.id, newStatus);
                                              },
                                            ),
                                          ),
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
                  return const Center(child: Text('No users found'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'ACTIVE':
      return Colors.green;
    case 'SUSPENDED':
      return Colors.orange;
    case 'BANNED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String _getStatusDescription(String status) {
  switch (status) {
    case 'ACTIVE':
      return 'No user restrictions.';
    case 'SUSPENDED':
      return 'User cannot upload new content.';
    case 'BANNED':
      return 'User banned from TasteTube.';
    default:
      return 'Unknown status.';
  }
}
