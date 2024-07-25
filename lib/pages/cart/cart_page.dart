import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/cart/cart_item_widget.dart';
import 'package:snapmeal/pages/cart/total_price_box.dart';
import 'package:snapmeal/providers/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<CartProvider>(context).fetchServiceCharge();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Are you sure you want to clear your cart?'),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Clear'),
                        onPressed: () {
                          Provider.of<CartProvider>(context, listen: false).removeAllItems();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cart cleared'),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                final cartItems = cartProvider.cartItems;

                if (cartItems.isEmpty) {
                  return const Center(
                    child: Text('Your cart is empty'),
                  );
                }

                return ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    return CartItemWidget(cartItem: cartItem);
                  },
                );
              },
            ),
          ),
          TotalPriceBox(
            subtotal: Provider.of<CartProvider>(context).getSubtotal(),
            serviceCharge: Provider.of<CartProvider>(context).serviceChargeAmount,
            totalPrice: Provider.of<CartProvider>(context).getTotalPrice(),
          ),
        ],
      ),
    );
  }
}
