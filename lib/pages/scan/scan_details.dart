import 'package:flutter/material.dart';

class ScanDetails extends StatelessWidget {
  final String? itemLabel;
  final String? itemPrice;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const ScanDetails({
    required this.itemLabel,
    required this.itemPrice,
    required this.quantity,
    required this.onQuantityChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            itemLabel ?? 'No Item Detected',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          itemPrice != null ? 'RM $itemPrice' : '',
          style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (quantity > 1) onQuantityChanged(quantity - 1);
              },
            ),
            Text(
              '$quantity',
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                onQuantityChanged(quantity + 1);
              },
            ),
          ],
        ),
      ],
    );
  }
}
