import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/widgets/admin_scaffold.dart';
import '../../../routing/route_names.dart';
import '../providers/feedback_provider.dart';
import '../widgets/feedback_card.dart';
import '../widgets/feedback_stats_card.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFeedbacks();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final provider = Provider.of<AdminFeedbackProvider>(
        context,
        listen: false,
      );
      if (!provider.isLoading && provider.currentPage < provider.totalPages) {
        provider.loadNextPage();
      }
    }
  }

  Future<void> _loadFeedbacks() async {
    final provider = Provider.of<AdminFeedbackProvider>(context, listen: false);
    await provider.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Customer Feedback',
      currentRoute: RouteNames.feedback,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadFeedbacks,
          tooltip: 'Refresh',
        ),
      ],
      body: RefreshIndicator(
        onRefresh: _loadFeedbacks,
        child: Consumer<AdminFeedbackProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && !provider.hasFeedbacks) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && !provider.hasFeedbacks) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      provider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadFeedbacks,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!provider.hasFeedbacks) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.feedback_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No feedback yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customer feedback will appear here',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.hasFeedbacks
                  ? provider.feedbacks.length +
                        2 // +2 for stats and loading
                  : 1,
              itemBuilder: (context, index) {
                // Statistics card at top
                if (index == 0) {
                  return Column(
                    children: [
                      FeedbackStatsCard(
                        totalFeedbacks: provider.totalFeedbacks,
                        averageRating: provider.averageRating,
                        ratingDistribution: provider.ratingDistribution,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                // Feedback cards
                if (index <= provider.feedbacks.length) {
                  final feedback = provider.feedbacks[index - 1];
                  return FeedbackCard(
                    feedback: feedback,
                    onTap: () {
                      // Could navigate to order details or show full feedback
                    },
                  );
                }

                // Loading indicator at bottom
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}
