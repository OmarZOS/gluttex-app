import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
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

  int? _idprovider_details_id;
  int? _id_product_provider;
  int? _product_provider_details_id;
  String? _provider_name;
  String? _provider_contact_info = "";
  // String? _product_provider_type_desc;
  int? _product_provider_type_id;
  double? _location_latitude;
  double? _location_longitude;
  String? _location_name;
  Uint8List? _supplierImage;

  LatLng? _position;

  final List<TextEditingController> _contactControllers = [];
  final List<Widget> _contactFields = [];

  @override
  void initState() {
    super.initState();
    _addContactField();
  }

  @override
  void dispose() {
    for (var controller in _contactControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addContactField() {
    final controller = TextEditingController();
    final field = TextFormField(
      controller: controller,
      decoration:
          const InputDecoration(labelText: GluttexConstants.contactInfoMsg),
      // onSaved: (value) =>
      //     _provider_contact_info = '${_provider_contact_info}${value},',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return GluttexConstants.pleaseInputContactInfoMsg;
        }
        return null;
      },
    );

    setState(() {
      _contactControllers.add(controller);
      _contactFields.add(field);
    });
  }

  void _removeContactField(int index) {
    setState(() {
      _contactControllers.removeAt(index);
      _contactFields.removeAt(index);
    });
  }

  void _onCategoryChanged(int identifier) {
    _product_provider_type_id = identifier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            // concatenating contact info fields
            _provider_contact_info = _contactControllers
                .map((controller) => controller.text)
                .join(',');
            // -----------------------------------------
            final supplier = Supplier(
              idprovider_details_id: _idprovider_details_id ?? 0,
              id_product_provider: _id_product_provider ?? 0,
              product_provider_details_id: _product_provider_details_id ?? 0,
              product_provider_type_id: _product_provider_type_id ?? 1,
              provider_name: _provider_name ?? "",
              provider_contact_info: _provider_contact_info ?? "",
              location_latitude: _location_latitude ?? 0.0,
              location_longitude: _location_longitude ?? 0.0,
              location_name: _location_name ?? "",
            );

            // Handle Supplier submission
            int? result = await GluttexLocator.get<SupplierService>()
                .addSupplier(supplier);

            Response response = Response();

            switch (result) {
              case 200:
                response.color = Colors.green;
                response.text = GluttexConstants.putSuccess;
                break;
              case 406:
                response.color = Colors.amberAccent;
                response.text = GluttexConstants.putFailure;
                break;
              case 422:
                response.color = Colors.amberAccent;
                response.text = GluttexConstants.putFailure;
                break;

              default:
                response.color = Colors.red;
                response.text = GluttexConstants.serverError;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.text),
                backgroundColor: response.color,
              ),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.text),
                backgroundColor: response.color,
              ),
            );
          }
        },
        child: const Icon(Icons.add_business_sharp),
      ),
      appBar: AppBar(
          title: const Text(
        GluttexConstants.addSupplierTxt,
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    labelText: GluttexConstants.supplierNameMsg),
                onSaved: (value) => _provider_name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.addBusinessNameMsg;
                  }
                  return null;
                },
              ),
              // TextFormField(
              //   decoration: const InputDecoration(labelText: 'Contact info'),
              //   onSaved: (value) => _provider_contact_info = value,
              // ),
              TextFormField(
                  decoration: const InputDecoration(
                      labelText: GluttexConstants.locationNameText),
                  onSaved: (value) => _location_name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return GluttexConstants.pleaseInputLocationNameMsg;
                    }
                    return null;
                  }),
              const SizedBox(height: 16.0),
              FutureBuilder<List<Category>>(
                future: GluttexLocator.get<SupplierService>().getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Show a loading indicator while waiting
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text(GluttexConstants.categoriesNotFoundTxt);
                  } else {
                    return CategoryPicker(
                      categories: snapshot.data!,
                      onCategoryChanged: (selectedCategoryId) {
                        _onCategoryChanged(selectedCategoryId);
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16.0),
              Column(
                children: _contactFields.asMap().entries.map((entry) {
                  int index = entry.key;
                  Widget field = entry.value;
                  return ListTile(
                    title: field,
                    // // tileColor: Colors.amber[100],
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle),
                      onPressed: () {
                        _removeContactField(index);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: const Icon(Icons.add_circle),
                title: const Text(GluttexConstants.addContactInfoMsg),
                // tileColor: Colors.amber[100],
                onTap: _addContactField,
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(
                    '${_position ?? GluttexConstants.insertCoordinatesMsg}'),
                // tileColor: Colors.grey[100],
                trailing: _position != null
                    ? const Icon(
                        Icons.check_circle_outline_outlined,
                        color: Colors.green,
                      )
                    : null,
                onTap: () async {
                  _position = await showLocationInputDialog(context);
                  _location_latitude = _position?.latitude;
                  _location_longitude = _position?.longitude;
                  setState(() {});
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: const Text(GluttexConstants.pickImageMsg),
                // tileColor: Colors.grey[100],
                onTap: () async {
                  final pickedImage = await pickImage();
                  setState(() {
                    _supplierImage = pickedImage;
                  });
                },
              ),
              _supplierImage != null
                  ? Image.memory(_supplierImage!)
                  : Container(),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
