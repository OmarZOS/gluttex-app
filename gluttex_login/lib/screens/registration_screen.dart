import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_constants/gluttex_constants.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  String? appUserName = "";
  String? appUserPassword = "";
  int? appUserTypeId = 0;
  String? personFirstName = "";
  String? personLastName = "";
  String? personGender = "";
  String? personNationality = "";
  int? bloodTypeId = 0;
  double? locationLatitude = 0;
  double? locationLongitude = 0;
  String? locationName = "";
  String? addressStreet = "";
  String? addressCity = "";
  String? addressPostalCode = "";
  String? addressCountry = "";

  final TextEditingController _birthDateController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(GluttexConstants.registerationFormText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: GluttexConstants.usernameText),
                onSaved: (value) {
                  appUserName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.pleaseInputusernameMsg;
                  }
                  return null;
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: GluttexConstants.passwordText),
                obscureText: true,
                onSaved: (value) {
                  appUserPassword = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.pleaseInputpasswordMsg;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                decoration:
                    const InputDecoration(labelText: GluttexConstants.userTypeText),
                items: [
                  {'value': 1, 'label': GluttexConstants.clientText},
                  {'value': 3, 'label': GluttexConstants.cookingChefText}
                ].map((Map<String, dynamic> item) {
                  return DropdownMenuItem<int>(
                    value: item['value'],
                    child: Text(item['label']),
                  );
                }).toList(),
                onChanged: (value) {
                  appUserTypeId = value;
                },
                validator: (value) {
                  if (value == null) {
                    return GluttexConstants.pleaseInputUserTypeMsg;
                  }
                  return null;
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: GluttexConstants.firstNameText),
                onSaved: (value) {
                  personFirstName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.pleaseInputFirstNameMsg;
                  }
                  return null;
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: GluttexConstants.lastNameText),
                onSaved: (value) {
                  personLastName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.pleaseInputLastNameMsg;
                  }
                  return null;
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(
                  labelText: GluttexConstants.birthdayText,
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      _birthDateController.text = "${pickedDate.toLocal()}"
                          .split(' ')[0]; // Formatting the date as yyyy-MM-dd
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return GluttexConstants.pleaseInputBirthdateMsg;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: GluttexConstants.genderText),
                items: GluttexConstants.genderTextList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  personGender = value;
                },
                validator: (value) {
                  if (value == null) {
                    return GluttexConstants.pleaseInputgenderMsg;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: GluttexConstants.nationalityText),
                items: GluttexConstants.nationalityTextList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  personNationality = value;
                },
                validator: (value) {
                  if (value == null) {
                    return GluttexConstants.pleaseInputnationalityMsg;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                decoration:
                    const InputDecoration(labelText: GluttexConstants.bloodTypeText),
                items: [
                  {'value': 1, 'label': 'O+'},
                  {'value': 2, 'label': 'A+'},
                  {'value': 3, 'label': 'B+'},
                  {'value': 4, 'label': 'AB+'},
                  {'value': 5, 'label': 'O-'},
                  {'value': 6, 'label': 'A-'},
                  {'value': 7, 'label': 'B-'},
                  {'value': 8, 'label': 'AB-'},
                ].map((Map<String, dynamic> item) {
                  return DropdownMenuItem<int>(
                    value: item['value'],
                    child: Text(item['label']),
                  );
                }).toList(),
                onChanged: (value) {
                  bloodTypeId = value;
                },
                validator: (value) {
                  if (value == null) {
                    return GluttexConstants.pleaseInputBloodTypeMsg;
                  }
                  return null;
                },
              ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: GluttexConstants.latitudeText),
              //   keyboardType: TextInputType.number,
              //   onSaved: (value) {
              //     locationLatitude = double.tryParse(value ?? '');
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: GluttexConstants.longitudeText),
              //   keyboardType: TextInputType.number,
              //   onSaved: (value) {
              //     locationLongitude = double.tryParse(value ?? '');
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: GluttexConstants.locationNameText),
              //   onSaved: (value) {
              //     locationName = value;
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: GluttexConstants.streetText),
              //   onSaved: (value) {
              //     addressStreet = value;
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: GluttexConstants.cityText),
              //   onSaved: (value) {
              //     addressCity = value;
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: GluttexConstants.postalCodeText),
              //   onSaved: (value) {
              //     addressPostalCode = value;
              //   },
              // ),
              DropdownButtonFormField<String>(
                decoration:
                    const InputDecoration(labelText: GluttexConstants.countryText),
                items: ['Algeria', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  addressCountry = value;
                },
                validator: (value) {
                  if (value == null) {
                    return GluttexConstants.pleaseInputCountryMsg;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // sendRegistrationData();

                    var payload = {
                      "user": {
                        "id_app_user": 0,
                        "app_user_person_id": 0,
                        "app_user_name": appUserName ?? "",
                        "app_user_password": appUserPassword ?? "",
                        "app_user_type_id": appUserTypeId ?? 1,
                      },
                      // "person": {
                      //   "id_person": 0,
                      //   "person_details_id": 0,
                      //   "id_person_details": 0,
                      //   "person_first_name": personFirstName,
                      //   "person_last_name": personLastName,
                      //   "person_birth_date": _birthDateController.text,
                      //   "person_gender": personGender,
                      //   "person_nationality": personNationality,
                      //   "id_blood_type": bloodTypeId,
                      // },
                      // "location": {
                      //   "id_location": 0,
                      //   "location_address_id": 0,
                      //   "id_address": 0,
                      //   "location_latitude": locationLatitude ?? 0.0,
                      //   "location_longitude": locationLongitude ?? 0.0,
                      //   "location_name": locationName ?? "",
                      //   "address_street": addressStreet ?? "",
                      //   "address_city": addressCity ?? "",
                      //   "address_postal_code": addressPostalCode,
                      //   "address_country": addressCountry ?? "",
                      // }
                    };

                    log(payload.toString());

                    try {
                      dynamic data = await Provider.of<AppUserNotifier>(context,
                              listen: false)
                          .signUpWithData(payload);

                      if (data != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(data.toString())),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              backgroundColor: Colors.green,
                              content:
                                  Text(GluttexConstants.loginSuccessfullMsg)),
                        );
                      }

                      Navigator.of(context).pop();
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(error.toString())),
                      );
                    }
                  }
                },
                child: const Text(GluttexConstants.registerText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendRegistrationData() async {
    // Build the payload

    // Send the data to the server
  }
}
