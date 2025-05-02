part of 'customer_order_tab.dart';

class _FeedbackDialog extends StatefulWidget {
  final String orderId;
  final Product product;

  const _FeedbackDialog({required this.product, required this.orderId});

  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final TextEditingController _feedbackController = TextEditingController();
  int? _rating = 0;

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
            const Text('Rate Product:'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(widget.product.name),
                _StarRating(
                  rating: _rating,
                  onRatingChanged: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Feedback',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
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
            if (_rating == null) {
              ToastService.showToast(
                  context, 'Please select a rating', ToastType.error);
              return;
            }
            final feedback = _feedbackController.text.trim();
            context.read<FeedbackCubit>().updateProductFeedback(
                  orderId: widget.orderId,
                  productId: widget.product.id,
                  rating: _rating!,
                  feedback: feedback,
                );
            Navigator.of(context).pop();
            ToastService.showToast(
                context, 'Feedback submitted', ToastType.success);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: (_rating == null)
                ? Theme.of(context).disabledColor
                : Theme.of(context).colorScheme.primary,
          ),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class _StarRating extends StatefulWidget {
  final int? rating;
  final ValueChanged<int?> onRatingChanged;

  const _StarRating({required this.rating, required this.onRatingChanged});

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<_StarRating> {
  int? _currentRating;

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
              _currentRating = starValue;
              widget.onRatingChanged(_currentRating);
            });
          },
        );
      }),
    );
  }
}
