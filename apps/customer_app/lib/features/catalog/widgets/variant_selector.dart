import 'package:flutter/material.dart';
import 'package:flutter_shared/flutter_shared.dart';

/// Widget for selecting product variants (color/B&W)
class VariantSelector extends StatelessWidget {
  final List<ProductVariant> variants;
  final ProductVariant? selectedVariant;
  final Function(ProductVariant) onVariantSelected;

  const VariantSelector({
    super.key,
    required this.variants,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Variant', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: variants.map((variant) {
            final isSelected = selectedVariant?.id == variant.id;
            final isAvailable = variant.stock;

            return ChoiceChip(
              label: Text(_getVariantLabel(variant)),
              selected: isSelected,
              onSelected: isAvailable
                  ? (selected) {
                      if (selected) {
                        onVariantSelected(variant);
                      }
                    }
                  : null,
              selectedColor: Theme.of(context).primaryColor,
              backgroundColor: Colors.grey[200],
              disabledColor: Colors.grey[300],
              labelStyle: TextStyle(
                color: !isAvailable
                    ? Colors.grey
                    : isSelected
                    ? Colors.white
                    : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getVariantLabel(ProductVariant variant) {
    final variantType = variant.variantType.toUpperCase();

    if (variantType == 'COLOR') {
      return 'Color (₹${variant.price})';
    } else if (variantType == 'BW' || variantType == 'B&W') {
      return 'B&W (₹${variant.price})';
    } else {
      return '${variant.variantType} (₹${variant.price})';
    }
  }
}
