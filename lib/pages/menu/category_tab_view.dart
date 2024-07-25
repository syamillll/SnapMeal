import 'package:flutter/material.dart';
import 'package:snapmeal/pages/menu/item_grid.dart';
import 'package:snapmeal/providers/category_provider.dart';
import 'package:snapmeal/providers/item_provider.dart';


class CategoryTabView extends StatelessWidget {
  final CategoryProvider categoryProvider;
  final ItemProvider itemProvider;
  final String searchQuery;

  const CategoryTabView({
    super.key,
    required this.categoryProvider,
    required this.itemProvider,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        // All Items Tab
        itemProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ItemsGrid(items: itemProvider.items, searchQuery: searchQuery),
        // Category Tabs
        ...categoryProvider.categories.map((category) {
          final categoryItems = itemProvider.getItemsByCategory(category.id);
          return itemProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ItemsGrid(items: categoryItems, searchQuery: searchQuery);
        }),
      ],
    );
  }
}
