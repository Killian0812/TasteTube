import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/common/text.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/feature/product/data/product.dart';
import 'package:taste_tube/feature/shop/view/shop_cubit.dart';

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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<ShopCubit, ShopState>(
              listenWhen: (previous, current) => current is ShopError,
              listener: (context, state) {
                if (state is ShopError) {
                  ToastService.showToast(
                      context, state.message!, ToastType.warning);
                }
              },
            ),
          ],
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
        decoration: InputDecoration(
          hintText: 'Search products...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(),
          ),
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
              Tab(icon: Icon(Icons.location_on), text: 'Location'),
              Tab(icon: Icon(Icons.payment), text: 'Payment'),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
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
            // TODO: Navigate to product details page
          },
          child: Card(
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    product.images[0].url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
