import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_data/product/category.dart';
import 'package:taste_tube/feature/shop/view/cart_page.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_cubit.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_product_page.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/phone_call.util.dart';

class SingleShopPage extends StatefulWidget {
  final String shopId;

  static Widget provider(String shopId) => BlocProvider(
        create: (context) => SingleShopCubit(shopId)..getProducts(),
        child: SingleShopPage(shopId: shopId),
      );

  const SingleShopPage({
    super.key,
    required this.shopId,
  });

  @override
  State<SingleShopPage> createState() => _SingleShopPageState();
}

class _SingleShopPageState extends State<SingleShopPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: BlocBuilder<SingleShopCubit, SingleShopState>(
            builder: (context, state) {
              return Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    foregroundImage: NetworkImage(state.shopImage),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            state.shopName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                          if (state.shopPhone != null &&
                              state.shopPhone!.isNotEmpty)
                            Text(
                              'Hotline: ${state.shopPhone}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (state.shopAddress != null)
                        Text(
                          state.shopAddress!.value,
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await makePhoneCall(state.shopPhone!);
                        },
                        icon: Icon(Icons.phone),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () async {
                          await MapsLauncher.launchQuery(
                              state.shopAddress!.value);
                        },
                        icon: Icon(Icons.location_pin),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                ],
              );
            },
          ),
          actions: [CartButton()],
        ),
        body: BlocListener<SingleShopCubit, SingleShopState>(
            listenWhen: (previous, current) => current is SingleShopError,
            listener: (context, state) {
              if (state is SingleShopError) {
                ToastService.showToast(
                    context, state.message!, ToastType.warning);
              }
            },
            child: Column(
              children: [
                _buildSearchBar(context),
                BlocBuilder<SingleShopCubit, SingleShopState>(
                  builder: (context, state) {
                    if (state is SingleShopLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final categorizedProducts = state.products;
                    return Expanded(
                      child: ListView(
                        children: categorizedProducts.entries.map((entry) {
                          final category = entry.key;
                          final products = entry.value;
                          return _buildCategorySection(category, products);
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            )));
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (keyword) {
                if (keyword.isNotEmpty) {
                  context.read<SingleShopCubit>().searchProducts(keyword);
                } else {
                  context.read<SingleShopCubit>().getProducts();
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(Category category, List<Product> products) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SingleShopProductPage(product: product)));
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyUtil.amountWithCurrency(
                                product.cost, product.currency),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: product.prepTime != null
                                ? [
                                    Icon(Icons.access_time_outlined,
                                        color: Colors.grey, size: 15),
                                    Text(
                                      ' ${product.prepTime != null ? "${product.prepTime} min" : "N/A"}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ]
                                : [const SizedBox.shrink()],
                          ),
                          Text(
                            product.distanceInKm != null
                                ? "${product.distanceInKm!.toStringAsFixed(2)} km"
                                : "",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
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
          if (product.avgRating != null && product.avgRating! > 0.0)
            Positioned(
              top: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.avgRating!.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
