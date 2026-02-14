import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feedback_provider.dart';

class FeedbackDialog extends StatefulWidget {
  final String orderId;

  const FeedbackDialog({super.key, required this.orderId});

  @override
  State<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final feedbackProvider = Provider.of<FeedbackProvider>(
      context,
      listen: false,
    );

    final success = await feedbackProvider.submitFeedback(
      orderId: widget.orderId,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    if (success && mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your feedback!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted && feedbackProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(feedbackProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Consumer<FeedbackProvider>(
        builder: (context, feedbackProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Rate Your Order',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Star rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = starValue;
                            });
                          },
                          child: Icon(
                            starValue <= _rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 48,
                            color: starValue <= _rating
                                ? Colors.amber
                                : Colors.grey[400],
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),

                    // Rating text
                    if (_rating > 0)
                      Text(
                        _getRatingText(_rating),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    const SizedBox(height: 24),

                    // Comment field
                    TextFormField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        labelText: 'Comments (Optional)',
                        hintText: 'Tell us more about your experience...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ElevatedButton(
                      onPressed: feedbackProvider.isSubmitting
                          ? null
                          : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: feedbackProvider.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Submit Feedback',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 8),

                    // Cancel button
                    TextButton(
                      onPressed: feedbackProvider.isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
