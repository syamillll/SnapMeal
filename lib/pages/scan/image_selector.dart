import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelector extends StatelessWidget {
  final File? image;
  final Function(File?) onImagePicked;

  ImageSelector({required this.image, required this.onImagePicked, super.key});

  final picker = ImagePicker();

  Future<void> _getImageFromCamera(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    onImagePicked(pickedFile != null ? File(pickedFile.path) : null);
  }

  Future<void> _getImageFromGallery(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    onImagePicked(pickedFile != null ? File(pickedFile.path) : null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        image == null
            ? Container(
                height: MediaQuery.of(context).size.height * 0.3,
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
                  image!,
                  height: MediaQuery.of(context).size.height * 0.3,
                  fit: BoxFit.cover,
                ),
              ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () => _getImageFromCamera(context),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Take Picture'),
            ),
            ElevatedButton.icon(
              onPressed: () => _getImageFromGallery(context),
              icon: const Icon(Icons.photo_library),
              label: const Text('Upload Image'),
            ),
          ],
        ),
      ],
    );
  }
}
