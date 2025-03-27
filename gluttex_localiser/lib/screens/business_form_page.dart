import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_localiser/components/category_picker.dart';
import 'package:gluttex_localiser/components/image_picker.dart';
import 'package:gluttex_localiser/components/map_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locator/locator.dart';
import 'package:gluttex_core/app/Response.dart';

class SupplierFormScreen extends StatefulWidget {
  const SupplierFormScreen({super.key});

  @override
  _SupplierFormScreenState createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  // Form state variables
  int? _idprovider_details_id;
  int? _id_product_provider;
  int? _product_provider_details_id;
  String? _provider_name;
  String? _provider_contact_info = "";
  int? _product_provider_type_id;
  double? _location_latitude;
  double? _location_longitude;
  String? _location_name;
  Uint8List? _supplierImage;
  LatLng? _position;

  // Dynamic contact fields
  final List<TextEditingController> _contactControllers = [];
  final List<FocusNode> _contactFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _addContactField(); // Start with one contact field
  }

  @override
  void dispose() {
    for (var controller in _contactControllers) {
      controller.dispose();
    }
    for (var node in _contactFocusNodes) {
      node.dispose();
    }
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addContactField() {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    setState(() {
      _contactControllers.add(controller);
      _contactFocusNodes.add(focusNode);
    });
  }

  void _removeContactField(int index) {
    setState(() {
      _contactControllers.removeAt(index);
      _contactFocusNodes.removeAt(index).dispose();
    });
  }

  void _onCategoryChanged(int identifier) {
    setState(() {
      _product_provider_type_id = identifier;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Concatenate contact info fields
      _provider_contact_info = _contactControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => controller.text)
          .join(',');

      final supplier = Supplier(
        idProviderDetails: _idprovider_details_id ?? 0,
        idProductProvider: _id_product_provider ?? 0,
        productProviderDetailsId: _product_provider_details_id ?? 0,
        productProviderTypeId: _product_provider_type_id ?? 1,
        providerName: _provider_name ?? "",
        providerContactInfo: _provider_contact_info ?? "",
        locationLatitude: _location_latitude ?? 0.0,
        locationLongitude: _location_longitude ?? 0.0,
        locationName: _location_name ?? "",
      );

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(AppLocalizations.of(context)!.processingRequest),
            ],
          ),
          duration:
              const Duration(minutes: 1), // Long duration for async operation
        ),
      );

      try {
        final result =
            await GluttexLocator.get<SupplierService>().addSupplier(supplier);

        // Hide loading indicator
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        final response = Response();
        switch (result) {
          case 200:
            response.color = Colors.green;
            response.text = AppLocalizations.of(context)!.putSuccess;
            break;
          case 406:
          case 422:
            response.color = Colors.amber;
            response.text = AppLocalizations.of(context)!.putFailure;
            break;
          default:
            response.color = Colors.red;
            response.text = AppLocalizations.of(context)!.serverError;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.text),
            backgroundColor: response.color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        if (result == 200) {
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.of(context).pop();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.addSupplierTxt),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
            tooltip: localizations.save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Supplier Image Section
              _buildImageSection(context),
              const SizedBox(height: 24),

              // Basic Information Section
              _buildSectionHeader(localizations.basicInformation),
              _buildTextField(
                context,
                label: localizations.supplierNameMsg,
                icon: Icons.business,
                onSaved: (value) => _provider_name = value,
                validator: (value) => value?.isEmpty ?? true
                    ? localizations.addBusinessNameMsg
                    : null,
              ),
              const SizedBox(height: 16),

              // Category Picker
              _buildCategoryPicker(context),
              const SizedBox(height: 24),

              // Location Information Section
              _buildSectionHeader(localizations.locationInformation),
              _buildTextField(
                context,
                label: localizations.locationNameText,
                icon: Icons.place,
                onSaved: (value) => _location_name = value,
                validator: (value) => value?.isEmpty ?? true
                    ? localizations.pleaseInputLocationNameMsg
                    : null,
              ),
              const SizedBox(height: 16),
              _buildLocationPicker(context),
              const SizedBox(height: 24),

              // Contact Information Section
              _buildSectionHeader(localizations.contactInformation),
              ..._buildContactFields(context),
              _buildAddContactButton(context),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  localizations.saveSupplier,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              _supplierImage != null ? MemoryImage(_supplierImage!) : null,
          child: _supplierImage == null
              ? const Icon(Icons.store, size: 50, color: Colors.grey)
              : null,
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: Text(AppLocalizations.of(context)!.pickImageMsg),
          onPressed: () async {
            final pickedImage = await pickImage();
            if (pickedImage != null) {
              setState(() => _supplierImage = pickedImage);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCategoryPicker(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final categories = localizations.providerCategoryTextList.split(",");

    if (categories.isEmpty) {
      return Text(
        localizations.categoriesNotFoundTxt,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    return CategoryPicker(
      categories: categories.asMap().entries.map((entry) {
        return SupplierCategory(
          productProviderTypeId: entry.key + 1,
          productCategoryDesc: '', // Assuming IDs start at 1
          // Add other required SupplierCategory fields here
          // For example:
          // name: entry.value,
          // description: '',
        );
      }).toList(),
      onCategoryChanged: _onCategoryChanged,
      initialSelection: 0, // Default to first category
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.location_on,
          color: _position != null ? Colors.green : null,
        ),
        title: Text(
          _position != null
              ? '${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}'
              : AppLocalizations.of(context)!.insertCoordinatesMsg,
        ),
        trailing: _position != null
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newPosition = await showLocationInputDialog(context);
                  if (newPosition != null) {
                    setState(() {
                      _position = newPosition;
                      _location_latitude = newPosition.latitude;
                      _location_longitude = newPosition.longitude;
                    });
                  }
                },
              )
            : null,
        onTap: () async {
          final position = await showLocationInputDialog(context);
          if (position != null) {
            setState(() {
              _position = position;
              _location_latitude = position.latitude;
              _location_longitude = position.longitude;
            });
          }
        },
      ),
    );
  }

  List<Widget> _buildContactFields(BuildContext context) {
    return _contactControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      final focusNode = _contactFocusNodes[index];

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.contactInfoMsg,
                  prefixIcon: const Icon(Icons.contact_phone),
                  suffixIcon: _contactControllers.length > 1
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: Colors.red),
                          onPressed: () => _removeContactField(index),
                        )
                      : null,
                ),
                validator: (value) => value?.isEmpty ?? true
                    ? AppLocalizations.of(context)!.pleaseInputContactInfoMsg
                    : null,
                textInputAction: index == _contactControllers.length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                onEditingComplete: () {
                  if (index == _contactControllers.length - 1) {
                    focusNode.unfocus();
                  } else {
                    FocusScope.of(context)
                        .requestFocus(_contactFocusNodes[index + 1]);
                  }
                },
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildAddContactButton(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.add_circle_outline),
      label: Text(AppLocalizations.of(context)!.addContactInfoMsg),
      onPressed: () {
        _addContactField();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
          FocusScope.of(context).requestFocus(_contactFocusNodes.last);
        });
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}
