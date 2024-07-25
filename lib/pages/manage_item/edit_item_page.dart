import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/pages/manage_item/formatter.dart';
import 'package:snapmeal/providers/item_provider.dart';
import 'package:snapmeal/models/item.dart';

class EditItemPage extends StatefulWidget {
  final Item item;

  const EditItemPage({super.key, required this.item});

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  bool _availability = true;
  File? _image;
  bool _isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item.name;
    _descriptionController.text = widget.item.description;
    _priceController.text = widget.item.price.toString();
    _availability = widget.item.availability;
    for (String option in widget.item.options) {
      _optionControllers.add(TextEditingController(text: option));
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
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
              _buildTextFormField(
                controller: _priceController,
                labelText: 'Price',
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

  Widget _buildImagePicker(BuildContext context) {
    return Column(
      children: [
        _image == null
            ? widget.item.image.isEmpty
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
                    child: Image.network(
                      widget.item.image,
                      height: 200,
                      fit: BoxFit.cover,
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
                    Text('Updating item...'),
                  ],
                ),
              );
            },
          );

          try {
            String imageUrl = widget.item.image;
            if (_image != null) {
              imageUrl = await itemProvider.uploadImage(_image!);
            }

            List<String> options = _optionControllers.map((controller) => controller.text.trim()).toList();

            final updatedItem = Item(
              id: widget.item.id,
              image: imageUrl,
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: double.parse(_priceController.text.trim()),
              options: options,
              availability: _availability,
              category: widget.item.category,
              labelId: widget.item.labelId,
            );

            await itemProvider.updateItem(updatedItem);
            Navigator.of(context).pop(); // Close the loading dialog
            Navigator.of(context).pop(); // Go back to the previous page
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating item: $e')),
            );
          } finally {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      child: const Text('Save'),
    );
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    });
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
