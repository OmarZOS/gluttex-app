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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
      _selectedContactTypes.add(_contactTypes.first); // initialize same length
    });
  }

  void _removeContactField(int index) {
    setState(() {
      _contactControllers.removeAt(index);
      _selectedContactTypes.removeAt(index);
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
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.save),
        //     onPressed: _submitForm,
        //     tooltip: localizations.save,
        //   ),
        // ],
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
              // _buildAddContactButton(context),
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
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final hasLocation = _position != null;

    return GestureDetector(
      onTap: () async {
        final position = await showLocationInputDialog(context);
        if (position != null && mounted) {
          setState(() {
            _position = position;
            _location_latitude = position.latitude;
            _location_longitude = position.longitude;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasLocation
                ? theme.colorScheme.primary.withOpacity(0.2)
                : theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasLocation
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on,
                color: hasLocation
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.insertCoordinatesMsg,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasLocation
                        ? '${_position!.latitude.toStringAsFixed(4)}, ${_position!.longitude.toStringAsFixed(4)}'
                        : loc.insertCoordinatesMsg,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: hasLocation
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  if (hasLocation && _location_name != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _location_name!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
            ),
            if (hasLocation)
              IconButton(
                icon: Icon(Icons.edit, size: 20),
                color: theme.colorScheme.primary,
                onPressed: () async {
                  final newPosition = await showLocationInputDialog(context);
                  if (newPosition != null && mounted) {
                    setState(() {
                      _position = newPosition;
                      _location_latitude = newPosition.latitude;
                      _location_longitude = newPosition.longitude;
                    });
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  final List<String> _contactTypes = [
    'Instagram',
    'Facebook',
    'Email',
    'Phone',
    'TikTok',
  ];

  final Map<String, IconData> _contactIcons = {
    'Instagram':
        FontAwesomeIcons.instagram, // replace with brand icons if needed
    'Facebook': FontAwesomeIcons.facebook,
    'Email': FontAwesomeIcons.envelope,
    'Phone': FontAwesomeIcons.phone,
    'TikTok': FontAwesomeIcons.tiktok,
  };

// Stores selected type for each contact row
  List<String> _selectedContactTypes = [];

  List<Widget> _buildContactFields(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return _contactControllers.asMap().entries.map((entry) {
      final index = entry.key;
      final controller = entry.value;
      final focusNode = _contactFocusNodes[index];
      final selectedType = _selectedContactTypes[index];
      final isLastField = index == _contactControllers.length - 1;

      return Padding(
        padding: EdgeInsets.only(bottom: isLastField ? 24 : 16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Contact type dropdown (icon-only)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Tooltip(
                        message: selectedType,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.surfaceVariant
                                .withOpacity(0.3),
                          ),
                          child: Center(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedType,
                                onChanged: (newValue) => setState(() {
                                  _selectedContactTypes[index] = newValue!;
                                  if (controller.text.isEmpty) {
                                    FocusScope.of(context)
                                        .requestFocus(focusNode);
                                  }
                                }),
                                items: _contactTypes.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Tooltip(
                                      message: type,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child:
                                            Icon(_contactIcons[type], size: 24),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                selectedItemBuilder: (context) {
                                  return _contactTypes.map((type) {
                                    return Center(
                                      child:
                                          Icon(_contactIcons[type], size: 24),
                                    );
                                  }).toList();
                                },
                                icon:
                                    const Icon(Icons.arrow_drop_down, size: 20),
                                borderRadius: BorderRadius.circular(12),
                                dropdownColor: theme.colorScheme.surface,
                                elevation: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Contact input field
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          hintText: _getContactHint(selectedType),
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
                            child: Icon(
                              _contactIcons[selectedType],
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          suffixIcon: _contactControllers.length > 1
                              ? IconButton(
                                  icon: Icon(Icons.remove_circle,
                                      color: theme.colorScheme.error),
                                  onPressed: () => _removeContactField(index),
                                  // tooltip: loc.removeContact,
                                )
                              : null,
                        ),
                        style: theme.textTheme.bodyMedium,
                        validator: (value) =>
                            value == "" ? loc.pleaseInputContactInfoMsg : null,
                        textInputAction: isLastField
                            ? TextInputAction.done
                            : TextInputAction.next,
                        keyboardType: _getKeyboardType(selectedType),
                        onEditingComplete: () {
                          if (isLastField) {
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
              ),

              // Add new field button (only on last field)
              if (isLastField)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      onPressed: _addContactField,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: theme.colorScheme.surfaceVariant,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add,
                              size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(loc.addContactInfoMsg,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

// Helper method to determine keyboard type based on contact type
  TextInputType _getKeyboardType(String contactType) {
    if (contactType.toLowerCase().contains('phone')) {
      return TextInputType.phone;
    } else if (contactType.toLowerCase().contains('email')) {
      return TextInputType.emailAddress;
    } else if (contactType.toLowerCase().contains('url')) {
      return TextInputType.url;
    }
    return TextInputType.text;
  }

// Helper method to provide contextual hints
  String _getContactHint(String contactType) {
    switch (contactType.toLowerCase()) {
      case 'phone':
        return 'Enter phone number';
      case 'email':
        return 'Enter email address';
      case 'website':
        return 'Enter website URL';
      case 'social':
        return 'Enter social media handle';
      default:
        return 'Enter contact information';
    }
  }

  // Widget _buildAddContactButton(BuildContext context) {
  //   return TextButton.icon(
  //     icon: const Icon(Icons.add_circle_outline),
  //     label: Text(AppLocalizations.of(context)!.addContactInfoMsg),
  //     onPressed: () {
  //       _addContactField();
  //       WidgetsBinding.instance.addPostFrameCallback((_) {
  //         _scrollController.animateTo(
  //           _scrollController.position.maxScrollExtent,
  //           duration: const Duration(milliseconds: 300),
  //           curve: Curves.easeOut,
  //         );
  //         FocusScope.of(context).requestFocus(_contactFocusNodes.last);
  //       });
  //     },
  //   );
  // }

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
