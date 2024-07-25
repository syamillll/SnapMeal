import 'package:flutter/material.dart';
import 'package:snapmeal/models/item.dart';
import 'package:snapmeal/pages/menu/item_card.dart';


class ItemsGrid extends StatelessWidget {
  final List<Item> items;
  final String searchQuery;

  const ItemsGrid({super.key, required this.items, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final filteredItems = items
        .where((item) => item.name.toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();

    if (filteredItems.isEmpty) {
      return const Center(
        child: Text(
          'No items found',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of items per row
          crossAxisSpacing: 10.0, // Space between columns
          mainAxisSpacing: 10.0, // Space between rows
          childAspectRatio: 0.8, // Aspect ratio of the grid items
        ),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return ItemCard(item: item);
        },
      ),
    );
  }
}
