import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:borrow_my_driveway/common/custom_button.dart';
import 'package:borrow_my_driveway/common/custom_textfield.dart';
import 'package:borrow_my_driveway/constants.dart';
import 'package:borrow_my_driveway/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class EditDrivewayScreen extends StatefulWidget {
  final models.Document drivewayDocument;
  const EditDrivewayScreen({super.key, required this.drivewayDocument});

  @override
  State<EditDrivewayScreen> createState() => _EditDrivewayScreenState();
}

class _EditDrivewayScreenState extends State<EditDrivewayScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _houseNameController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  bool _isLoading = false;
  String _priceType = 'per day';

  final Databases _databases = getIt<Databases>();

  @override
  void initState() {
    super.initState();
    // Pre-fill the form fields with the existing data, with null safety
    final data = widget.drivewayDocument.data;
    _houseNameController.text = data['houseName'] ?? '';
    _streetController.text = data['street'] ?? '';
    _cityController.text = data['city'] ?? '';
    _postcodeController.text = data['postcode'] ?? '';
    _countryController.text = data['country'] ?? '';
    // Use the 'priceAmount' field to correctly populate the price
    _priceController.text = data['priceAmount'] ?? '';
    _priceType = data['priceType'] ?? 'per day';
    _commentsController.text = data['comments'] ?? '';
  }

  void _updateDriveway() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final fullAddress = '${_houseNameController.text}, ${_streetController.text}, ${_cityController.text}, ${_postcodeController.text}, ${_countryController.text}';
        final fullPrice = '${_priceController.text}/$_priceType';

        await _databases.updateDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.drivewaysCollectionId,
          documentId: widget.drivewayDocument.$id,
          data: {
            'houseName': _houseNameController.text,
            'street': _streetController.text,
            'city': _cityController.text,
            'postcode': _postcodeController.text,
            'country': _countryController.text,
            'address': fullAddress,
            'price': fullPrice,
            'priceAmount': _priceController.text,
            'priceType': _priceType,
            'comments': _commentsController.text,
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driveway updated successfully!')),
        );
        Navigator.pop(context, true); // Return true to signal a refresh
      } on AppwriteException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to update driveway.')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _deleteDriveway() async {
    // Show a confirmation dialog before deleting
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('Are you sure you want to delete this driveway listing? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _databases.deleteDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.drivewaysCollectionId,
          documentId: widget.drivewayDocument.$id,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driveway deleted successfully!')),
        );
        Navigator.pop(context, true); // Return true to signal a refresh
      } on AppwriteException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to delete driveway.')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Your Driveway')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form fields are the same as the list driveway screen
              CustomTextField(controller: _houseNameController, hintText: 'House Name or Number', validator: RequiredValidator(errorText: 'This field is required')),
              const SizedBox(height: 16),
              CustomTextField(controller: _streetController, hintText: 'Street', validator: RequiredValidator(errorText: 'Street is required')),
              const SizedBox(height: 16),
              CustomTextField(controller: _cityController, hintText: 'City', validator: RequiredValidator(errorText: 'City is required')),
              const SizedBox(height: 16),
              CustomTextField(controller: _postcodeController, hintText: 'Postcode', validator: RequiredValidator(errorText: 'Postcode is required')),
              const SizedBox(height: 16),
              CustomTextField(controller: _countryController, hintText: 'Country', validator: RequiredValidator(errorText: 'Country is required')),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: CustomTextField(controller: _priceController, hintText: 'Price', keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: RequiredValidator(errorText: 'Price is required'))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _priceType,
                      decoration: InputDecoration(enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[200]),
                      items: <String>['per hour', 'per day'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                      onChanged: (String? newValue) => setState(() => _priceType = newValue!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _commentsController,
                maxLines: 4,
                decoration: InputDecoration(hintText: 'e.g: Driveway\'s gate is closed, please call me to open the gate', alignLabelWithHint: true, labelText: 'Any comments', enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)), focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[200]),
              ),
              const SizedBox(height: 24),
              // Note: Image editing is not included in this step for simplicity.
              CustomButton(
                onPressed: _updateDriveway,
                text: 'Update Details',
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : _deleteDriveway,
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16)
                ),
                child: const Text('Delete Listing'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
