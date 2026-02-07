import 'package:flutter/material.dart';

/// Quantity selector widget with increment/decrement buttons
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int minQuantity;
  final int? maxQuantity;
  final bool compact;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.minQuantity = 1,
    this.maxQuantity,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = quantity > minQuantity;
    final canIncrement = maxQuantity == null || quantity < maxQuantity!;

    if (compact) {
      return _buildCompactSelector(context, canDecrement, canIncrement);
    }

    return _buildStandardSelector(context, canDecrement, canIncrement);
  }

  Widget _buildStandardSelector(
    BuildContext context,
    bool canDecrement,
    bool canIncrement,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: canDecrement ? onDecrement : null,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: canIncrement ? onIncrement : null,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSelector(
    BuildContext context,
    bool canDecrement,
    bool canIncrement,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: canDecrement ? onDecrement : null,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.remove,
                size: 16,
                color: canDecrement ? null : Colors.grey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              quantity.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          InkWell(
            onTap: canIncrement ? onIncrement : null,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                Icons.add,
                size: 16,
                color: canIncrement ? null : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
