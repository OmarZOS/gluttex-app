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

    var idBloodType;
    var bloodTypeDesc;
    var personBirthDate;
    var idPersonDetails;
    var personNationality;
    var personFirstName;
    var personLastName;
    var personGender;
    var locationLatitude;
    var locationLongitude;
    var locationAddressId;
    var locationName;
    var addressCity;
    var addressStreet;
    var addressCountry;
    var addressPostalCode;

    var appUserPerson = json['app_user_person'];
    if (appUserPerson != null && appUserPerson.isNotEmpty) {
      var personBloodType = appUserPerson["person_blood_type"];
      if (personBloodType != null && personBloodType.isNotEmpty) {
        idBloodType = personBloodType["id_blood_type"];
        bloodTypeDesc = personBloodType["blood_type_desc"];
      }

      var personDetails = appUserPerson['person_details'];
      if (personDetails != null && personDetails.isNotEmpty) {
        personBirthDate = personDetails['person_birth_date'];
        idPersonDetails = personDetails['id_person_details'];
        personNationality = personDetails['person_nationality'];
        personFirstName = personDetails['person_first_name'];
        personLastName = personDetails['person_last_name'];
        personGender = personDetails['person_gender'];
      }

      var personLocation = appUserPerson['person_location'];
      if (personLocation != null && personLocation.isNotEmpty) {
        locationLatitude = personLocation["location_latitude"];
        locationLongitude = personLocation["location_longitude"];
        locationAddressId = personLocation["location_address_id"];
        locationName = personLocation["location_name"];

        var locationAddress = personLocation['location_address'];
        if (locationAddress != null && locationAddress.isNotEmpty) {
          addressCity = locationAddress['address_city'];
          addressStreet = locationAddress['address_street'];
          addressCountry = locationAddress['address_country'];
          addressPostalCode = locationAddress['address_postal_code'];
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
      personDetailsId: idPersonDetails ?? 0,
      personFirstName: personFirstName ?? "",
      personLastName: personLastName ?? "",
      personBirthDate: personBirthDate ?? "",
      personGender: personGender ?? "",
      personNationality: personNationality ?? "",
      idBloodType: idBloodType ?? 0,
      idLocation: json['idLocation'] ?? 0,
      locationLatitude: locationLatitude ?? 0.0,
      locationLongitude: locationLongitude ?? 0.0,
      locationName: locationName ?? "",
      locationAddressId: locationAddressId ?? 0,
      addressStreet: addressStreet ?? "",
      addressCity: addressCity ?? "",
      addressPostalCode: addressPostalCode ?? "",
      addressCountry: addressCountry ?? "",
      bloodTypeDesc: bloodTypeDesc ?? "",
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
