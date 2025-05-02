part of 'customer_order_tab.dart';

class _FeedbackDialog extends StatefulWidget {
  final Order order;

  const _FeedbackDialog({required this.order});

  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  final Map<String, double?> _ratings = {};

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Your Order'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Overall Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('Rate Products:'),
            ...widget.order.items.map((item) {
              final product = item.product;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(product.name),
                  _StarRating(
                    rating: _ratings[item.product.id],
                    onRatingChanged: (rating) {
                      setState(() {
                        _ratings[item.product.id] = rating;
                      });
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final feedback = _feedbackController.text.trim();
            context.read<OrderCubit>().updateOrderFeedback(
                  widget.order.id,
                  feedback,
                  _ratings,
                );
            Navigator.of(context).pop();
            ToastService.showToast(
                context, 'Feedback submitted', ToastType.success);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _StarRating extends StatefulWidget {
  final double? rating;
  final ValueChanged<double?> onRatingChanged;

  const _StarRating({required this.rating, required this.onRatingChanged});

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<_StarRating> {
  double? _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return IconButton(
          icon: Icon(
            _currentRating != null && _currentRating! >= starValue
                ? Icons.star
                : Icons.star_border,
            color: Colors.amber,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _currentRating = starValue.toDouble();
              widget.onRatingChanged(_currentRating);
            });
          },
        );
      }),
    );
  }
}
