import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/store/view/tabs/analytic/shop_analytic_cubit.dart';
import 'package:taste_tube/feature/store/view/tabs/analytic/shop_analytic_tab.dart';
import 'package:taste_tube/feature/store/view/tabs/delivery/delivery_option_tab.dart';
import 'package:taste_tube/feature/store/view/tabs/payment/payment_setting_cubit.dart';
import 'package:taste_tube/feature/store/view/tabs/payment/payment_setting_tab.dart';
import 'package:taste_tube/feature/store/view/tabs/product/category_cubit.dart';
import 'package:taste_tube/feature/store/view/tabs/order/shop_order_tab.dart';
import 'package:taste_tube/feature/store/view/tabs/product/product_cubit.dart';
import 'package:taste_tube/feature/store/view/tabs/product/product_tab.dart';
import 'package:taste_tube/feature/store/view/tabs/discount/discount_page.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/core/providers.dart';
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
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      final notifier = getIt<BottomNavigationBarToggleNotifier>();
      // Hide bottom nav bar on Analytics tab
      if (_tabController.index == 4) {
        notifier.hide();
      } else {
        notifier.show();
      }
    });
  }

  @override
  void dispose() {
    getIt<BottomNavigationBarToggleNotifier>().show();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double estimatedTabWidth = 120.0;
              final totalTabsWidth = estimatedTabWidth * 5;
              final isScrollable = totalTabsWidth > constraints.maxWidth;

              return TabBar(
                controller: _tabController,
                isScrollable: isScrollable,
                labelPadding: isScrollable
                    ? const EdgeInsets.symmetric(horizontal: 16.0)
                    : null,
                tabs: const [
                  Tab(icon: Icon(Icons.receipt_long), text: 'Orders'),
                  Tab(icon: Icon(Icons.food_bank_rounded), text: 'Products'),
                  Tab(icon: Icon(Icons.discount_rounded), text: 'Discount'),
                  Tab(icon: Icon(Icons.local_shipping), text: 'Delivery'),
                  Tab(icon: Icon(Icons.payment), text: 'Payment'),
                  Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
                ],
              );
            },
          ),
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
            BlocProvider(
              create: (context) =>
                  ShopAnalyticCubit()..fetchAnalytics(UserDataUtil.getUserId()),
            ),
          ],
          child: TabBarView(
            controller: _tabController,
            children: const [
              ShopOrderTab(),
              ProductTab(),
              DiscountPage(),
              DeliveryOptionTab(),
              PaymentSettingTab(),
              ShopAnalyticTab(),
            ],
          ),
        ),
      ),
    );
  }
}
