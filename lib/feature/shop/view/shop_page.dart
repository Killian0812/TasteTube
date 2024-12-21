import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/shop/view/cart_page.dart';
import 'package:taste_tube/feature/shop/view/tabs/address/address_cubit.dart';
import 'package:taste_tube/feature/shop/view/tabs/address/address_tab.dart';
import 'package:taste_tube/feature/shop/view/tabs/order/customer_order_tab.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/shop_tab.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/shop_cubit.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  static Widget provider() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ShopCubit()..getRecommendedProducts(),
          ),
          BlocProvider(
            create: (context) => AddressCubit()..fetchAddresses(),
          ),
        ],
        child: const ShopPage(),
      );

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ShopCubit>().getRecommendedProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonTextWidget.tasteTubeMini,
                const SizedBox(width: 10),
                const Text(
                  "Shop",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: const [CartButton()],
            bottom: const TabBar(
              labelColor: Colors.black,
              indicatorColor: CommonColor.activeBgColor,
              tabs: [
                Tab(icon: Icon(Icons.shopping_basket_rounded), text: 'Shop'),
                Tab(icon: Icon(Icons.receipt_long), text: 'Order'),
                Tab(icon: Icon(Icons.card_giftcard), text: 'Voucher'),
                Tab(icon: Icon(Icons.location_on), text: 'Address'),
                Tab(icon: Icon(Icons.payment), text: 'Payment'),
              ],
            ),
          ),
          body: BlocListener<ShopCubit, ShopState>(
            listenWhen: (previous, current) => current is ShopError,
            listener: (context, state) {
              if (state is ShopError) {
                ToastService.showToast(
                    context, state.message!, ToastType.warning);
              }
            },
            child: const TabBarView(
              children: [
                ShopTab(),
                CustomerOrderTab(),
                Placeholder(),
                AddressTab(),
                Placeholder(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
