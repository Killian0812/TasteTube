import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/search/view/search_cubit.dart';
import 'package:taste_tube/feature/search/view/search_user_tab.dart';
import 'package:taste_tube/feature/search/view/search_video_tab.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static Widget provider() => BlocProvider(
        create: (context) => SearchCubit(),
        child: const SearchPage(),
      );

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  int currentTab = 0;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onSubmitted: (value) {
            if (currentTab == 0) {
              context.read<SearchCubit>().searchForUser(value);
            } else {
              context.read<SearchCubit>().searchForVideo(value);
            }
          },
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: "User"),
                Tab(text: "Video"),
              ],
              onTap: (value) {
                currentTab = value;
              },
            ),
            Expanded(
              child: TabBarView(children: [
                SearchUserTab(),
                SearchVideoTab(),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
