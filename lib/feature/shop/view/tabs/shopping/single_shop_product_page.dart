import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/feature/shop/view/cart_page.dart';
import 'package:taste_tube/feature/shop/view/payment/payment_page.dart';
import 'package:taste_tube/feature/shop/view/quantity_dialog.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/phone_call.util.dart';

class SingleShopProductPage extends StatelessWidget {
  final Product product;
  const SingleShopProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        centerTitle: true,
        actions: const [CartButton()],
      ),
      body: BlocListener<CartCubit, CartState>(
        listener: (context, state) {
          if (state is AddedToCartAndReadyToPay) {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (context) => PaymentPage.provider()),
            );
          }
        },
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            final horizontalPadding =
                sizingInformation.isDesktop ? 250.0 : 16.0;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: sizingInformation.isDesktop
                  ? _buildDesktopLayout(context, sizingInformation)
                  : _buildMobileLayout(context, sizingInformation),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, SizingInformation sizingInformation) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images (Left)
              Expanded(
                flex: 1,
                child: _ProductImages(images: product.images),
              ),
              // Product Details (Right)
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildProductDetails(context, sizingInformation),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Owner Info and Action Buttons
        _buildOwnerInfo(context, sizingInformation),
        const Divider(height: 1, color: Colors.grey),
        _buildActionButtons(context, sizingInformation),
      ],
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, SizingInformation sizingInformation) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              _ProductImages(images: product.images),
              _buildProductDetails(context, sizingInformation),
              _buildOwnerInfo(context, sizingInformation),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
        _buildActionButtons(context, sizingInformation),
      ],
    );
  }

  Widget _buildProductDetails(
      BuildContext context, SizingInformation sizingInformation) {
    final textScaleFactor = sizingInformation.isDesktop ? 1.2 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              product.name,
              style: TextStyle(
                fontSize: 24 * textScaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product.ship)
              Container(
                margin: const EdgeInsets.only(left: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Ship',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15 * textScaleFactor,
                  ),
                ),
              ),
          ],
        ),
        if (product.categoryId != null)
          GestureDetector(
            onTap: () {
              context.pushNamed('single-shop', pathParameters: {
                'shopId': product.userId,
              }, extra: {
                'shopImage': product.userImage,
                'shopName': product.username,
                'shopPhone': product.userPhone,
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.fromBorderSide(
                    BorderSide(color: CommonColor.activeBgColor)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Category: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20 * textScaleFactor,
                      color: CommonColor.activeBgColor,
                    ),
                  ),
                  Text(
                    product.categoryName ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20 * textScaleFactor,
                      color: CommonColor.activeBgColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        if (product.description != null && product.description!.isNotEmpty) ...[
          Text(
            product.description!,
            style: TextStyle(
              fontSize: 16 * textScaleFactor,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Price: ${CurrencyUtil.amountWithCurrency(product.cost, product.currency)}',
          style: TextStyle(
            fontSize: 18 * textScaleFactor,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo(
      BuildContext context, SizingInformation sizingInformation) {
    final textScaleFactor = sizingInformation.isDesktop ? 1.2 : 1.0;
    final avatarRadius = sizingInformation.isDesktop ? 32.0 : 26.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          context.push('/user/${product.userId}');
        },
        child: Row(children: [
          CircleAvatar(
            backgroundImage: NetworkImage(product.userImage),
            radius: avatarRadius,
          ),
          const SizedBox(width: 8),
          Text(
            product.username,
            style: TextStyle(
              fontSize: 22 * textScaleFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (product.userPhone != null && product.userPhone!.isNotEmpty) ...[
            const SizedBox(width: 30),
            GestureDetector(
              onTap: () async {
                await makePhoneCall(product.userPhone!);
              },
              child: Text(
                'Hotline: ${product.userPhone}',
                style: TextStyle(
                  fontSize: 22 * textScaleFactor,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, SizingInformation sizingInformation) {
    if (!product.ship) {
      return const SizedBox.shrink();
    }
    final textScaleFactor = sizingInformation.isDesktop ? 1.2 : 1.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                int? quantity = await showDialog<int>(
                  context: context,
                  builder: (context) => const QuantityInputDialog(),
                );
                if (!context.mounted || quantity == null || quantity < 1) {
                  return;
                }
                context.read<CartCubit>().addToCart(product, quantity);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: CommonColor.activeBgColor),
              ),
              child: Text(
                'Add to Cart',
                style: TextStyle(
                  color: CommonColor.activeBgColor,
                  fontSize: 16 * textScaleFactor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                int? quantity = await showDialog<int>(
                  context: context,
                  builder: (context) => const QuantityInputDialog(),
                );
                if (!context.mounted || quantity == null || quantity < 1) {
                  return;
                }
                context
                    .read<CartCubit>()
                    .addToCartAndPayImmediate(product, quantity);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CommonColor.activeBgColor,
              ),
              child: Text(
                'Buy Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * textScaleFactor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImages extends StatefulWidget {
  final List<ImageData> images;
  const _ProductImages({required this.images});

  @override
  State<_ProductImages> createState() => _ProductImagesState();
}

class _ProductImagesState extends State<_ProductImages> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.toInt();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final imageHeight = sizingInformation.isDesktop ? 450.0 : 350.0;
        final textScaleFactor = sizingInformation.isDesktop ? 1.2 : 1.0;

        return Stack(
          alignment: Alignment.bottomRight,
          children: [
            SizedBox(
              height: imageHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.images[index].url,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 10, right: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                color: CommonColor.activeBgColor,
              ),
              child: Text(
                '${(_currentIndex + 1).toString()}/${widget.images.length.toString()}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * textScaleFactor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
