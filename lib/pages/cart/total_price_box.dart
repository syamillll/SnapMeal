import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/pages/invoice/invoice_page.dart';
import 'package:snapmeal/providers/auth_service.dart';
import 'package:snapmeal/providers/cart_provider.dart';

class TotalPriceBox extends StatelessWidget {
  const TotalPriceBox({
    super.key,
    required this.subtotal,
    required this.serviceCharge,
    required this.totalPrice,
  });

  final double subtotal;
  final double serviceCharge;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isVerified = authService.isVerified;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Subtotal: RM${subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            'Service Tax (%): ${serviceCharge.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            'Total: RM${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Expanded(
              //   child: ElevatedButton(
              //     onPressed: onClearAll,
              //     child: const Text('Clear All'),
              //   ),
              // ),
              // const SizedBox(width: 8), 
              if (isVerified) // Conditionally render the button based on verification status
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _generateInvoice(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secColor,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.07),
                    ),
                    child: const Text('Generate Invoice'),
                  ),
                  
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _generateInvoice(BuildContext context) async {
    TextEditingController tableNumberController = TextEditingController();
    String? tableNumber = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Table Number'),
            content: TextFormField(
            controller: tableNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Table Number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(tableNumberController.text);
              },
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );

    if (tableNumber != null && tableNumber.isNotEmpty) {
      // Fetch restaurant details
      DocumentSnapshot restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc('restaurant_id')
          .get();
      String restaurantName = restaurantDoc['name'];

      // Save the invoice to Firestore
      CartProvider cartProvider =
          Provider.of<CartProvider>(context, listen: false);
      await cartProvider.saveInvoice(restaurantName, tableNumber);

      // Navigate to the invoice page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InvoicePage(invoiceId: cartProvider.invoiceId),
        ),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Table number is required'),
        ),
      );
    }
  }
}
