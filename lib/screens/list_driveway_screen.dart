import 'dart:io';
import 'package:appwrite/appwrite.dart';
import 'package:borrow_my_driveway/common/custom_button.dart';
import 'package:borrow_my_driveway/common/custom_textfield.dart';
import 'package:borrow_my_driveway/constants.dart';
import 'package:borrow_my_driveway/providers/auth_provider.dart';
import 'package:borrow_my_driveway/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ListDrivewayScreen extends StatefulWidget {
  const ListDrivewayScreen({super.key});

  @override
  State<ListDrivewayScreen> createState() => _ListDrivewayScreenState();
}

class _ListDrivewayScreenState extends State<ListDrivewayScreen> {
  final _formKey = GlobalKey<FormState>();
  // New controllers for the detailed address
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  File? _image;
  bool _isLoading = false;
  String _priceType = 'per day'; // Default price type

  final Databases _databases = getIt<Databases>();
  final Storage _storage = getIt<Storage>();

  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitDriveway() async {
    // Get the current user's ID from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ownerId = authProvider.user?.$id;

    if (ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in.')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _image != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final uploadedFile = await _storage.createFile(
          bucketId: AppwriteConstants.storageBucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: _image!.path, filename: '${ID.unique()}.jpg'),
        );

        final imageUrl = '${AppwriteConstants.endpoint}/storage/buckets/${AppwriteConstants.storageBucketId}/files/${uploadedFile.$id}/view?project=${AppwriteConstants.projectId}';

        // Combine address fields for a full address string
        final fullAddress = '${_houseNameController.text}, ${_streetController.text}, ${_cityController.text}, ${_postcodeController.text}, ${_countryController.text}';
        final fullPrice = ' ${_priceController.text} $_priceType';

        await _databases.createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.drivewaysCollectionId,
          documentId: ID.unique(),
          data: {
            // Add the ownerId
            'ownerId': ownerId,
            // Store individual address components
            'houseName': _houseNameController.text,
            'street': _streetController.text,
            'city': _cityController.text,
            'postcode': _postcodeController.text,
            'country': _countryController.text,
            // Store the combined address for easy display
            'address': fullAddress,
            // Store price details
            'price': fullPrice,
            'priceType': _priceType,
            // Store comments and image URL
            'comments': _commentsController.text,
            'imageUrl': imageUrl,
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driveway listed successfully!')),
        );
        Navigator.pop(context, true);
      } on AppwriteException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to list driveway.')),
        );
      } finally {
        if(mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image for the driveway.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Your Driveway')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Address Fields
              CustomTextField(
                controller: _houseNameController,
                hintText: 'House Name or Number',
                validator: RequiredValidator(errorText: 'This field is required').call,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _streetController,
                hintText: 'Street',
                validator: RequiredValidator(errorText: 'Street is required').call,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cityController,
                hintText: 'City',
                validator: RequiredValidator(errorText: 'City is required').call,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _postcodeController,
                hintText: 'Postcode',
                validator: RequiredValidator(errorText: 'Postcode is required').call,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _countryController,
                hintText: 'Country',
                validator: RequiredValidator(errorText: 'Country is required').call,
              ),
              const SizedBox(height: 24),

              // Price Fields
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      hintText: 'Price',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: RequiredValidator(errorText: 'Price is required').call,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priceType,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      items: <String>['per hour', 'per day']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _priceType = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Comments Field
              TextFormField(
                controller: _commentsController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'e.g: Driveway\'s gate is closed, please call me to open the gate',
                  alignLabelWithHint: true,
                  labelText: 'Any comments',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              const SizedBox(height: 24),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.grey[200],
                  ),
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                  )
                      : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: Colors.black54), SizedBox(height: 8), Text('Tap to select an image', style: TextStyle(color: Colors.black54))])),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: _submitDriveway,
                text: 'List Driveway',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
