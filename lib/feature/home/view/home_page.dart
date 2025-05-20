import 'package:flutter/material.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/feature/watch/view/review_page.dart';
import 'package:taste_tube/feature/search/view/search_page.dart';
import 'package:taste_tube/feature/watch/view/content/content_page.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
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
                  Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                          builder: (context) => SearchPage.provider()));
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
          ContentPage(),
          ReviewPage(),
        ],
      ),
    );
  }
}
