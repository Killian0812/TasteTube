import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/feature/home/content/content_page.dart';
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
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Material(
            color: Colors.transparent,
            type: MaterialType.transparency,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: CommonColor.greyOutTextColor,
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Explore'),
                    Tab(text: 'Reviews'),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    context.push('/search');
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ContentTab(),
            ReviewsPage(),
          ],
        ),
      ),
    );
  }
}
