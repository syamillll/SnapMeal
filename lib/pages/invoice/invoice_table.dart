import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/models/cart_item.dart';
import 'package:snapmeal/models/item.dart';
import 'package:snapmeal/providers/cart_provider.dart';

class InvoiceTable extends StatelessWidget {
  final List<CartItem> cartItems;

  const InvoiceTable({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Table(
      border: const TableBorder(
        bottom: BorderSide(color: Colors.grey),
        horizontalInside: BorderSide(color: Colors.grey),
      ),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
      },
      children: [
        const TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Price (RM)', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right),
              ),
            ),
          ],
        ),
        ...cartItems.map((cartItem) => TableRow(
          children: [
            TableCell(
              child: FutureBuilder<Item?>(
                future: Provider.of<CartProvider>(context, listen: false).fetchItem(cartItem.itemId),
                builder: (context, itemSnapshot) {
                  if (itemSnapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (itemSnapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Error: ${itemSnapshot.error}'),
                    );
                  }
                  if (!itemSnapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Item not found'),
                    );
                  }

                  var item = itemSnapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(item.name),
                  );
                },
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(cartItem.quantity.toString()),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  (cartItem.price * cartItem.quantity).toStringAsFixed(2),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }
}
