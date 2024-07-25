import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/drawer_menu.dart';
import 'package:snapmeal/pages/menu/category_tab_view.dart';
import 'package:snapmeal/pages/menu/my_search_bar.dart';
import 'package:snapmeal/providers/item_provider.dart';
import 'package:snapmeal/providers/category_provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return DefaultTabController(
      length: categoryProvider.categories.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu'),
          centerTitle: true,
          foregroundColor: Colors.blueGrey,
          actions: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black54),
              onPressed: () {
                Navigator.of(context).pushNamed('/cart');
              },
            ),
          ],
        ),
        drawer: const DrawerMenu(),
        body: Column(
          children: [
            MySearchBar(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            TabBar(
              isScrollable: true,
              tabs: [
                const Tab(text: 'All'),
                ...categoryProvider.categories.map((category) {
                  return Tab(text: category.name);
                }),
              ],
            ),
            Expanded(
              child: CategoryTabView(
                categoryProvider: categoryProvider,
                itemProvider: itemProvider,
                searchQuery: _searchQuery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
