import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:snapmeal/models/cart_item.dart';
import 'package:snapmeal/models/item.dart';
import 'package:snapmeal/pages/invoice/invoice_details.dart';

class InvoicePage extends StatelessWidget {
  final String invoiceId;

  const InvoicePage({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Invoice')),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveAsPDF(context),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchInvoiceData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Invoice not found'));
          }

          var invoiceData = snapshot.data!.data() as Map<String, dynamic>;
          List<CartItem> cartItems = (invoiceData['items'] as List)
              .map((itemData) => CartItem.fromMap(itemData))
              .toList();
          double subtotal = invoiceData['subtotal'];
          double serviceCharge = invoiceData['serviceCharge'];
          double total = invoiceData['total'];

          DateTime dateTime = (invoiceData['dateTime'] as Timestamp).toDate();
          String formattedDateTime = DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);

          return SingleChildScrollView(
            child: InvoiceDetails(
              invoiceData: invoiceData,
              cartItems: cartItems,
              subtotal: subtotal,
              serviceCharge: serviceCharge,
              total: total,
              formattedDateTime: formattedDateTime,
            ),
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> _fetchInvoiceData() {
    return FirebaseFirestore.instance.collection('invoices').doc(invoiceId).get();
  }

  Future<void> _saveAsPDF(BuildContext context) async {
    final pdf = pw.Document();
    DocumentSnapshot snapshot = await _fetchInvoiceData();
    var invoiceData = snapshot.data() as Map<String, dynamic>;
    List<CartItem> cartItems = (invoiceData['items'] as List)
        .map((itemData) => CartItem.fromMap(itemData))
        .toList();
    double subtotal = invoiceData['subtotal'];
    double serviceCharge = invoiceData['serviceCharge'];
    double total = invoiceData['total'];

    DateTime dateTime = (invoiceData['dateTime'] as Timestamp).toDate();
    String formattedDateTime = DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);

    // Fetch all item details
    Map<String, String> itemNames = await _fetchItemNames(cartItems);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(invoiceData['restaurantName'], style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Text('Table Number: ${invoiceData['tableNumber']}', style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Date: $formattedDateTime', style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20.0),
              _buildInvoiceTable(cartItems, itemNames),
              pw.SizedBox(height: 20.0),
              _buildTotalSection(subtotal, serviceCharge, total),
            ],
          );
        },
      ),
    );

    final file = await _savePDFToFile(pdf);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invoice saved as PDF: ${file.path}')));
    await OpenFile.open(file.path);
  }

  Future<Map<String, String>> _fetchItemNames(List<CartItem> cartItems) async {
    Map<String, String> itemNames = {};
    for (var cartItem in cartItems) {
      DocumentSnapshot itemSnapshot = await FirebaseFirestore.instance.collection('items').doc(cartItem.itemId).get();
      Item item = Item.fromDocumentSnapshot(itemSnapshot);
      itemNames[cartItem.itemId] = item.name;
    }
    return itemNames;
  }

  pw.Table _buildInvoiceTable(List<CartItem> cartItems, Map<String, String> itemNames) {
    return pw.Table(
      border: const pw.TableBorder(
        bottom: pw.BorderSide(color: PdfColors.grey),
        horizontalInside: pw.BorderSide(color: PdfColors.grey),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Item', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Qty', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text('Price (RM)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
            ),
          ],
        ),
        ...cartItems.map((cartItem) {
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(itemNames[cartItem.itemId] ?? 'Unknown Item', style: const pw.TextStyle(fontSize: 16)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(cartItem.quantity.toString(), style: const pw.TextStyle(fontSize: 16)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text((cartItem.price * cartItem.quantity).toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 16)),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTotalSection(double subtotal, double serviceCharge, double total) {
    return pw.Align(
      alignment: pw.Alignment.bottomRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('Subtotal: RM${subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Service Tax (%): ${serviceCharge.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
          pw.Text('Total: RM${total.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  Future<File> _savePDFToFile(pw.Document pdf) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/invoice_$invoiceId.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
