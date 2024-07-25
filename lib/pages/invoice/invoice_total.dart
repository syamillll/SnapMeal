import 'package:flutter/material.dart';

class InvoiceTotal extends StatelessWidget {
  final double subtotal;
  final double serviceCharge;
  final double total;

  const InvoiceTotal({super.key, required this.subtotal, required this.serviceCharge, required this.total});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Subtotal: RM${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
          Text('Service Tax (%): ${serviceCharge.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
          Text('Total: RM${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
