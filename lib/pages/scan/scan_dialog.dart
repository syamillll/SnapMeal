import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/models/item.dart';
import 'package:snapmeal/providers/cart_provider.dart';

class ScanDialog extends StatefulWidget {
  final Item item;
  final int quantity;
  final File? image;

  const ScanDialog({required this.item, required this.quantity, required this.image, super.key});

  @override
  _ScanDialogState createState() => _ScanDialogState();
}

class _ScanDialogState extends State<ScanDialog> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Option'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.item.options.map((option) {
            return Row(
              children: [
                Radio<String>(
                  value: option,
                  groupValue: selectedOption,
                  onChanged: (String? value) {
                    setState(() {
                      selectedOption = value;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    option,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedOption != null
              ? () {
                  final cartProvider = Provider.of<CartProvider>(context, listen: false);
                  cartProvider.addToCart(widget.item, selectedOption!, widget.quantity, widget.image);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Item added: ${widget.item.name}, Option: $selectedOption')),
                  );
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Add to Cart'),
        ),
      ],
    );
  }
}
