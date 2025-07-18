import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/feature/shop/data/shop_response.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/shop_cubit.dart';
import 'package:taste_tube/feature/shop/view/tabs/shopping/single_shop_product_page.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/utils/currency.util.dart';

class ShopTab extends StatefulWidget {
  const ShopTab({super.key});

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final int _limit = 10;
  ProductOrderBy _selectedOrder = ProductOrderBy.distance;

  @override
  void initState() {
    super.initState();

    // Set up infinite scrolling
    _scrollController.addListener(() {
      final cubit = context.read<ShopCubit>();
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          cubit.state.pagination.hasNextPage &&
          cubit.state is! ShopLoading) {
        final nextPage = cubit.state.pagination.page + 1;
        if (_searchController.text.isEmpty) {
          cubit.getRecommendedProducts(
            page: nextPage,
            loadMore: true,
            orderBy: _selectedOrder,
          );
        } else {
          cubit.searchProducts(
            keyword: _searchController.text,
            page: nextPage,
            loadMore: true,
            orderBy: _selectedOrder,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBarAndFilterBox(),
        Expanded(
          child: BlocBuilder<ShopCubit, ShopState>(
            builder: (context, state) {
              return state is ShopLoading && state.products.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProductGrid(
                      state.products,
                      hasNextPage: state.pagination.hasNextPage,
                      isLoadingMore: state is ShopLoading,
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarAndFilterBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (keyword) {
                if (keyword.isNotEmpty) {
                  context.read<ShopCubit>().searchProducts(
                        keyword: keyword,
                        page: 1,
                        limit: _limit,
                        orderBy: _selectedOrder,
                      );
                } else {
                  context.read<ShopCubit>().getRecommendedProducts(
                        orderBy: _selectedOrder,
                      );
                }
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ShopCubit>().getRecommendedProducts(
                          orderBy: _selectedOrder,
                        );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<ProductOrderBy>(
            value: _selectedOrder,
            underline: const SizedBox(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedOrder = value);

              final keyword = _searchController.text.trim();
              if (keyword.isNotEmpty) {
                context.read<ShopCubit>().searchProducts(
                      keyword: keyword,
                      page: 1,
                      limit: _limit,
                      orderBy: _selectedOrder,
                    );
              } else {
                context.read<ShopCubit>().getRecommendedProducts(
                      orderBy: _selectedOrder,
                    );
              }
            },
            items: ProductOrderBy.values.map((order) {
              return DropdownMenuItem(
                value: order,
                child: Text(order.label),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
    List<Product> products, {
    required bool hasNextPage,
    required bool isLoadingMore,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          onRefresh: () async {
            _searchController.clear();
            context
                .read<ShopCubit>()
                .getRecommendedProducts(orderBy: _selectedOrder);
          },
          child: GridView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 2 / 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length + (hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == products.length) {
                if (hasNextPage && isLoadingMore) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox.shrink();
              }
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SingleShopProductPage(product: product),
                    ),
                  );
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
                              child: product.images.isNotEmpty
                                  ? Image.network(
                                      product.images[0].url,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image),
                                    )
                                  : const Icon(Icons.image_not_supported),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  CurrencyUtil.amountWithCurrency(
                                      product.cost, product.currency),
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.green[700]),
                                ),
                                if (product.shopAddress != null)
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin,
                                          color: Colors.grey, size: 15),
                                      Expanded(
                                        child: Text(
                                          " ${product.shopAddress!.value}",
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                    fontSize: 12,
                                                    color: Colors.grey),
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
            },
          ),
        );
      },
    );
  }
}
