import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/appwrite_client.dart';

class ListDrivewayScreen extends StatefulWidget {
  const ListDrivewayScreen({super.key});
  @override
  State<ListDrivewayScreen> createState() => _ListDrivewayScreenState();
}

class _ListDrivewayScreenState extends State<ListDrivewayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _image;
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() { _image = File(pickedFile.path); });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image.')),
      );
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final appwriteClient = context.read<AppwriteClient>();
      final user = appwriteClient.user;
      if (user == null) throw Exception("User not logged in");

      // 1. Upload image to Appwrite Storage
      final file = await appwriteClient.storage.createFile(
        bucketId: AppwriteClient.storageBucketId,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: _image!.path, filename: _image!.path.split('/').last),
      );

      // 2. Get the public URL for the image
      final imageUrl = '${AppwriteClient.endpoint}/storage/buckets/${AppwriteClient.storageBucketId}/files/${file.$id}/view?project=${AppwriteClient.projectId}';

      // 3. Save driveway details to Appwrite Database
      await appwriteClient.databases.createDocument(
        databaseId: AppwriteClient.databaseId,
        collectionId: AppwriteClient.drivewaysCollectionId,
        documentId: ID.unique(),
        data: {
          'ownerId': user.$id,
          'address': _addressController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': _priceController.text.trim(), // **UPDATED LOGIC**: Save as a string
          'imageUrl': imageUrl,
        },
        permissions: [
          Permission.read(Role.any()), // Anyone can view
          Permission.update(Role.user(user.$id)), // Only creator can update
          Permission.delete(Role.user(user.$id)), // Only creator can delete
        ],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driveway listed successfully!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to list driveway: $e')));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // ... build method is identical to the Firebase version
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Your Driveway'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(12)),
                child: _image == null
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _pickImage, child: const Text('Select Image')),
                    ],
                  ),
                )
                    : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity)),
              ),
              if (_image != null) TextButton(onPressed: _pickImage, child: const Text('Change Image')),
              const SizedBox(height: 24),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Full Address'), validator: (value) => value!.isEmpty ? 'Please enter an address' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price per Hour (£)'), validator: (value) => value!.isEmpty ? 'Please enter a price' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Short Description (optional)'), maxLines: 3),
              const SizedBox(height: 32),
              _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submitForm, child: const Text('List My Driveway')),
            ],
          ),
        ),
      ),
    );
  }
}