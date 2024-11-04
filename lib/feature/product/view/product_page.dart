import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/product/category/category_cubit.dart';
import 'package:taste_tube/feature/product/category/category_tab.dart';
import 'package:taste_tube/feature/product/product/product_cubit.dart';
import 'package:taste_tube/feature/product/product/product_tab.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
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
            Tab(text: 'Products'),
            Tab(text: 'Categories'),
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
