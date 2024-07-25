import 'package:flutter/material.dart';
import 'package:snapmeal/models/cart_item.dart';
import 'package:snapmeal/pages/invoice/invoice_table.dart';
import 'package:snapmeal/pages/invoice/invoice_total.dart';

class InvoiceDetails extends StatelessWidget {
  final Map<String, dynamic> invoiceData;
  final List<CartItem> cartItems;
  final double subtotal;
  final double serviceCharge;
  final double total;
  final String formattedDateTime;

  const InvoiceDetails({super.key, 
    required this.invoiceData,
    required this.cartItems,
    required this.subtotal,
    required this.serviceCharge,
    required this.total,
    required this.formattedDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${invoiceData['restaurantName']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Table No: ${invoiceData['tableNumber']}', style: const TextStyle(fontSize: 16)),
          Text('Date: $formattedDateTime', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20.0),
          InvoiceTable(cartItems: cartItems),
          const SizedBox(height: 20.0),
          InvoiceTotal(subtotal: subtotal, serviceCharge: serviceCharge, total: total),
        ],
      ),
    );
  }
}
