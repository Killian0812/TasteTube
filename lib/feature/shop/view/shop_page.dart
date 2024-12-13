import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/feature/shop/view/cart_page.dart';
import 'package:taste_tube/feature/shop/cubit/shop_cubit.dart';
import 'package:taste_tube/feature/shop/view/single_shop_product_page.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  static Widget provider() => BlocProvider(
        create: (context) => ShopCubit()..getRecommendedProducts(),
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
    return SafeArea(
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
        ),
        body: BlocListener<ShopCubit, ShopState>(
          listenWhen: (previous, current) => current is ShopError,
          listener: (context, state) {
            if (state is ShopError) {
              ToastService.showToast(
                  context, state.message!, ToastType.warning);
            }
          },
          child: Column(
            children: [
              _buildSearchBar(),
              _buildTabBar(),
              Expanded(
                child: BlocBuilder<ShopCubit, ShopState>(
                  builder: (context, state) {
                    if (state is ShopLoading && state.products.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return _buildProductGrid(state.products);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onSubmitted: (keyword) {
          if (keyword.isNotEmpty) {
            context.read<ShopCubit>().searchProducts(keyword);
          } else {
            context.read<ShopCubit>().getRecommendedProducts();
          }
        },
        decoration: const InputDecoration(
          hintText: 'Search products...',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return const DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
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
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return RefreshIndicator(
      onRefresh: () async {
        _searchController.clear();
        context.read<ShopCubit>().getRecommendedProducts();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2 / 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      SingleShopProductPage(product: product)));
            },
            child: Stack(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image.network(
                            product.images[0].url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.currency} ${product.cost.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (product.ship)
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Ship',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
