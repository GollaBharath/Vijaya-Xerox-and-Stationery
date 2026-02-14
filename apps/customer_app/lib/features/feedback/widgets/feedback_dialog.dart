import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
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
  late Future<OrderFeedback?> _feedbackFuture;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final feedbackProvider = Provider.of<FeedbackProvider>(
      context,
      listen: false,
    );
    _feedbackFuture = feedbackProvider.getFeedbackForOrder(widget.orderId);
  }

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
      // Refresh feedback data
      setState(() {
        _feedbackFuture = feedbackProvider.getFeedbackForOrder(widget.orderId);
        _isEditing = false;
      });

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

  Future<void> _updateFeedback() async {
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

    final success = await feedbackProvider.updateFeedback(
      orderId: widget.orderId,
      rating: _rating,
      comment: _commentController.text.trim(),
    );

    if (success && mounted) {
      // Refresh feedback data
      setState(() {
        _feedbackFuture = feedbackProvider.getFeedbackForOrder(widget.orderId);
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feedback updated successfully!'),
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
          return FutureBuilder<OrderFeedback?>(
            future: _feedbackFuture,
            builder: (context, snapshot) {
              final existingFeedback = snapshot.data;
              final hasExistingFeedback = existingFeedback != null;

              // Initialize form with existing feedback if available
              if (hasExistingFeedback && _rating == 0 && !_isEditing) {
                _rating = existingFeedback.rating;
                _commentController.text = existingFeedback.comment ?? '';
              }

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
                          hasExistingFeedback && !_isEditing
                              ? 'Your Feedback'
                              : 'Rate Your Order',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Star rating (disabled if showing existing feedback and not editing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            return GestureDetector(
                              onTap: (hasExistingFeedback && !_isEditing)
                                  ? null
                                  : () {
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
                          enabled: !hasExistingFeedback || _isEditing,
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

                        // Submit/Update button
                        if (!hasExistingFeedback || _isEditing)
                          ElevatedButton(
                            onPressed: feedbackProvider.isSubmitting
                                ? null
                                : (hasExistingFeedback
                                      ? _updateFeedback
                                      : _submitFeedback),
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
                                : Text(
                                    hasExistingFeedback
                                        ? 'Update Feedback'
                                        : 'Submit Feedback',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),

                        // Edit/Done button (for existing feedback)
                        if (hasExistingFeedback) ...[
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                              });
                            },
                            icon: Icon(_isEditing ? Icons.check : Icons.edit),
                            label: Text(
                              _isEditing ? 'Cancel' : 'Edit Feedback',
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: _isEditing
                                  ? Colors.orange
                                  : Colors.grey[600],
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Close button
                        TextButton(
                          onPressed: feedbackProvider.isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(true),
                          child: const Text('Close'),
                        ),

                        // Submitted info (if existing feedback)
                        if (hasExistingFeedback) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Submitted on ${_formatDate(existingFeedback.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
