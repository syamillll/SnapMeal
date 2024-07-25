import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/pages/components/instructional_text.dart';
import 'package:snapmeal/pages/manage_item/add_item_page.dart';
import 'package:snapmeal/pages/manage_item/edit_item_page.dart';
import 'package:snapmeal/pages/menu/item_detail_page.dart';
import 'package:snapmeal/providers/item_provider.dart';

class ItemListPage extends StatelessWidget {
  final String categoryId;

  const ItemListPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final filteredItems = itemProvider.getItemsByCategory(categoryId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item List'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
      ),

      // Add item button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddItemPage(categoryId: categoryId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: itemProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredItems.isEmpty
              ? const Center(child: Text('No items found'))
              : Column(
                  children: [
                    const InstructionalText(
                      text:
                          'Tap on an item to view details. Swipe left to delete an item. Tap on the edit icon to edit an item.',
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: errorColor,
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: const Icon(Icons.delete,
                                  color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await showConfirmationDialog(context);
                            },
                            onDismissed: (direction) {
                              itemProvider.deleteItem(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('${item.name} deleted')),
                              );
                            },
                            child: Card(
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: item.image.isNotEmpty
                                        ? Image.network(
                                            item.image, fit: BoxFit.cover)
                                        : const Icon(Icons.image),
                                  ),
                                ),
                                title: Text(item.name),
                                subtitle:
                                    Text('RM${item.price.toStringAsFixed(2)}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    // Navigate to edit item page
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditItemPage(item: item),
                                      ),
                                    );
                                  },
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ItemDetailPage(item: item),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<bool> showConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
