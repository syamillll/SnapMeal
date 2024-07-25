import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/models/favorite.dart';
import 'package:snapmeal/models/item.dart';
import 'package:snapmeal/pages/menu/item_detail_page.dart';
import 'package:snapmeal/providers/auth_service.dart';

class ItemCard extends StatelessWidget {
  final Item item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<AuthService>(context);
    final isFavorite = favoriteProvider.favorites.any((fav) => fav.itemId == item.id);
    
    return GestureDetector(
      onTap: () {
        // Navigate to item detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(item: item),
          ),
        );
      },
      child: IgnorePointer(
        ignoring: !item.availability,
        child: Opacity(
          opacity: item.availability ? 1.0 : 0.5,
          child: Card(
            elevation: 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with Favorite Button
                Stack(
                  children: [
                    // Image
                    item.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              item.image,
                              height: MediaQuery.of(context).size.height * 0.15,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.image,
                              size: MediaQuery.of(context).size.height * 0.15,
                            ),
                          ),
                    // Favorite Button
                    Positioned(
                      top: 0,
                      right: 0,
                        child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 30,
                        ),
                        color: isFavorite ? Colors.red : Colors.blueGrey,
                        onPressed: () {
                          if (isFavorite) {
                            favoriteProvider.removeFavorite(item.id);
                          } else {
                            final favorite = Favorite(
                              itemId: item.id,
                              userId: favoriteProvider.userId,
                            );
                            favoriteProvider.addFavorite(favorite);
                          }
                        },
                        ),
                    ),
                  ],
                ),

                // Name
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    item.name,
                    textScaler: MediaQuery.textScalerOf(context),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Price
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'RM${item.price.toStringAsFixed(2)}',
                    textScaler: MediaQuery.textScalerOf(context),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),

                // Availability
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: item.availability ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      item.availability ? 'Available' : 'Not Available',
                      style: TextStyle(
                        fontSize: 14,
                        color: item.availability ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
