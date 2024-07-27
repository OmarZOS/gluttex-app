import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

class AppUser {
  final int? id_app_user;
  final int? app_user_person_id;
  final int? app_user_type_id;
  final String? app_user_name;
  final String? app_user_password;
  final String? app_user_preferences;
  final String? app_user_type_desc;
  final Uint8List? app_user_image;
  final int idPerson;
  final int personDetailsId;
  final String personFirstName;
  final String personLastName;
  final String personBirthDate;
  final String personGender;
  final String personNationality;
  final int idBloodType;
  final String bloodTypeDesc;
  final int idLocation;
  final double locationLatitude;
  final double locationLongitude;
  final String locationName;
  final int locationAddressId;
  final String addressStreet;
  final String addressCity;
  final String addressPostalCode;
  final String addressCountry;

  AppUser({
    required this.id_app_user,
    required this.app_user_person_id,
    required this.app_user_type_id,
    required this.app_user_name,
    required this.app_user_password,
    required this.app_user_preferences,
    required this.app_user_type_desc,
    required this.app_user_image,
    required this.idPerson,
    required this.personDetailsId,
    required this.personFirstName,
    required this.personLastName,
    required this.personBirthDate,
    required this.personGender,
    required this.personNationality,
    required this.idBloodType,
    required this.bloodTypeDesc,
    required this.idLocation,
    required this.locationLatitude,
    required this.locationLongitude,
    required this.locationName,
    required this.locationAddressId,
    required this.addressStreet,
    required this.addressCity,
    required this.addressPostalCode,
    required this.addressCountry,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    Uint8List? imageData;
    log("= json['app_user_image']");
    if (json['app_user_image'] != null && json['app_user_image']!.isNotEmpty) {
      final imageBase64 = json['app_user_image'];
      if (imageBase64 != null && imageBase64 != "" && imageBase64 != "string") {
        imageData = base64Decode(imageBase64);
      }
    }

    var _id_blood_type;
    var _blood_type_desc;
    var _person_birth_date;
    var _id_person_details;
    var _person_nationality;
    var _person_first_name;
    var _person_last_name;
    var _person_gender;
    var _location_latitude;
    var _location_longitude;
    var _location_address_id;
    var _location_name;
    var _address_city;
    var _address_street;
    var _address_country;
    var _address_postal_code;

    log("= json['app_user_person']");
    var _app_user_person = json['app_user_person'];
    if (_app_user_person != null && _app_user_person.isNotEmpty) {
      var _person_blood_type = _app_user_person["person_blood_type"];
      if (_person_blood_type != null && _person_blood_type.isNotEmpty) {
        _id_blood_type = _person_blood_type["id_blood_type"];
        _blood_type_desc = _person_blood_type["blood_type_desc"];
      }

      var _person_details = _app_user_person['person_details'];
      if (_person_details != null && _person_details.isNotEmpty) {
        _person_birth_date = _person_details['person_birth_date'];
        _id_person_details = _person_details['id_person_details'];
        _person_nationality = _person_details['person_nationality'];
        _person_first_name = _person_details['person_first_name'];
        _person_last_name = _person_details['person_last_name'];
        _person_gender = _person_details['person_gender'];
      }

      var _person_location = _app_user_person['person_location'];
      if (_person_location != null && _person_location.isNotEmpty) {
        _location_latitude = _person_location["location_latitude"];
        _location_longitude = _person_location["location_longitude"];
        _location_address_id = _person_location["location_address_id"];
        _location_name = _person_location["location_name"];

        var _location_address = _person_location['location_address'];
        if (_location_address != null && _location_address.isNotEmpty) {
          _address_city = _location_address['address_city'];
          _address_street = _location_address['address_street'];
          _address_country = _location_address['address_country'];
          _address_postal_code = _location_address['address_postal_code'];
        }
      }
    }

    return AppUser(
      id_app_user: json['id_app_user'] ?? 0,
      app_user_person_id: json['app_user_person_id'] ?? 0,
      app_user_type_id: json['app_user_type_id'] ?? 0,
      app_user_name: json['app_user_name'] ?? "",
      app_user_password: json['app_user_password'] ?? "",
      app_user_preferences: json['app_user_preferences'] ?? "",
      app_user_type_desc: json['app_user_type']?['app_user_type_desc'] ?? "",
      app_user_image: imageData,
      idPerson: json['idPerson'] ?? 0,
      personDetailsId: _id_person_details ?? 0,
      personFirstName: _person_first_name ?? "",
      personLastName: _person_last_name ?? "",
      personBirthDate: _person_birth_date ?? "",
      personGender: _person_gender ?? "",
      personNationality: _person_nationality ?? "",
      idBloodType: _id_blood_type ?? 0,
      idLocation: json['idLocation'] ?? 0,
      locationLatitude: _location_latitude ?? 0.0,
      locationLongitude: _location_longitude ?? 0.0,
      locationName: _location_name ?? "",
      locationAddressId: _location_address_id ?? 0,
      addressStreet: _address_street ?? "",
      addressCity: _address_city ?? "",
      addressPostalCode: _address_postal_code ?? "",
      addressCountry: _address_country ?? "",
      bloodTypeDesc: _blood_type_desc ?? "",
    );
  }

  factory AppUser.empty() {
    return AppUser(
      id_app_user: 0,
      app_user_person_id: 0,
      app_user_type_id: 0,
      app_user_name: "",
      app_user_password: "",
      app_user_preferences: "",
      app_user_type_desc: "",
      app_user_image: null,
      idPerson: 0,
      personDetailsId: 0,
      personFirstName: "",
      personLastName: "",
      personBirthDate: "",
      personGender: "",
      personNationality: "",
      idBloodType: 0,
      idLocation: 0,
      locationLatitude: 0.0,
      locationLongitude: 0.0,
      locationName: "",
      locationAddressId: 0,
      addressStreet: "",
      addressCity: "",
      addressPostalCode: "",
      addressCountry: "",
      bloodTypeDesc: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_app_user': id_app_user,
      'app_user_person_id': app_user_person_id,
      'app_user_type_id': app_user_type_id,
      'app_user_name': app_user_name,
      'app_user_password': app_user_password,
      'app_user_preferences': app_user_preferences,
      'app_user_type_desc': app_user_type_desc,
      'app_user_image': app_user_image
    };
  }
}

class AppUserCategory {
  final int id_app_user_type;
  final String app_user_type_desc;
  AppUserCategory(
      {required this.id_app_user_type, required this.app_user_type_desc});

  factory AppUserCategory.fromJson(Map<String, dynamic> json) {
    return AppUserCategory(
        id_app_user_type: json['id_app_user_type'] ?? 0,
        app_user_type_desc: json['app_user_type_desc'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'id_app_user_type': id_app_user_type,
      'app_user_type_desc': app_user_type_desc,
    };
  }
}
