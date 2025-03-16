import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/store/view/tabs/delivery/delivery_tab.dart';
import 'package:taste_tube/feature/store/view/tabs/payment/payment_setting_cubit.dart';
import 'package:taste_tube/feature/store/view/tabs/payment/payment_setting_tab.dart';
import 'package:taste_tube/feature/store/view/tabs/product/category_cubit.dart';
import 'package:taste_tube/feature/store/view/tabs/order/shop_order_tab.dart';
import 'package:taste_tube/feature/store/view/tabs/product/product_cubit.dart';
import 'package:taste_tube/feature/store/view/tabs/product/product_tab.dart';
import 'package:taste_tube/utils/user_data.util.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            Tab(icon: Icon(Icons.receipt_long), text: 'Orders'),
            Tab(icon: Icon(Icons.inventory), text: 'Products'),
            Tab(icon: Icon(Icons.local_shipping), text: 'Delivery'),
            Tab(icon: Icon(Icons.payment), text: 'Payment'),
          ],
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => CategoryCubit()..fetchCategory(),
            ),
            BlocProvider(
              create: (context) =>
                  ProductCubit()..fetchProducts(UserDataUtil.getUserId()),
            ),
            BlocProvider(
              create: (context) => PaymentSettingCubit()..fetchCards(),
            ),
          ],
          child: TabBarView(
            controller: _tabController,
            children: const [
              ShopOrderTab(),
              ProductTab(),
              DeliveryTab(),
              PaymentSettingTab(),
            ],
          ),
        ),
      ),
    );
  }
}
