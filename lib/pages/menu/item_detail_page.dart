import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/models/item.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/providers/cart_provider.dart';

class ItemDetailPage extends StatefulWidget {
  final Item item;

  const ItemDetailPage({super.key, required this.item});

  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  String? _selectedOption;

  @override
  void initState() {
    _selectedOption = widget.item.options.isNotEmpty ? widget.item.options[0] : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Detail'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Image
            widget.item.image.isNotEmpty
              ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.item.image,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                )
              : const Icon(
                Icons.image,
                size: 200,
                ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Name
                Expanded(
                  child: Text(
                    widget.item.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Price
                Text(
                  'RM${widget.item.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, color: Colors.blueGrey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            widget.item.description.isNotEmpty
              ? Text(
                widget.item.description,
                style: const TextStyle(fontSize: 16),
              )
              : const Text(
                'None',
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 10),

            // Options
            if (widget.item.options.isNotEmpty && widget.item.options[0].isNotEmpty) ...[
              const Text(
              'Options',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...widget.item.options.map((option) {
              return Row(
                children: [
                Radio<String>(
                  value: option,
                  groupValue: _selectedOption,
                  onChanged: (String? value) {
                  setState(() {
                    _selectedOption = value;
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
            const SizedBox(height: 10),

            // // Availability
            // Row(
            //   children: [
            //     const Text(
            //       'Availability: ',
            //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //     ),
            //     Text(
            //       widget.item.availability ? 'Available' : 'Not Available',
            //       style: TextStyle(
            //         fontSize: 16,
            //         color: widget.item.availability ? Colors.green : Colors.red,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 10),

            // Add to Cart Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor: secColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.07),
                  ),
              onPressed: widget.item.availability && _selectedOption != null
                  ? () {
                      cartProvider.addToCart(widget.item, _selectedOption!, 1, null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.item.name} added to cart'),
                        ),
                      );
                    }
                  : null,
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
