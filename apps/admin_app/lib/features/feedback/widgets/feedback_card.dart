import 'package:flutter/material.dart';
import 'package:flutter_shared/flutter_shared.dart';
import 'package:intl/intl.dart';

class FeedbackCard extends StatelessWidget {
  final OrderFeedback feedback;
  final VoidCallback? onTap;

  const FeedbackCard({super.key, required this.feedback, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Customer name and date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feedback.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(feedback.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Rating
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < feedback.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${feedback.rating}/5',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              // Comment
              if (feedback.comment != null && feedback.comment!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  feedback.comment!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Order ID
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Order #${feedback.orderId.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
