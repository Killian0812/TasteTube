import 'package:flutter/material.dart';
import 'package:taste_tube/common/color.dart';
import 'package:taste_tube/feature/product/data/product.dart';
import 'package:taste_tube/feature/profile/view/profile_page.dart';

class SingleShopProductPage extends StatelessWidget {
  final Product product;
  const SingleShopProductPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _ProductImages(images: product.images),
          _buildProductDetails(),
          _buildOwnerInfo(context),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (product.categoryId != null)
            GestureDetector(
              onTap: () {
                // TODO: Show products in same category
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
                    const Text(
                      'Category: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: CommonColor.activeBgColor),
                    ),
                    Text(
                      product.categoryName ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: CommonColor.activeBgColor),
                    )
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            product.description ?? 'No description available.',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Price: ${product.currency} ${product.cost.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ProfilePage.provider(product.userId)),
          );
        },
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(product.userImage),
              radius: 26,
            ),
            const SizedBox(width: 8),
            Text(
              product.username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Add to cart functionality
              },
              style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: CommonColor.activeBgColor)),
              child: const Text(
                'Add to Cart',
                style: TextStyle(color: CommonColor.activeBgColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Buy now functionality
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CommonColor.activeBgColor,
              ),
              child: const Text(
                'Buy Now',
                style: TextStyle(color: Colors.white),
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
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.images[index].url,
                fit: BoxFit.cover,
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
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }
}