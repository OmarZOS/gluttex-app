import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:provider/provider.dart';

class RegistrationForm extends StatefulWidget {
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

  TextEditingController _birthDateController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                onSaved: (value) {
                  appUserName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (value) {
                  appUserPassword = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'User Type'),
                items: [
                  {'value': 1, 'label': 'Client'},
                  {'value': 3, 'label': 'Cooking Chef'}
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
                    return 'Please select a user type';
                  }
                  return null;
                },
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name'),
                onSaved: (value) {
                  personFirstName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a first name';
                  }
                  return null;
                },
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name'),
                onSaved: (value) {
                  personLastName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a last name';
                  }
                  return null;
                },
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: 'Birthdate',
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
                    return 'Please select your birthdate';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other'].map((String value) {
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
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Nationality'),
                items: ['Algerian', 'Other'].map((String value) {
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
                    return 'Please select a nationality';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Blood Type'),
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
                    return 'Please select a blood type';
                  }
                  return null;
                },
              ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: 'Latitude'),
              //   keyboardType: TextInputType.number,
              //   onSaved: (value) {
              //     locationLatitude = double.tryParse(value ?? '');
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: 'Longitude'),
              //   keyboardType: TextInputType.number,
              //   onSaved: (value) {
              //     locationLongitude = double.tryParse(value ?? '');
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: 'Location Name'),
              //   onSaved: (value) {
              //     locationName = value;
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: 'Street'),
              //   onSaved: (value) {
              //     addressStreet = value;
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: 'City'),
              //   onSaved: (value) {
              //     addressCity = value;
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: 'Postal Code'),
              //   onSaved: (value) {
              //     addressPostalCode = value;
              //   },
              // ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Country'),
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
                    return 'Please select a country';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
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

                      if (data != null)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(data.toString())),
                        );
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.green,
                              content: Text("Successfully signed up.")),
                        );
                      }

                      Navigator.of(context).pop();
                    } catch (error, stacktrace) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(error.toString())),
                      );
                    }
                  }
                },
                child: Text('Register'),
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
