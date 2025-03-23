import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

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
  String? personNationality = "Algeria";
  int? bloodTypeId = 0;
  double? locationLatitude = 0;
  double? locationLongitude = 0;
  String? locationName = "";
  String? addressStreet = "";
  String? addressCity = "";
  String? addressPostalCode = "";
  String? addressCountry = "Algeria";

  final TextEditingController _birthDateController = TextEditingController();
  DateTime? selectedDate;

  final List<Map<String, String>> countries = [
    {"name": "Afghanistan", "native": "افغانستان"},
    {"name": "Albania", "native": "Shqipëri"},
    {"name": "Algeria", "native": "الجزائر"},
    {"name": "Andorra", "native": "Andorra"},
    {"name": "Angola", "native": "Angola"},
    {"name": "Argentina", "native": "Argentina"},
    {"name": "Armenia", "native": "Հայաստան"},
    {"name": "Australia", "native": "Australia"},
    {"name": "Austria", "native": "Österreich"},
    {"name": "Azerbaijan", "native": "Azərbaycan"},
    {"name": "Bahamas", "native": "Bahamas"},
    {"name": "Bahrain", "native": "البحرين"},
    {"name": "Bangladesh", "native": "বাংলাদেশ"},
    {"name": "Belarus", "native": "Беларусь"},
    {"name": "Belgium", "native": "België"},
    {"name": "Benin", "native": "Bénin"},
    {"name": "Bhutan", "native": "འབྲུག"},
    {"name": "Bolivia", "native": "Bolivia"},
    {"name": "Bosnia and Herzegovina", "native": "Bosna i Hercegovina"},
    {"name": "Botswana", "native": "Botswana"},
    {"name": "Brazil", "native": "Brasil"},
    {"name": "Brunei", "native": "بروني"},
    {"name": "Bulgaria", "native": "България"},
    {"name": "Burkina Faso", "native": "Burkina Faso"},
    {"name": "Burundi", "native": "Uburundi"},
    {"name": "Cambodia", "native": "កម្ពុជា"},
    {"name": "Cameroon", "native": "Cameroun"},
    {"name": "Canada", "native": "Canada"},
    {"name": "Cape Verde", "native": "Cabo Verde"},
    {"name": "Central African Republic", "native": "République Centrafricaine"},
    {"name": "Chad", "native": "تشاد"},
    {"name": "Chile", "native": "Chile"},
    {"name": "China", "native": "中国"},
    {"name": "Colombia", "native": "Colombia"},
    {"name": "Comoros", "native": "Komori"},
    {"name": "Congo (Congo-Brazzaville)", "native": "Congo"},
    {"name": "Costa Rica", "native": "Costa Rica"},
    {"name": "Croatia", "native": "Hrvatska"},
    {"name": "Cuba", "native": "Cuba"},
    {"name": "Cyprus", "native": "Κύπρος"},
    {"name": "Czech Republic", "native": "Česká republika"},
    {"name": "Denmark", "native": "Danmark"},
    {"name": "Djibouti", "native": "جيبوتي"},
    {"name": "Dominica", "native": "Dominica"},
    {"name": "Dominican Republic", "native": "República Dominicana"},
    {"name": "Ecuador", "native": "Ecuador"},
    {"name": "Egypt", "native": "مصر"},
    {"name": "El Salvador", "native": "El Salvador"},
    {"name": "Equatorial Guinea", "native": "Guinea Ecuatorial"},
    {"name": "Eritrea", "native": "إريتريا"},
    {"name": "Estonia", "native": "Eesti"},
    {"name": "Eswatini", "native": "Eswatini"},
    {"name": "Ethiopia", "native": "ኢትዮጵያ"},
    {"name": "Fiji", "native": "Fiji"},
    {"name": "Finland", "native": "Suomi"},
    {"name": "France", "native": "France"},
    {"name": "Gabon", "native": "Gabon"},
    {"name": "Gambia", "native": "The Gambia"},
    {"name": "Georgia", "native": "საქართველო"},
    {"name": "Germany", "native": "Deutschland"},
    {"name": "Ghana", "native": "Ghana"},
    {"name": "Greece", "native": "Ελλάδα"},
    {"name": "Grenada", "native": "Grenada"},
    {"name": "Guatemala", "native": "Guatemala"},
    {"name": "Guinea", "native": "Guinée"},
    {"name": "Guinea-Bissau", "native": "Guiné-Bissau"},
    {"name": "Guyana", "native": "Guyana"},
    {"name": "Haiti", "native": "Haïti"},
    {"name": "Honduras", "native": "Honduras"},
    {"name": "Hungary", "native": "Magyarország"},
    {"name": "Iceland", "native": "Ísland"},
    {"name": "India", "native": "भारत"},
    {"name": "Indonesia", "native": "Indonesia"},
    {"name": "Iran", "native": "ایران"},
    {"name": "Iraq", "native": "العراق"},
    {"name": "Ireland", "native": "Éire"},
    // {"name": "Israel", "native": "יִשְׂרָאֵל"},
    {"name": "Italy", "native": "Italia"},
    {"name": "Jamaica", "native": "Jamaica"},
    {"name": "Japan", "native": "日本"},
    {"name": "Jordan", "native": "الأردن"},
    {"name": "Kazakhstan", "native": "Қазақстан"},
    {"name": "Kenya", "native": "Kenya"},
    {"name": "Kiribati", "native": "Kiribati"},
    {"name": "Kuwait", "native": "الكويت"},
    {"name": "Kyrgyzstan", "native": "Кыргызстан"},
    {"name": "Laos", "native": "ສ.ປ.ປ ລາວ"},
    {"name": "Latvia", "native": "Latvija"},
    {"name": "Lebanon", "native": "لبنان"},
    {"name": "Lesotho", "native": "Lesotho"},
    {"name": "Liberia", "native": "Liberia"},
    {"name": "Libya", "native": "ليبيا"},
    {"name": "Liechtenstein", "native": "Liechtenstein"},
    {"name": "Lithuania", "native": "Lietuva"},
    {"name": "Luxembourg", "native": "Luxembourg"},
    {"name": "Madagascar", "native": "Madagasikara"},
    {"name": "Malawi", "native": "Malawi"},
    {"name": "Malaysia", "native": "Malaysia"},
    {"name": "Maldives", "native": "ދިވެހި"},
    {"name": "Mali", "native": "Mali"},
    {"name": "Malta", "native": "Malta"},
    {"name": "Marshall Islands", "native": "Aolepān Aorōkin M̧ajeļ"},
    {"name": "Mauritania", "native": "موريتانيا"},
    {"name": "Mauritius", "native": "Maurice"},
    {"name": "Mexico", "native": "México"},
    {"name": "Micronesia", "native": "Micronesia"},
    {"name": "Moldova", "native": "Moldova"},
    {"name": "Monaco", "native": "Monaco"},
    {"name": "Mongolia", "native": "Монгол Улс"},
    {"name": "Montenegro", "native": "Crna Gora"},
    {"name": "Morocco", "native": "المغرب"},
    {"name": "Mozambique", "native": "Moçambique"},
    {"name": "Myanmar", "native": "မြန်မာ"},
    {"name": "Namibia", "native": "Namibia"},
    {"name": "Nauru", "native": "Nauru"},
    {"name": "Nepal", "native": "नेपाल"},
    {"name": "Netherlands", "native": "Nederland"},
    {"name": "New Zealand", "native": "Aotearoa"},
    {"name": "Nicaragua", "native": "Nicaragua"},
    {"name": "Niger", "native": "Niger"},
    {"name": "Nigeria", "native": "Nigeria"},
    {"name": "North Korea", "native": "조선"},
    {"name": "North Macedonia", "native": "Северна Македонија"},
    {"name": "Norway", "native": "Norge"},
    {"name": "Oman", "native": "عمان"},
    {"name": "Pakistan", "native": "پاکستان"},
    {"name": "Palau", "native": "Belau"},
    {"name": "Palestine", "native": "فلسطين"},
    {"name": "Panama", "native": "Panamá"},
    {"name": "Papua New Guinea", "native": "Papua Niugini"},
    {"name": "Paraguay", "native": "Paraguay"},
    {"name": "Peru", "native": "Perú"},
    {"name": "Philippines", "native": "Pilipinas"},
    {"name": "Poland", "native": "Polska"},
    {"name": "Portugal", "native": "Portugal"},
    {"name": "Qatar", "native": "قطر"},
    {"name": "Romania", "native": "România"},
    {"name": "Rwanda", "native": "Rwanda"},
    {"name": "Saint Kitts and Nevis", "native": "Saint Kitts and Nevis"},
    {"name": "Saint Lucia", "native": "Saint Lucia"},
    {
      "name": "Saint Vincent and the Grenadines",
      "native": "Saint Vincent and the Grenadines"
    },
    {"name": "Samoa", "native": "Samoa"},
    {"name": "San Marino", "native": "San Marino"},
    {"name": "Sao Tome and Principe", "native": "São Tomé e Príncipe"},
    {"name": "Saudi Arabia", "native": "السعودية"},
    {"name": "Senegal", "native": "Sénégal"},
    {"name": "Serbia", "native": "Србија"},
    {"name": "Seychelles", "native": "Sesel"},
    {"name": "Sierra Leone", "native": "Sierra Leone"},
    {"name": "Singapore", "native": "Singapore"},
    {"name": "Slovakia", "native": "Slovensko"},
    {"name": "Slovenia", "native": "Slovenija"},
    {"name": "Solomon Islands", "native": "Solomon Islands"},
    {"name": "Somalia", "native": "Soomaaliya"},
    {"name": "South Africa", "native": "South Africa"},
    {"name": "South Korea", "native": "대한민국"},
    {"name": "South Sudan", "native": "جنوب السودان"},
    {"name": "Sri Lanka", "native": "ශ්‍රී ලංකාව"},
    {"name": "Sudan", "native": "السودان"},
    {"name": "Suriname", "native": "Suriname"},
    {"name": "Sweden", "native": "Sverige"},
    {"name": "Switzerland", "native": "Schweiz"},
    {"name": "Syria", "native": "سوريا"},
    {"name": "Tajikistan", "native": "Тоҷикистон"},
    {"name": "Tanzania", "native": "Tanzania"},
    {"name": "Thailand", "native": "ประเทศไทย"},
    {"name": "Timor-Leste", "native": "Timor-Leste"},
    {"name": "Togo", "native": "Togo"},
    {"name": "Tonga", "native": "Tonga"},
    {"name": "Trinidad and Tobago", "native": "Trinidad and Tobago"},
    {"name": "Tunisia", "native": "تونس"},
    {"name": "Turkey", "native": "Türkiye"},
    {"name": "Turkmenistan", "native": "Türkmenistan"},
    {"name": "Tuvalu", "native": "Tuvalu"},
    {"name": "Uganda", "native": "Uganda"},
    {"name": "Ukraine", "native": "Україна"},
    {"name": "United Arab Emirates", "native": "الإمارات العربية المتحدة"},
    {"name": "United Kingdom", "native": "United Kingdom"},
    {"name": "United States", "native": "United States"},
    {"name": "Uruguay", "native": "Uruguay"},
    {"name": "Uzbekistan", "native": "Oʻzbekiston"},
    {"name": "Vanuatu", "native": "Vanuatu"},
    {"name": "Vatican City", "native": "Vaticano"},
    {"name": "Venezuela", "native": "Venezuela"},
    {"name": "Vietnam", "native": "Việt Nam"},
    {"name": "Yemen", "native": "اليمن"},
    {"name": "Zambia", "native": "Zambia"},
    {"name": "Zimbabwe", "native": "Zimbabwe"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registerationFormText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.usernameText),
                onSaved: (value) {
                  appUserName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseInputusernameMsg;
                  }
                  return null;
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.passwordText),
                obscureText: true,
                onSaved: (value) {
                  appUserPassword = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseInputpasswordMsg;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.userTypeText),
                items: [
                  {
                    'value': 1,
                    'label': AppLocalizations.of(context)!.clientText
                  },
                  {
                    'value': 3,
                    'label': AppLocalizations.of(context)!.cookingChefText
                  }
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
                    return AppLocalizations.of(context)!.pleaseInputUserTypeMsg;
                  }
                  return null;
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.firstNameText),
                onSaved: (value) {
                  personFirstName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputFirstNameMsg;
                  }
                  return null;
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              TextFormField(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.lastNameText),
                onSaved: (value) {
                  personLastName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseInputLastNameMsg;
                  }
                  return null;
                },
              ),
              const Padding(padding: EdgeInsets.all(8.0)),
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.birthdayText,
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
                    return AppLocalizations.of(context)!
                        .pleaseInputBirthdateMsg;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.genderText),
                items: AppLocalizations.of(context)!
                    .genderTextList
                    .split(",")
                    .map((String value) {
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
                    return AppLocalizations.of(context)!.pleaseInputgenderMsg;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.nationalityText),
                items: countries.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['name'],
                    child: Text("${country['native']}"),
                  );
                }).toList(),
                onChanged: (value) {
                  personNationality = value;
                },
                value: personNationality,
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!
                        .pleaseInputnationalityMsg;
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.bloodTypeText),
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
                    return AppLocalizations.of(context)!
                        .pleaseInputBloodTypeMsg;
                  }
                  return null;
                },
              ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: AppLocalizations.of(context)!.latitudeText),
              //   keyboardType: TextInputType.number,
              //   onSaved: (value) {
              //     locationLatitude = double.tryParse(value ?? '');
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: AppLocalizations.of(context)!.longitudeText),
              //   keyboardType: TextInputType.number,
              //   onSaved: (value) {
              //     locationLongitude = double.tryParse(value ?? '');
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: AppLocalizations.of(context)!.locationNameText),
              //   onSaved: (value) {
              //     locationName = value;
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: AppLocalizations.of(context)!.streetText),
              //   onSaved: (value) {
              //     addressStreet = value;
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: AppLocalizations.of(context)!.cityText),
              //   onSaved: (value) {
              //     addressCity = value;
              //   },
              // ),
              // Padding(padding: const EdgeInsets.all(8.0)),
              // TextFormField(
              //   decoration: InputDecoration(labelText: AppLocalizations.of(context)!.postalCodeText),
              //   onSaved: (value) {
              //     addressPostalCode = value;
              //   },
              // ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!
                      .countryText, // Replace with localized text if needed
                ),
                value: addressCountry,
                items: countries.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['name'],
                    child: Text("${country['native']}"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    addressCountry = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return AppLocalizations.of(context)!
                        .pleaseInputCountryMsg; // Replace with localized text if needed
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
                        "app_user_preferences": "", // ✅ Added
                        "app_user_image": "" // ✅ Added
                      },
                      "person": {
                        "id_person": 0,
                        "person_details_id": 0, // ✅ Ensure this field exists
                        "id_person_details": 0, // ✅ Kept only one
                        "person_first_name": personFirstName ?? "",
                        "person_last_name": personLastName ?? "",
                        "person_birth_date":
                            _birthDateController.text.isNotEmpty
                                ? _birthDateController.text
                                : "2000-01-01", // ✅ Ensured valid date format
                        "person_gender": personGender ?? "", // ✅ Ensured string
                        "person_nationality": personNationality ?? "Unknown",
                        "id_blood_type": bloodTypeId ?? 0
                      },
                      "location": {
                        "id_location": 0,
                        "id_address": 0, // ✅ Ensure this field exists
                        "location_address_id": 0, // ✅ Removed "id_address"
                        "location_latitude": locationLatitude ?? 0.0,
                        "location_longitude": locationLongitude ?? 0.0,
                        "location_name": locationName ?? "",
                        "address_street": addressStreet ?? "",
                        "address_city": addressCity ?? "",
                        "address_postal_code": addressPostalCode ?? "00000",
                        "address_country": addressCountry ?? "Unknown"
                      }
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
                          SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(AppLocalizations.of(context)!
                                  .loginSuccessfullMsg)),
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
                child: Text(AppLocalizations.of(context)!.registerText),
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
