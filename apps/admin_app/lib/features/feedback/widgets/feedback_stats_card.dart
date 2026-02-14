import 'package:flutter/material.dart';

class FeedbackStatsCard extends StatelessWidget {
  final int totalFeedbacks;
  final double averageRating;
  final Map<int, int> ratingDistribution;

  const FeedbackStatsCard({
    super.key,
    required this.totalFeedbacks,
    required this.averageRating,
    required this.ratingDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Feedback Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Summary stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  'Total Feedbacks',
                  totalFeedbacks.toString(),
                  Icons.feedback,
                ),
                _buildStatColumn(
                  context,
                  'Average Rating',
                  averageRating.toStringAsFixed(1),
                  Icons.star,
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // Rating distribution
            const Text(
              'Rating Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            ...List.generate(5, (index) {
              final stars = 5 - index;
              final count = ratingDistribution[stars] ?? 0;
              final percentage = totalFeedbacks > 0
                  ? (count / totalFeedbacks * 100)
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '$stars',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalFeedbacks > 0 ? percentage / 100 : 0,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getRatingColor(stars),
                          ),
                          minHeight: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: Text(
                        '$count (${percentage.toStringAsFixed(0)}%)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Color _getRatingColor(int stars) {
    switch (stars) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
