import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/models/item.dart';
import 'package:snapmeal/pages/components/drawer_menu.dart';
import 'package:snapmeal/pages/menu/item_detail_page.dart';
import 'package:snapmeal/pages/menu/item_card.dart';
import 'package:snapmeal/providers/auth_service.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
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
      body: Consumer<AuthService>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.favorites.isEmpty) {
            return const Center(
              child: Text('No favorite items'),
            );
          }

          return FutureBuilder<List<Item>>(
            future: favoriteProvider.getFavoriteItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error fetching favorite items.'),
                );
              }

              final favoriteItems = snapshot.data!;

              if (favoriteItems.isEmpty) {
                return const Center(
                  child: Text('No favorite items.'),
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
                  itemCount: favoriteItems.length,
                  itemBuilder: (context, index) {
                    final item = favoriteItems[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailPage(item: item),
                          ),
                        );
                      },
                      child: ItemCard(item: item),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
