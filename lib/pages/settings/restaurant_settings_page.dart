import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snapmeal/pages/components/constants.dart';
import 'package:snapmeal/pages/manage_item/formatter.dart';
import 'package:snapmeal/providers/restaurant_provider.dart';

class RestaurantSettingsPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  RestaurantSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RestaurantProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Restaurant Info'),
          centerTitle: true,
          foregroundColor: Colors.blueGrey,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<RestaurantProvider>(
            builder: (context, provider, child) {
              return provider.isLoading ? _buildLoadingIndicator() : _buildSettingsForm(provider, context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildSettingsForm(RestaurantProvider provider, BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Restaurant Name
            TextFormField(
              controller: provider.nameController,
              decoration: InputDecoration(
                labelText: 'Restaurant Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the restaurant name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),

            // Service Charge
            TextFormField(
              controller: provider.serviceChargeController,
              decoration: InputDecoration(
                labelText: 'Service Charge (%)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the service charge';
                }
                return null;
              },
            ),
            const SizedBox(height: 20.0),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor: secColor,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, MediaQuery.of(context).size.height * 0.07),
                  ),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  provider.saveSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
