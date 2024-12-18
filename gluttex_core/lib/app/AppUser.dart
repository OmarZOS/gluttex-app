import 'dart:convert';
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
    if (json['app_user_image'] != null && json['app_user_image']!.isNotEmpty) {
      final imageBase64 = json['app_user_image'];
      if (imageBase64 != null && imageBase64 != "" && imageBase64 != "string") {
        imageData = base64Decode(imageBase64);
      }
    }

    var id_blood_type;
    var blood_type_desc;
    var person_birth_date;
    var id_person_details;
    var person_nationality;
    var person_first_name;
    var person_last_name;
    var person_gender;
    var location_latitude;
    var location_longitude;
    var location_address_id;
    var location_name;
    var address_city;
    var address_street;
    var address_country;
    var address_postal_code;

    var app_user_person = json['app_user_person'];
    if (app_user_person != null && app_user_person.isNotEmpty) {
      var person_blood_type = app_user_person["person_blood_type"];
      if (person_blood_type != null && person_blood_type.isNotEmpty) {
        id_blood_type = person_blood_type["id_blood_type"];
        blood_type_desc = person_blood_type["blood_type_desc"];
      }

      var person_details = app_user_person['person_details'];
      if (person_details != null && person_details.isNotEmpty) {
        person_birth_date = person_details['person_birth_date'];
        id_person_details = person_details['id_person_details'];
        person_nationality = person_details['person_nationality'];
        person_first_name = person_details['person_first_name'];
        person_last_name = person_details['person_last_name'];
        person_gender = person_details['person_gender'];
      }

      var person_location = app_user_person['person_location'];
      if (person_location != null && person_location.isNotEmpty) {
        location_latitude = person_location["location_latitude"];
        location_longitude = person_location["location_longitude"];
        location_address_id = person_location["location_address_id"];
        location_name = person_location["location_name"];

        var location_address = person_location['location_address'];
        if (location_address != null && location_address.isNotEmpty) {
          address_city = location_address['address_city'];
          address_street = location_address['address_street'];
          address_country = location_address['address_country'];
          address_postal_code = location_address['address_postal_code'];
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
      personDetailsId: id_person_details ?? 0,
      personFirstName: person_first_name ?? "",
      personLastName: person_last_name ?? "",
      personBirthDate: person_birth_date ?? "",
      personGender: person_gender ?? "",
      personNationality: person_nationality ?? "",
      idBloodType: id_blood_type ?? 0,
      idLocation: json['idLocation'] ?? 0,
      locationLatitude: location_latitude ?? 0.0,
      locationLongitude: location_longitude ?? 0.0,
      locationName: location_name ?? "",
      locationAddressId: location_address_id ?? 0,
      addressStreet: address_street ?? "",
      addressCity: address_city ?? "",
      addressPostalCode: address_postal_code ?? "",
      addressCountry: address_country ?? "",
      bloodTypeDesc: blood_type_desc ?? "",
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
