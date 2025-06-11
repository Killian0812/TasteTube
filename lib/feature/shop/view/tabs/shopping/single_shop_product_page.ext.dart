part of 'single_shop_product_page.dart';

class _FeedbackItem extends StatelessWidget {
  final ProductFeedback feedback;

  const _FeedbackItem({
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(feedback.user.image),
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feedback.user.username,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < feedback.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (feedback.text != null && feedback.text!.isNotEmpty)
              Text(
                feedback.text!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              DateTimeUtil.dateTimeddMMyyyy(feedback.createdAt),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImages extends StatefulWidget {
  final List<ImageData> images;
  final bool ship;
  const _ProductImages({required this.images, required this.ship});

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
                    fit: BoxFit.fill,
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
            if (widget.ship)
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
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
