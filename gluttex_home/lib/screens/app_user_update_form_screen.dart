import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:gluttex_home/screens/category_picker.dart';
import 'package:gluttex_home/screens/tools/image_picker.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

class AppUserEditFormScreen extends StatefulWidget {
  final int? initial_id_app_user;
  final int? initial_app_user_person_id;
  final int? initial_app_user_type_id;
  final int? initial_id_app_user_type;
  final int? initial_idPerson;
  final int? initial_personDetailsId;
  final int? initial_idBloodType;
  final String? initial_bloodTypeDesc;
  final int? initial_idLocation;
  final int? initial_locationAddressId;
  final String? initial_app_user_name;
  final String? initial_app_user_password;
  final String? initial_app_user_preferences;
  final String? initial_app_user_type_desc;
  final Uint8List? initial_app_user_image;
  final String? initial_personFirstName;
  final String? initial_personLastName;
  final String? initial_personBirthDate;
  final String? initial_personGender;
  final String? initial_personNationality;
  final double? initial_locationLatitude;
  final double? initial_locationLongitude;
  final String? initial_locationName;
  final String? initial_addressStreet;
  final String? initial_addressCity;
  final String? initial_addressPostalCode;
  final String? initial_addressCountry;

  const AppUserEditFormScreen(
      {Key? key,
      required this.initial_id_app_user,
      required this.initial_app_user_person_id,
      required this.initial_app_user_type_id,
      required this.initial_id_app_user_type,
      required this.initial_idPerson,
      required this.initial_personDetailsId,
      required this.initial_idBloodType,
      required this.initial_idLocation,
      required this.initial_locationAddressId,
      required this.initial_app_user_name,
      required this.initial_app_user_password,
      required this.initial_app_user_preferences,
      required this.initial_app_user_type_desc,
      required this.initial_app_user_image,
      required this.initial_personFirstName,
      required this.initial_personLastName,
      required this.initial_personBirthDate,
      required this.initial_personGender,
      required this.initial_personNationality,
      required this.initial_locationLatitude,
      required this.initial_locationLongitude,
      required this.initial_locationName,
      required this.initial_addressStreet,
      required this.initial_addressCity,
      required this.initial_addressPostalCode,
      required this.initial_addressCountry,
      required this.initial_bloodTypeDesc})
      : super(key: key);

  @override
  _AppUserEditFormScreenState createState() => _AppUserEditFormScreenState();
}

class _AppUserEditFormScreenState extends State<AppUserEditFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late int? _id_app_user;
  late int? _app_user_person_id;
  late int? _app_user_type_id;
  late int? _id_app_user_type;
  late int? _idPerson;
  late int? _personDetailsId;
  late int? _idBloodType;
  late String? _bloodTypeDesc;
  late int? _idLocation;
  late int? _locationAddressId;
  late String? _app_user_name;
  late String? _app_user_password;
  late String? _app_user_preferences;
  late String? _app_user_type_desc;
  late Uint8List? _app_user_image;
  late String? _personFirstName;
  late String? _personLastName;
  late String? _personBirthDate;
  late String? _personGender;
  late String? _personNationality;
  late double? _locationLatitude;
  late double? _locationLongitude;
  late String? _locationName;
  late String? _addressStreet;
  late String? _addressCity;
  late String? _addressPostalCode;
  late String? _addressCountry;

  @override
  void initState() {
    super.initState();

    _id_app_user = widget.initial_id_app_user;
    _app_user_person_id = widget.initial_app_user_person_id;
    _app_user_type_id = widget.initial_app_user_type_id;
    _id_app_user_type = widget.initial_id_app_user_type;
    _idPerson = widget.initial_idPerson;
    _personDetailsId = widget.initial_personDetailsId;
    _idBloodType = widget.initial_idBloodType;
    _idLocation = widget.initial_idLocation;
    _locationAddressId = widget.initial_locationAddressId;
    _app_user_name = widget.initial_app_user_name;
    _app_user_password = widget.initial_app_user_password;
    _app_user_preferences = widget.initial_app_user_preferences;
    _app_user_type_desc = widget.initial_app_user_type_desc;
    _app_user_image = widget.initial_app_user_image;
    _personFirstName = widget.initial_personFirstName;
    _personLastName = widget.initial_personLastName;
    _personBirthDate = widget.initial_personBirthDate;
    _personGender = widget.initial_personGender;
    _personNationality = widget.initial_personNationality;
    _locationLatitude = widget.initial_locationLatitude;
    _locationLongitude = widget.initial_locationLongitude;
    _locationName = widget.initial_locationName;
    _addressStreet = widget.initial_addressStreet;
    _addressCity = widget.initial_addressCity;
    _addressPostalCode = widget.initial_addressPostalCode;
    _addressCountry = widget.initial_addressCountry;
    _bloodTypeDesc = widget.initial_bloodTypeDesc;

    // Initialize state variables with initial values from the widget

    // id_app_user = widget.initialAppUserName;
    // _app_user_image = widget.initialAppUserImage;
    // _appUserDescription = widget.initialAppUserDescription;
    // _appUserInstruction = widget.initialAppUserInstruction;
    // _appUser_category_id = widget.initialAppUser_category_id;
    // _id_appUser = widget.initialIdAppUser;
    // _id_appUser_image = widget.initialIdAppUserImage;
    // _appUserPreparationTime = widget.initialAppUserPreparationTime;
    // preparationTime = ParseDurationString(_appUserPreparationTime ?? "");
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageData = await pickedFile.readAsBytes();
      Uint8List resizedImage = resizeImage(
          imageData,
          MediaQuery.of(context).size.width.floor(),
          MediaQuery.of(context).size.width.floor());
      setState(() {
        _app_user_image = resizedImage;
      });
    }
  }

  void _onCategoryChanged(int identifier) {
    _app_user_type_id = identifier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update AppUser'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.shopify_sharp,
          // color: Colors.yellow[50],
        ),
        onPressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _app_user_name,
                decoration: const InputDecoration(labelText: 'AppUser Name'),
                onSaved: (value) => _app_user_name = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a appUser description';
                  }

                  if ((value).length >= 300) {
                    return 'Character limit: 300.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _personLastName,
                decoration: const InputDecoration(labelText: 'AppUser Name'),
                onSaved: (value) => _personLastName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a appUser description';
                  }

                  if ((value).length >= 300) {
                    return 'Character limit: 300.';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: '${_personFirstName ?? ""}',
                decoration:
                    const InputDecoration(labelText: 'AppUser Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a appUser description';
                  }

                  if ((value).length >= 300) {
                    return 'Character limit: 300.';
                  }
                  return null;
                },
                onSaved: (value) => _personFirstName = value,
              ),
              const SizedBox(height: 16.0),
              FutureBuilder<List<AppUserCategory>?>(
                future: GluttexLocator.get<AppUserService>().getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Show a loading indicator while waiting
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Categories not found');
                  } else {
                    return CategoryPicker(
                      category_id: _id_app_user_type ?? 1,
                      categories: snapshot.data!,
                      onCategoryChanged: (selectedCategoryId) {
                        _onCategoryChanged(selectedCategoryId);
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16.0),
              _app_user_image != null
                  ? Image.memory(_app_user_image!,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width)
                  : const Text('No image selected'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final appUser = AppUser(
                      id_app_user: _id_app_user ?? 0,
                      app_user_person_id: _app_user_person_id ?? 0,
                      app_user_type_id: _app_user_type_id ?? 0,
                      app_user_name: _app_user_name ?? "",
                      app_user_password: _app_user_password ?? "",
                      app_user_preferences: _app_user_preferences ?? "",
                      app_user_type_desc: _app_user_type_desc ?? "",
                      app_user_image: _app_user_image,
                      idPerson: _idPerson ?? 0,
                      personDetailsId: _personDetailsId ?? 0,
                      personFirstName: _personFirstName ?? "",
                      personLastName: _personLastName ?? "",
                      personBirthDate: _personBirthDate ?? "",
                      personGender: _personGender ?? "",
                      personNationality: _personNationality ?? "",
                      idBloodType: _idBloodType ?? 0,
                      idLocation: _idLocation ?? 0,
                      locationLatitude: _locationLatitude ?? 0.0,
                      locationLongitude: _locationLongitude ?? 0.0,
                      locationName: _locationName ?? "",
                      locationAddressId: _locationAddressId ?? 0,
                      addressStreet: _addressStreet ?? "",
                      addressCity: _addressCity ?? "",
                      addressPostalCode: _addressPostalCode ?? "",
                      addressCountry: _addressCountry ?? "",
                      bloodTypeDesc: _bloodTypeDesc ?? "",
                    );

                    // Handle appUser submission
                    int? status_code =
                        await GluttexLocator.get<AppUserService>()
                            .updateAppUser(appUser);

                    Response response = Response();

                    switch (status_code) {
                      case 200:
                        response.color = Colors.green;
                        response.text = GluttexConstants.putSuccess;
                        await Provider.of<AppUserNotifier>(context,
                                listen: false)
                            .fetchAppUser('${_id_app_user}');
                        Navigator.pop(context, appUser);
                        break;
                      case 406:
                        response.color = Colors.amberAccent;
                        response.text = 'Error ${status_code}: ' +
                            GluttexConstants.putFailure;
                        break;
                      case 422:
                        response.color = Colors.amberAccent;
                        response.text = 'Error ${status_code}: ' +
                            GluttexConstants.putFailure;
                        break;

                      default:
                        response.color = Colors.red;
                        response.text = 'Error ${status_code}: ' +
                            GluttexConstants.serverError;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.text),
                        backgroundColor: response.color,
                      ),
                    );

                    // You can use a provider or any state management to save the appUser
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
