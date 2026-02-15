
import 'package:flutter/material.dart';

enum FilterStyle {
  largeTab,    // Top level: Big rounded tabs
  text,        // Text only
  chip,        // Pill shaped chips
  underline,   // Text with underline
}

class FilterRow<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) labelBuilder;
  final T? selectedItem;
  final ValueChanged<T?> onSelected;
  final FilterStyle style;
  final String? allLabel;
  final Widget Function(T)? iconBuilder;

  const FilterRow({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.selectedItem,
    required this.onSelected,
    this.style = FilterStyle.chip,
    this.allLabel,
    this.iconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (allLabel != null)
             Padding(
               padding: const EdgeInsets.only(right: 8.0),
               child: _buildItem(context, null, allLabel!, selectedItem == null),
             ),
          
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = item == selectedItem;
            return Padding(
              padding: EdgeInsets.only(right: index < items.length - 1 ? 8.0 : 0),
              child: _buildItem(
                context, 
                item, 
                labelBuilder(item), 
                isSelected,
                icon: iconBuilder?.call(item),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, 
    T? item, 
    String label, 
    bool isSelected,
    {Widget? icon}
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; 
    final isDark = theme.brightness == Brightness.dark;
    
    // Colors for unselected state
    final unselectedBgColor = isDark ? Colors.grey[800] : Colors.grey[200];
    final unselectedBorderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    final unselectedTextColor = isDark ? Colors.white70 : Colors.black87;
    
    switch (style) {
      case FilterStyle.largeTab:
        return InkWell(
          onTap: () => onSelected(item),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : unselectedBgColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? primaryColor : unselectedBorderColor,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : unselectedTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );

      case FilterStyle.text:
         return InkWell(
          onTap: () => onSelected(item),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               color: isSelected ? primaryColor.withOpacity(0.1) : null,
               borderRadius: BorderRadius.circular(8),
             ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : unselectedTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );

      case FilterStyle.chip:
        return InkWell(
          onTap: () => onSelected(item),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primaryColor : (isDark ? Colors.green[700]! : Colors.green[300]!), 
              ),
            ),
            child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 if (icon != null) ...[
                    icon,
                    const SizedBox(width: 4),
                 ],
                 Text(
                   label,
                   style: TextStyle(
                     color: isSelected ? Colors.white : (isDark ? Colors.green[300] : Colors.green[700]),
                     fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                     fontSize: 13,
                   ),
                 ),
               ],
            ),
          ),
        );

      case FilterStyle.underline:
        return InkWell(
          onTap: () => onSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? primaryColor : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : unselectedTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        );
    }
  }
}
