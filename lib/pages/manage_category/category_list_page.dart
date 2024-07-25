import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/pages/components/instructional_text.dart';
import 'package:snapmeal/pages/manage_category/add_category_modal.dart';
import 'package:snapmeal/pages/manage_category/edit_category_modal.dart';
import 'package:snapmeal/pages/manage_item/item_list_page.dart';
import 'package:snapmeal/providers/category_provider.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the category provider
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      // App bar
      appBar: AppBar(
        title: const Text('Menu Category'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
      ),

      // Add category button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddCategoryModal(),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: categoryProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryProvider.categories.isEmpty
              ? const Center(child: Text('No categories found'))
              : Column(
                  children: [
                    const InstructionalText(
                      text:
                          'Tap on a category to view details. Swipe left to delete a category. Tap on the edit icon to edit a category.',
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: categoryProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryProvider.categories[index];
                          return Dismissible(
                            key: Key(category.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: errorColor,
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding: EdgeInsets.only(right: 16.0),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showConfirmationDialog(context);
                            },
                            onDismissed: (direction) {
                              categoryProvider.deleteCategory(category.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Category deleted'),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              elevation: 1.0,
                              child: ListTile(
                                title: Text(category.name),
                                onTap: () {
                                  // Navigate to item list page
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ItemListPage(categoryId: category.id),
                                    ),
                                  );
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => EditCategoryModal(
                                        categoryId: category.id,
                                        initialCategoryName: category.name,
                                      ),
                                    );
                                  },
                                ),
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
          content: const Text('Are you sure you want to delete this category?'),
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
