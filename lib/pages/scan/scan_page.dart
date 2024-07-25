import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/pages/components/drawer_menu.dart';
import 'package:snapmeal/pages/scan/image_selector.dart';
import 'package:snapmeal/pages/scan/scan_details.dart';
import 'package:snapmeal/pages/scan/scan_dialog.dart';
import 'package:snapmeal/providers/cart_provider.dart';
import 'package:snapmeal/providers/item_provider.dart';
import 'package:snapmeal/models/item.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  File? _image;
  String? labelId;
  String? itemLabel;
  String? itemPrice;
  int quantity = 1; // Quantity counter
  late ItemProvider itemProvider;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tfLteInit();
  }

  Future<void> _tfLteInit() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
  }

  Future<void> _detectItem(String imagePath) async {
    var detections = await Tflite.runModelOnImage(
      path: imagePath,
      imageMean: 117.0,
      imageStd: 255.0,
      numResults: 2,
      threshold: 0.2,
      asynch: true,
    );

    setState(() {
      if (detections != null && detections.isNotEmpty) {
        final String result = detections[0]['label'].toString();
        final List<String> parts = result.split(' ');
        labelId = parts[0];
        itemLabel = parts.sublist(1).join(' ');
        _fetchItemPriceByLabelId(labelId!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal is not detected')),
        );
      }
    });
  }

  Future<void> _fetchItemPriceByLabelId(String labelId) async {
    try {
      final itemFromImage = itemProvider.items.firstWhere((item) => item.labelId == labelId);
      setState(() {
        itemPrice = itemFromImage.price.toStringAsFixed(2);
      });
    } catch (e) {
      setState(() {
        itemPrice = null;
      });
    }
  }

  Future<Item?> _fetchItemByLabelId(String labelId) async {
    final itemProvider = Provider.of<ItemProvider>
                          (context, listen: false);
    return itemProvider.items.firstWhere((item) 
                              => item.labelId == labelId);
  }

  void _showItemOptionsDialog(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScanDialog(
          item: item,
          quantity: quantity,
          image: _image,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    itemProvider = Provider.of<ItemProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Image'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.black54),
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ImageSelector(
              image: _image,
              onImagePicked: (File? pickedImage) {
                setState(() {
                  _image = pickedImage;
                  if (pickedImage != null) {
                    _detectItem(pickedImage.path);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            ScanDetails(
              itemLabel: itemLabel,
              itemPrice: itemPrice,
              quantity: quantity,
              onQuantityChanged: (int newQuantity) {
                setState(() {
                  quantity = newQuantity;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.07),
              ),
              onPressed: () async {
                if (labelId != null) {
                  try {
                    Item? item = await _fetchItemByLabelId(labelId!);
                    
                    // Show dialog if item has options
                    if (item!.options.isNotEmpty && item.options[0].isNotEmpty) {
                      _showItemOptionsDialog(item);
                    }
                    else {
                      final cartProvider = Provider.of<CartProvider>(context, listen: false);
                      cartProvider.addToCart(item, '', quantity, _image);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Item added: ${item.name}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item not found')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No item detected')),
                  );
                }
              },
              child: const Text('Add to Cart'),
            ),
          ],
        ),
      ),
    );
  }
}
