import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/feature/home/explore/explore_page.dart';
import 'package:taste_tube/feature/home/reviews/reviews_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Explore'),
            Tab(text: 'Reviews'),
          ],
        ),
        body: Stack(alignment: Alignment.topRight, children: [
          TabBarView(
            controller: _tabController,
            children: const [
              ExplorePage(),
              ReviewsPage(),
            ],
          ),
          IconButton(
            onPressed: () {
              context.push('/search');
            },
            icon: const Icon(Icons.search),
          )
        ]),
      ),
    );
  }
}
