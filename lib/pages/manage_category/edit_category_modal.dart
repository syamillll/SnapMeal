import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/providers/category_provider.dart';

class EditCategoryModal extends StatefulWidget {
  final String categoryId;
  final String initialCategoryName;

  const EditCategoryModal({super.key, required this.categoryId, required this.initialCategoryName});

  @override
  _EditCategoryModalState createState() => _EditCategoryModalState();
}

class _EditCategoryModalState extends State<EditCategoryModal> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialCategoryName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Get the category provider
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page Title
            const Text(
              'Edit Category',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            
            // Category Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Category name cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor: secColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.07),
                  ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  categoryProvider.updateCategory(widget.categoryId, _nameController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}
