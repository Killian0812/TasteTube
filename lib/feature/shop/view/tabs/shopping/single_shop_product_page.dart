import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/feature/profile/view/profile_cubit.dart';
import 'package:taste_tube/feature/shop/view/cart_page.dart';
import 'package:taste_tube/feature/shop/view/payment/payment_page.dart';
import 'package:taste_tube/feature/shop/view/quantity_dialog.dart';
import 'package:taste_tube/feature/shop/view/tabs/order/feedback_cubit.dart';
import 'package:taste_tube/global_bloc/order/cart_cubit.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_data/product/feedback.dart';
import 'package:taste_tube/utils/currency.util.dart';
import 'package:taste_tube/utils/datetime.util.dart';
import 'package:taste_tube/utils/phone_call.util.dart';

part 'single_shop_product_page.ext.dart';

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
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  FeedbackCubit()..getProductFeedbacks(product.id),
            ),
            BlocProvider(
              create: (context) =>
                  ProfileCubit(product.userId)..init(productId: product.id),
            ),
          ],
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
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context, SizingInformation sizingInformation) {
    return Column(
      children: [
        Expanded(
          flex: 7,
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
                    child: Column(
                      children: [
                        _buildProductDetails(context, sizingInformation),
                        _buildOwnerInfo(context, sizingInformation),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 6,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: "Order Feedback"),
                    Tab(text: "Customer Reviews"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildFeedbackSection(context, sizingInformation),
                      _buildReviewSection(context, sizingInformation),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
          child: DefaultTabController(
            length: 2,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductImages(images: product.images),
                  const SizedBox(height: 16),
                  _buildProductDetails(context, sizingInformation),
                  _buildOwnerInfo(context, sizingInformation),
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: "Order Feedback"),
                      Tab(text: "Customer Reviews"),
                    ],
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildFeedbackSection(context, sizingInformation),
                        _buildReviewSection(context, sizingInformation),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.grey),
        _buildActionButtons(context, sizingInformation),
      ],
    );
  }

  Widget _buildProductDetails(
      BuildContext context, SizingInformation sizingInformation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              product.name,
              style: TextStyle(
                fontSize: 20,
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
                    fontSize: 15,
                  ),
                ),
              ),
          ],
        ),
        if (product.categoryId != null)
          GestureDetector(
            onTap: () {
              context.push("/shop/${product.userId}");
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.fromBorderSide(
                    BorderSide(color: CommonColor.activeBgColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Category: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: CommonColor.activeBgColor,
                    ),
                  ),
                  Text(
                    product.categoryName ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
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
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Price: ${CurrencyUtil.amountWithCurrency(product.cost, product.currency)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerInfo(
      BuildContext context, SizingInformation sizingInformation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: GestureDetector(
        onTap: () {
          context.push('/user/${product.userId}');
        },
        child: Row(children: [
          CircleAvatar(
            backgroundImage: NetworkImage(product.userImage),
            radius: 24,
          ),
          const SizedBox(width: 8),
          Text(
            product.username,
            style: TextStyle(
              fontSize: 20,
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
                  fontSize: 20,
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                side: const BorderSide(color: CommonColor.activeBgColor),
              ),
              child: Text(
                'Add to Cart',
                style: TextStyle(
                  color: CommonColor.activeBgColor,
                  fontSize: 16,
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                backgroundColor: CommonColor.activeBgColor,
              ),
              child: Text(
                'Buy Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(
      BuildContext context, SizingInformation sizingInformation) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: BlocBuilder<FeedbackCubit, FeedbackState>(
          builder: (context, state) {
            if (state is FeedbackLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildFeedbackList(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildReviewSection(
      BuildContext context, SizingInformation sizingInformation) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading && state.reviews.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildReviewGrid(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildFeedbackList(BuildContext context, FeedbackState state) {
    if (state.feedbacks.isEmpty) {
      return Center(
        child: Text(
          'No feedback yet.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
      );
    }
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.feedbacks.length,
          itemBuilder: (context, index) {
            final feedback = state.feedbacks[index];
            return _FeedbackItem(feedback: feedback);
          },
        ),
        if (state.totalPages > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(state.totalPages, (index) {
                final page = index + 1;
                final isCurrentPage = page == state.currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: isCurrentPage
                        ? null
                        : () {
                            context
                                .read<FeedbackCubit>()
                                .loadSpecificPage(product.id, page);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrentPage
                          ? CommonColor.activeBgColor
                          : Colors.grey[300],
                      foregroundColor:
                          isCurrentPage ? Colors.white : Colors.black,
                      minimumSize: Size(40, 40),
                      padding: const EdgeInsets.all(0),
                    ),
                    child: Text(
                      page.toString(),
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewGrid(BuildContext context, ProfileState state) {
    if (state.reviews.isEmpty) {
      return Center(
        child: Text(
          'No reviews yet.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: state.reviews.length,
      itemBuilder: (context, index) {
        final video = state.reviews[index];
        return GestureDetector(
          onTap: () {
            context.push('/watch/${video.id}', extra: state.reviews);
          },
          child: Stack(
            children: [
              Image.memory(
                base64Decode(video.thumbnail ?? ''),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                bottom: 5,
                left: 5,
                child: Row(
                  children: [
                    const Icon(
                      Icons.visibility,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      state.reviews[index].views.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
