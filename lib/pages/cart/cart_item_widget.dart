import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/models/cart_item.dart';
import 'package:snapmeal/models/item.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/providers/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({super.key, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return FutureBuilder<Item?>(
      future: cartProvider.fetchItem(cartItem.itemId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final item = snapshot.data!;
        return Dismissible(
          key: Key(cartItem.itemId.toString()),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            cartProvider.removeItem(cartItem);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} removed from cart'),
              ),
            );
          },
          background: Container(
            color: errorColor,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: item.image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        cartItem.image,
                        width: 50,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(Icons.image, size: 50),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'RM${item.price.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 4),
                      if (cartItem.selectedOption.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          child: Text(
                            cartItem.selectedOption,
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          cartProvider.decreaseQuantity(cartItem);
                        },
                      ),
                      Text('${cartItem.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          cartProvider.increaseQuantity(cartItem);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
