import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/product/category/category_cubit.dart';
import 'package:taste_tube/feature/product/category/category_tab.dart';
import 'package:taste_tube/feature/product/product/product_cubit.dart';
import 'package:taste_tube/feature/product/product/product_tab.dart';
import 'package:taste_tube/utils/user_data.util.dart';

// TODO: Modify
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage>
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
            Tab(text: 'Shop'),
            Tab(text: 'Your Cart'),
          ],
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => CategoryCubit()..fetchCategory(),
            ),
            BlocProvider(
              create: (context) => ProductCubit()
                ..fetchProducts(UserDataUtil.getUserId(context)),
            ),
          ],
          child: TabBarView(
            controller: _tabController,
            children: const [
              ProductTab(),
              CategoryTab(),
            ],
          ),
        ),
      ),
    );
  }
}
