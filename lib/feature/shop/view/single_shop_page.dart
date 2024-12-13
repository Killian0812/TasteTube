import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taste_tube/common/toast.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_data/product/category.dart';
import 'package:taste_tube/feature/shop/view/cart_page.dart';
import 'package:taste_tube/feature/shop/cubit/single_shop_cubit.dart';
import 'package:taste_tube/feature/shop/view/single_shop_product_page.dart';
import 'package:taste_tube/utils/phone_call.util.dart';

class SingleShopPage extends StatefulWidget {
  final String shopId;
  final String shopImage;
  final String shopName;
  final String? shopPhone;

  static Widget provider(
    String shopId,
    String shopImage,
    String shopName,
    String? shopPhone,
  ) =>
      BlocProvider(
        create: (context) => SingleShopCubit(shopId),
        child: SingleShopPage(
          shopId: shopId,
          shopImage: shopImage,
          shopName: shopName,
          shopPhone: shopPhone,
        ),
      );

  const SingleShopPage({
    super.key,
    required this.shopId,
    required this.shopImage,
    required this.shopName,
    this.shopPhone,
  });

  @override
  State<SingleShopPage> createState() => _SingleShopPageState();
}

class _SingleShopPageState extends State<SingleShopPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SingleShopCubit>().getProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                foregroundImage: NetworkImage(widget.shopImage),
              ),
              const SizedBox(width: 10),
              Text(
                widget.shopName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.shopPhone != null && widget.shopPhone!.isNotEmpty) ...[
                const SizedBox(width: 30),
                GestureDetector(
                  onTap: () async {
                    await makePhoneCall(widget.shopPhone!);
                  },
                  child: Text(
                    'Hotline: ${widget.shopPhone}',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
              ]
            ],
          ),
          actions: const [CartButton()],
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
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
  }
}
