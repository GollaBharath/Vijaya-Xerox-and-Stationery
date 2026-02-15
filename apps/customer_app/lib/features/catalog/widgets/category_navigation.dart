
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shared/flutter_shared.dart';
import '../providers/category_provider.dart';
import '../providers/subject_provider.dart';
import 'filter_row.dart';

class CategoryNavigation extends StatefulWidget {
  final Function(String? categoryId, String? subjectId) onSelectionChanged;
  final String? initialCategoryId;
  final String? initialSubjectId;

  const CategoryNavigation({
    super.key,
    required this.onSelectionChanged,
    this.initialCategoryId,
    this.initialSubjectId,
  });

  @override
  State<CategoryNavigation> createState() => _CategoryNavigationState();
}

class _CategoryNavigationState extends State<CategoryNavigation> {
  // Path of selected category IDs, from root to leaf
  List<String> _selectedCategoryIds = [];
  String? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    // Reconstruct path if initialCategoryId is provided
    // This is complex because we need to find parents. 
    // For now, let's start fresh. 
    // Ideally, CategoryProvider should have a method to get path to root.
  }
  
  // Method to handle category selection at a specific depth
  void _onCategorySelected(Category category, int depth) {
    setState(() {
      // 1. Truncate the path to the current depth
      if (_selectedCategoryIds.length > depth) {
        _selectedCategoryIds = _selectedCategoryIds.sublist(0, depth);
      }
      
      // 2. Add the new selection
      _selectedCategoryIds.add(category.id);
      
      // 3. Clear deeper selections/subjects
      _selectedSubjectId = null;
    });

    _notifySelection();
  }

  // Method to handle user deselecting or clearing a level
  // Actually, FilterRow usually enforces selection if we tap a different one.
  // We can add logic to toggle off if needed, but typically tabs switch.

  void _onSubjectSelected(Subject? subject) {
    setState(() {
      if (subject == null) {
        // 'All' was selected - clear subject filter
        _selectedSubjectId = null;
      } else if (_selectedSubjectId == subject.id) {
        _selectedSubjectId = null; // Toggle off
      } else {
        _selectedSubjectId = subject.id;
      }
    });

    _notifySelection();
  }

  void _notifySelection() {
    // If a subject is selected, pass ONLY the subject ID.
    // The backend uses strict AND logic (category AND subject).
    // Pasing categoryId might fail if the product isn't explicitly linked to the category
    // but only linked to the subject. Since Subject implies Category, this is safe.
    
    String? categoryId;
    if (_selectedSubjectId != null) {
      categoryId = null; 
    } else {
       categoryId = _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds.last : null;
    }
    
    widget.onSelectionChanged(categoryId, _selectedSubjectId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CategoryProvider, SubjectProvider>(
      builder: (context, categoryProvider, subjectProvider, child) {
        if (categoryProvider.isLoading) {
          return const LinearProgressIndicator();
        }

        final rows = <Widget>[];

        // --- Level 0 : Root Categories ---
        final rootCategories = categoryProvider.rootCategories;
        if (rootCategories.isEmpty) {
           return Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             child: Text(
               'No categories found. Please check database connectivity or seed data.',
               style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
             ),
           );
        } else {
           String? selectedId = _selectedCategoryIds.isNotEmpty ? _selectedCategoryIds[0] : null;

           Category? selectedCategory;
           if (selectedId != null) {
              try {
                selectedCategory = rootCategories.firstWhere((c) => c.id == selectedId);
              } catch (_) {}
           }

           rows.add(
             FilterRow<Category>(
               items: rootCategories,
               labelBuilder: (c) => c.name,
               selectedItem: selectedCategory,
               onSelected: (cat) {
                 if (cat != null) _onCategorySelected(cat, 0);
               },
               style: FilterStyle.largeTab,
             )
           );
        }

        // --- Intermediate Levels ---
        // Iterate through selected categories to show their children
        for (int i = 0; i < _selectedCategoryIds.length; i++) {
            final parentId = _selectedCategoryIds[i];
            final children = categoryProvider.getChildCategories(parentId);
            
            if (children.isNotEmpty) {
               // Determine if a child in this level is selected
               String? selectedChildId = (i + 1 < _selectedCategoryIds.length) 
                   ? _selectedCategoryIds[i + 1] 
                   : null;
               
               Category? selectedChild;
               if (selectedChildId != null) {
                 try {
                   selectedChild = children.firstWhere((c) => c.id == selectedChildId);
                 } catch (_) {}
               }

               rows.add(
                 FilterRow<Category>(
                   items: children,
                   labelBuilder: (c) => c.name,
                   selectedItem: selectedChild,
                   onSelected: (cat) {
                      if (cat != null) _onCategorySelected(cat, i + 1);
                   },
                    style: FilterStyle.chip, // All intermediate levels use chip style
                 )
               );
            }
        }

        // --- Subject Level ---
        // Show subjects for the LAST selected category
        if (_selectedCategoryIds.isNotEmpty) {
          final lastCategoryId = _selectedCategoryIds.last;
          // Only show subjects if there are NO further subcategories?
          // Or show subjects ANYWAY?
          // Design: "Last line ... are the subjects".
          // Usually logical to show subjects when we reach a leaf category or specific depth.
          // Let's check if the current category has children.
          final hasChildren = categoryProvider.getChildCategories(lastCategoryId).isNotEmpty;
          
          if (!hasChildren) {
             final subjects = subjectProvider.getSubjectsByCategoryId(lastCategoryId);
             
             if (subjects.isNotEmpty) {
                Subject? selectedSubject;
                if (_selectedSubjectId != null) {
                   selectedSubject = subjectProvider.getSubjectById(_selectedSubjectId!);
                }

                rows.add(
                  FilterRow<Subject>(
                    items: subjects,
                    labelBuilder: (s) => s.name,
                    selectedItem: selectedSubject,
                     onSelected: (sub) {
                       _onSubjectSelected(sub);
                     },
                    style: FilterStyle.underline,
                  )
                );
             }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: rows.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: r,
          )).toList(),
        );
      },
    );
  }
}
