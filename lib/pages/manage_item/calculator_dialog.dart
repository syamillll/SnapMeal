import 'package:flutter/material.dart';
import 'package:snapmeal/pages/manage_item/formatter.dart';

class CalculatorDialog extends StatefulWidget {
  const CalculatorDialog({super.key});

  @override
  _CalculatorDialogState createState() => _CalculatorDialogState();
}

class _CalculatorDialogState extends State<CalculatorDialog> {
  final TextEditingController _costPriceController = TextEditingController();
  final TextEditingController _markupController = TextEditingController();
  double? _sellingPrice;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Calculate Selling Price', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 6),

          TextFormField(
            controller: _costPriceController,
            decoration: InputDecoration(
              labelText: 'Cost Price (RM)',
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              )
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _markupController,
            decoration: InputDecoration(
              labelText: 'Markup (%)',
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              )
            ),
            keyboardType: TextInputType.number,
          ),

        ],
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
            final costPrice = double.tryParse(_costPriceController.text) ?? 0.0;
            final markup = double.tryParse(_markupController.text) ?? 0.0;
            setState(() {
              _sellingPrice = costPrice + (costPrice * markup / 100);
            });
            Navigator.of(context).pop(_sellingPrice);
          },
          child: const Text('Calculate'),
        ),
        
      ],
    );
  }
}
