import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/providers/category_provider.dart';

class AddCategoryModal extends StatefulWidget {
  const AddCategoryModal({super.key});

  @override
  _AddCategoryModalState createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

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
              'Create New Category',
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

            // Add Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor: secColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.07),
                  ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  categoryProvider.addCategory(_nameController.text);
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
