import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_constants/gluttex_response_codes.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_localiser/components/image_picker.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:gluttex_ui/components/ImagePickerSection.dart';
import 'package:gluttex_ui/components/category_picker.dart';
import 'package:gluttex_ui/components/map_picker.dart';
import 'package:gluttex_ui/components/organisation_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

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
  int? _id_provider_organisation;
  String? _provider_organisation_desc;
  String? _provider_organisation_name;
  String? _supplierImageUrl;
  int? _supplierImageId;
  LatLng? _position;
  int? _id_location;
  late SupplierChangeNotifier _notifier;
  bool _initialized = false; // to prevent re-initialization

  // Dynamic contact fields
  final List<TextEditingController> _contactControllers = [];
  final List<FocusNode> _contactFocusNodes = [];

  final TextEditingController _organizationController = TextEditingController();
  late List<Organisation> organizations;
  List<Organisation> filteredOrganizations = [];
  Organisation? selectedOrganization;
  bool isCustomOrganization = false;

  int _location_address_id = 0;
  String _address_street = "";
  String _address_city = "";
  String _address_postal_code = "";
  String _address_country = "";
  bool updatePage = false;

  GluttexImage? supplier_image;

  @override
  void initState() {
    super.initState();

    _notifier = Provider.of<SupplierChangeNotifier>(context, listen: false);
    organizations = _notifier.supplierOrganisations;
    filteredOrganizations = organizations;
    _organizationController.addListener(_filterOrganizations);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final Supplier? supplier = args?["supplier"];
      if (supplier != null) {
        updatePage = true;
        _idprovider_details_id = supplier.idProviderDetails;
        _id_product_provider = supplier.idProductProvider;
        _id_provider_organisation = supplier.id_provider_organisation;
        _provider_organisation_desc = supplier.provider_organisation_desc;
        _provider_organisation_name = supplier.provider_organisation_name;
        _product_provider_details_id = supplier.idProviderDetails;
        _provider_name = supplier.providerName;
        _provider_contact_info = supplier.providerContactInfo;
        _product_provider_type_id = supplier.productProviderTypeId;
        _location_latitude = supplier.locationLatitude;
        _location_longitude = supplier.locationLongitude;
        _location_name = supplier.locationName;
        _supplierImageUrl = supplier.supplier_image_url;
        _supplierImageId = supplier.supplier_image_id;
        _id_location = supplier.id_location;
        _position =
            LatLng(supplier.locationLatitude, supplier.locationLongitude);

        _location_address_id = supplier.location_address_id;
        _address_street = supplier.address_street;
        _address_city = supplier.address_city;
        _address_postal_code = supplier.address_postal_code;
        _address_country = supplier.address_country;
      }

      if (_provider_contact_info != null &&
          _provider_contact_info!.isNotEmpty) {
        final pattern = RegExp(r'([A-Za-z]+):\s*([^,]+)(?:,\s*|$)');
        final matches = pattern.allMatches(_provider_contact_info!);

        for (final match in matches) {
          if (match.groupCount >= 2) {
            final type = match.group(1)?.trim() ?? '';
            final value = match.group(2)?.trim() ?? '';

            // check if _contactTypes contains this type (case-insensitive)

            final checkedType = _getTypeText(type);

            _contactControllers.add(TextEditingController(text: value));
            _selectedContactTypes.add(checkedType); // keep lowercase
            _contactFocusNodes.add(FocusNode());
          }
        }
      }

      // fallback in case no valid contacts parsed
      if (_contactControllers.isEmpty) {
        _contactControllers.add(TextEditingController());
        _selectedContactTypes.add(_contactTypes.first);
        _contactFocusNodes.add(FocusNode());
      }

      _initialized = true; // prevents running this block again
    }
  }

  @override
  void dispose() {
    for (var controller in _contactControllers) {
      controller.dispose();
    }
    for (var node in _contactFocusNodes) {
      node.dispose();
    }
    _organizationController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterOrganizations() {
    final query = _organizationController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredOrganizations = organizations;
        isCustomOrganization = false;
      } else {
        filteredOrganizations = organizations
            .where((org) =>
                org.provider_organisation_name.toLowerCase().contains(query))
            .toList();

        // Check if the current text doesn't match any organization
        isCustomOrganization = filteredOrganizations.isEmpty ||
            !filteredOrganizations.any((org) =>
                org.provider_organisation_name.toLowerCase() ==
                query.toLowerCase());
      }
    });
  }

  void _selectOrganization(Organisation org) {
    setState(() {
      selectedOrganization = org;
      _organizationController.text = org.provider_organisation_name;
      isCustomOrganization = false;
    });
    // Close the dropdown
    FocusScope.of(context).unfocus();
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

      // Concatenate contact info fields with index mapping
      _provider_contact_info = _contactControllers
          .asMap()
          .entries
          .where((entry) => entry.value.text.isNotEmpty)
          .map((entry) =>
              '${_selectedContactTypes[entry.key]}:${entry.value.text}')
          .join(',');

      // log("${_provider_contact_info}");

      Supplier supplier = Supplier(
        id_location: _id_location ?? 0,
        idProviderDetails: _idprovider_details_id ?? 0,
        idProductProvider: _id_product_provider ?? 0,
        id_provider_organisation: _id_provider_organisation ?? 0,
        provider_organisation_name: _provider_organisation_name ?? "",
        provider_organisation_desc: _provider_organisation_desc ?? "",
        productProviderDetailsId: _product_provider_details_id ?? 0,
        productProviderTypeId: _product_provider_type_id ?? 1,
        providerName: _provider_name ?? "",
        providerContactInfo: _provider_contact_info ?? "",
        locationLatitude: _location_latitude ?? 0.0,
        locationLongitude: _location_longitude ?? 0.0,
        locationName: _location_name ?? "",
        productProviderOwnerId:
            Provider.of<AppUserNotifier>(context, listen: false)
                    .appUser!
                    .id_app_user ??
                0,
        supplier_image_url: _supplierImageUrl,
        supplier_image_id: _supplierImageId,
        location_address_id: _location_address_id,
        address_street: _address_street,
        address_city: _address_city,
        address_postal_code: _address_postal_code,
        address_country: _address_country,
      );

      try {
        if (supplier_image != null)
          // ignore: curly_braces_in_flow_control_structures
          supplier.supplier_image = supplier_image!;

        if (supplier.idProductProvider == 0) {
          supplier.supplier_image_url = await Navigator.pushNamed(
            context,
            AppRoutes.imageUpload,
            arguments: {
              "entity": "supplier",
              "id": supplier.idProductProvider,
            },
          ) as String?;
        }

        await Provider.of<SupplierChangeNotifier>(
          context,
          listen: false,
        ).addOrUpdateRecipe(supplier);

        ResponseHandler.handleResponse(
          context: context,
          statusCode: 200,
          responseCode: GluttexResponseCodes.put_success,
          finalMessage: AppLocalizations.of(context)!.putSuccess,
        );

        Navigator.popUntil(
            context, (route) => route.settings.name == AppRoutes.home);
        // Show success message once

        // ⚠️ Do NOT popUntil right after, otherwise the push gets cancelled
        // If you want to go home AFTER image upload, handle it in imageUpload screen
      } on GluttexException catch (e) {
        // Handle recipe submission error
        ResponseHandler.handleResponse(
          context: context,
          statusCode: e.statusCode ?? 300,
          responseCode: e.message,
          finalMessage: AppLocalizations.of(context)!.putFailure,
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
        title: Text(updatePage
            ? localizations.supplierText
            : localizations.addSupplierTxt),
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
              // _buildImageSection(context),
              // const SizedBox(height: 24),

              if (_id_product_provider != null && _id_product_provider != 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(localizations.providerImage),
                    ImagePickerSection(
                      initialImageUrl: (_supplierImageUrl ?? ""),
                      entityType: 'supplier',
                      ownerId: '$_id_provider_organisation',
                      entityId: '$_id_product_provider',
                      onImageUploaded: (newImage) {
                        setState(() {
                          supplier_image = newImage;
                          _supplierImageId =
                              0; // Reset image ID to 0 for new uploads
                        });
                      },
                    ),
                  ],
                ),

              // Basic Information Section
              _buildSectionHeader(localizations.basicInformation),
              _buildTextField(context,
                  label: localizations.supplierNameMsg,
                  icon: Icons.business,
                  onSaved: (value) => _provider_name = value,
                  validator: (value) => value?.isEmpty ?? true
                      ? localizations.addBusinessNameMsg
                      : null,
                  initialValue: _provider_name),
              const SizedBox(height: 6),
              _buildTextField(context,
                  label: localizations.streetText,
                  icon: Icons.business,
                  onSaved: (value) => _address_street = value ?? "",
                  validator: (value) =>
                      value?.isEmpty ?? true ? localizations.streetText : null,
                  initialValue: _address_street),
              const SizedBox(height: 6),
              _buildTextField(context,
                  label: localizations.cityText,
                  icon: Icons.business,
                  onSaved: (value) => _address_city = value ?? "",
                  validator: (value) =>
                      value?.isEmpty ?? true ? localizations.cityText : null,
                  initialValue: _address_city),
              const SizedBox(height: 6),
              _buildTextField(context,
                  label: localizations.postalCodeText,
                  icon: Icons.business,
                  onSaved: (value) => _address_postal_code = value ?? "",
                  validator: (value) => value?.isEmpty ?? true
                      ? localizations.postalCodeText
                      : null,
                  initialValue: _address_postal_code),

              const SizedBox(height: 6),
              _buildTextField(context,
                  label: localizations.countryText,
                  icon: Icons.business,
                  onSaved: (value) => _address_country = value ?? "",
                  validator: (value) =>
                      value?.isEmpty ?? true ? localizations.countryText : null,
                  initialValue: _address_country),

              const SizedBox(height: 16),

              // Replace your TextFormField with this premium component
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label

                  // Searchable input with TypeAhead

                  OrganisationPicker(
                    initialValue: _id_provider_organisation,
                    onOrganisationSelected: (value) {
                      _id_provider_organisation =
                          value.id_provider_organisation;
                      _provider_organisation_name =
                          value.provider_organisation_name;
                    },
                    hintText: localizations.selectOrganisationHintText,
                  ),
                  // _buildOrgPicker(conterxt),

                  // const SizedBox(height: 12),

                  // Selected organisation chip (pretty card style)
                  if (selectedOrganization != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${selectedOrganization!.provider_organisation_name}',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOrganization = null;
                                _organizationController.clear();
                              });
                            },
                            child: Icon(Icons.close,
                                color: Colors.grey[600], size: 18),
                          ),
                        ],
                      ),
                    ),

                  // Suggestion to create a new one
                  if (selectedOrganization == null &&
                      _organizationController.text.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add_circle,
                              color: Colors.orange[700], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: 'New organisation: '),
                                  TextSpan(
                                    text: _organizationController.text,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const TextSpan(
                                      text: ' will be created on submission'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              // Category Picker
              _buildCategoryPicker(context),
              const SizedBox(height: 16),

              // Location Information Section
              _buildSectionHeader(localizations.locationInformation),
              _buildTextField(context,
                  label: localizations.locationNameText,
                  icon: Icons.place,
                  onSaved: (value) => _location_name = value,
                  validator: (value) => value?.isEmpty ?? true
                      ? localizations.pleaseInputLocationNameMsg
                      : null,
                  initialValue: _location_name),
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
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary, // Button background color
                  foregroundColor: Theme.of(context)
                      .colorScheme
                      .onPrimary, // Text & icon color
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12), // optional
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
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
      categories: categories.toList(),
      onCategoryChanged: _onCategoryChanged,
      pathFunction: (int id) => "assets/icons/${id}.svg",
      category_id: 1,
      package: 'gluttex_localiser',
      // initialSelection: 0, // Default to first category
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
                color: theme.colorScheme.secondary,
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
    'instagram',
    'facebook',
    'email',
    'phone',
    'website',
    'tiktok',
    'whatsapp',
    'other',
  ];

  // final Map<String, IconData> _contactIcons = {
  //   'Instagram':
  //       FontAwesomeIcons.instagram, // replace with brand icons if needed
  //   'Facebook': FontAwesomeIcons.facebook,
  //   'Email': FontAwesomeIcons.envelope,
  //   'Phone': FontAwesomeIcons.phone,
  //   'TikTok': FontAwesomeIcons.tiktok,
  // };

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
                                        child: Icon(getContactIcon(type),
                                            size: 24),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                selectedItemBuilder: (context) {
                                  return _contactTypes.map((type) {
                                    return Center(
                                      child:
                                          Icon(getContactIcon(type), size: 24),
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
                          // prefixIcon: Padding(
                          //   padding: const EdgeInsets.only(left: 12, right: 8),
                          //   child: Icon(
                          //     _contactIcons[selectedType],
                          //     size: 20,
                          //     color: theme.colorScheme.onSurface,
                          //   ),
                          // ),
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

  // Widget _buildOrganisationPicker(BuildContext context) {
  //   return OrganisationPicker(
  //     organisations: _notifier.supplierOrganisations,
  //     initialOrganisationId: 1,
  //     onOrganisationChanged: (id) {
  //       // print("Selected organisation id: $id");
  //     },
  //   );
  // }

  String _getTypeText(String type) {
    final lowercaseType = type.toLowerCase();
    final contactTypes = _contactTypes.where((t) => t == lowercaseType);
    return contactTypes.isEmpty ? _contactTypes.last : contactTypes.first;
  }

  IconData getContactIcon(String type) {
    final lowercaseType = type.toLowerCase();

    if (lowercaseType.contains('facebook')) return FontAwesomeIcons.facebook;
    if (lowercaseType.contains('phone')) return FontAwesomeIcons.phone;
    if (lowercaseType.contains('website')) return FontAwesomeIcons.globe;
    if (lowercaseType.contains('instagram')) return FontAwesomeIcons.instagram;
    if (lowercaseType.contains('email')) return FontAwesomeIcons.envelope;
    if (lowercaseType.contains('whatsapp')) return FontAwesomeIcons.whatsapp;
    if (lowercaseType.contains('tiktok')) return FontAwesomeIcons.tiktok;

    return FontAwesomeIcons.addressCard; // default icon
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? Function(String?)? validator,
    String? initialValue,
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
      initialValue: initialValue,
    );
  }
}
