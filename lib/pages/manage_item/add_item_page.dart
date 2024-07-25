import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/pages/manage_item/calculator_dialog.dart';
import 'package:snapmeal/pages/manage_item/formatter.dart';
import 'package:snapmeal/pages/manage_item/item_list_page.dart';
import 'package:snapmeal/providers/category_provider.dart';
import 'package:snapmeal/providers/item_provider.dart';
import 'package:snapmeal/models/item.dart';

class AddItemPage extends StatefulWidget {
  final String categoryId;

  const AddItemPage({super.key, required this.categoryId});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  late String _selectedCategory;
  bool _availability = true;
  File? _image;
  String? labelId;
  bool _isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.categoryId;
    _tfLteInit();
    _addOption();
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final itemProvider = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              _buildCategoryDropdown(categoryProvider),
              const SizedBox(height: 20),
              _buildImagePicker(context),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) => _validateNotEmpty(value, 'Please enter a name'),
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _descriptionController,
                labelText: 'Description (Optional)',
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 20),
              _buildPriceField(
                context: context,
                controller: _priceController,
                labelText: 'Price (RM)',
                keyboardType: TextInputType.number,
                inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                validator: (value) => _validatePrice(value),
              ),
              const SizedBox(height: 20),
              _buildOptionsFields(),
              const SizedBox(height: 20),
              _buildAvailabilitySwitch(),
              const SizedBox(height: 20),
              _buildSubmitButton(context, itemProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(CategoryProvider categoryProvider) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: categoryProvider.categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Column(
      children: [
        _image == null
            ? Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'No Image Selected',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _image!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: _getImageFromCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Picture'),
            ),
            ElevatedButton.icon(
              onPressed: _getImageFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Upload Image'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    int? maxLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildPriceField({
    required TextEditingController controller,
    required String labelText,
    required TextInputType keyboardType,
    required List<TextInputFormatter> inputFormatters,
    required String? Function(String?) validator,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            ),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calculate),
          onPressed: () async {
            final result = await showDialog<double>(
              context: context,
              builder: (context) => const CalculatorDialog(),
            );
            if (result != null) {
              controller.text = result.toStringAsFixed(2);
            }
          },
        ),
      ],
    );
  }

  Widget _buildOptionsFields() {
    return Column(
      children: [
        ..._optionControllers.asMap().entries.map((entry) {
          int index = entry.key;
          TextEditingController controller = entry.value;
            return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
              Expanded(
                child: _buildTextFormField(
                controller: controller,
                labelText: 'Option ${index + 1} (Optional)',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => _removeOption(index),
              ),
              ],
            ),
            );
        }),
        TextButton(
          onPressed: _addOption,
          child: const Text('Add More Option'),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Availability', textAlign: TextAlign.left),
        Switch(
          value: _availability,
          onChanged: (value) {
            setState(() {
              _availability = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ItemProvider itemProvider) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
                    backgroundColor: secColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.07),
                  ),
      onPressed: _isLoading ? null : () async {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _isLoading = true;
          });

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Saving item...'),
                  ],
                ),
              );
            },
          );

          try {
            String imageUrl = '';
            if (_image != null) {
              imageUrl = await itemProvider.uploadImage(_image!);
            }

            List<String> options = _optionControllers.map((controller) => controller.text.trim()).toList();

            final newItem = Item(
              id: '',
              image: imageUrl,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: double.parse(_priceController.text.trim()),
              options: options,
              availability: _availability,
              category: _selectedCategory,
              labelId: labelId,
            );

            await itemProvider.addItem(newItem);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => ItemListPage(categoryId: _selectedCategory),
              ),
              ModalRoute.withName('/manage_menu'),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding item: $e')),
            );
          } finally {
            setState(() {
              _isLoading = false;
            });
            Navigator.of(context).pop(); // Close the loading dialog
          }
        }
      },
      child: const Text('Save'),
    );
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

  Future<void> _getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _detectItem(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    });
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _detectItem(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    });
  }

  Future<void> _detectItem(String imagePath) async {
    final itemProvider = Provider.of<ItemProvider>(context, listen: false);

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
        final String itemLabel = parts.sublist(1).join(' ');
        bool labelExists = itemProvider.isItemExists(labelId!);
        if (!labelExists) {
          _itemDetectionDialog(context, itemLabel);
        } else {
          labelId = null;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item with this label already exists')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal is not detected')),
        );
      }
    });
  }

  void _itemDetectionDialog(BuildContext context, String itemLabel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Meal Detection Result'),
          content: Text('The image is picture of a $itemLabel?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                labelId = null;
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                _nameController.text = itemLabel;
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _addOption() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  void _removeOption(int index) {
    setState(() {
      if (_optionControllers.length > 1) {
        _optionControllers[index].dispose();
        _optionControllers.removeAt(index);
      }
    });
  }

  String? _validateNotEmpty(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }
}
