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

  // final Uint8List? app_user_image;
  final String? app_user_image_url;
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

  get isAdmin => app_user_type_id == 3; // Assuming 3 is the admin type ID

  AppUser({
    required this.id_app_user,
    required this.app_user_person_id,
    required this.app_user_type_id,
    required this.app_user_name,
    required this.app_user_password,
    required this.app_user_preferences,
    required this.app_user_type_desc,
    // required this.app_user_image,
    required this.app_user_image_url,
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
  AppUser copyWith({
    Uint8List? app_user_image,
    String? app_user_image_url,
    String? personFirstName,
    int? id_app_user,
    int? app_user_person_id,
    int? app_user_type_id,
    String? app_user_name,
    String? app_user_password,
    String? app_user_preferences,
    String? app_user_type_desc,
    int? idPerson,
    int? personDetailsId,
    String? personLastName,
    String? personBirthDate,
    String? personGender,
    String? personNationality,
    int? idBloodType,
    String? bloodTypeDesc,
    int? idLocation,
    double? locationLatitude,
    double? locationLongitude,
    String? locationName,
    int? locationAddressId,
    String? addressStreet,
    String? addressCity,
    String? addressPostalCode,
    String? addressCountry,
    // ... all other fields
  }) {
    return AppUser(
      // app_user_image: app_user_image ?? this.app_user_image,
      app_user_image_url: app_user_image_url ?? this.app_user_image_url,
      personFirstName: personFirstName ?? this.personFirstName,
      id_app_user: id_app_user ?? this.id_app_user,
      app_user_person_id: app_user_person_id ?? this.app_user_person_id,
      app_user_type_id: app_user_type_id ?? this.app_user_type_id,
      app_user_name: app_user_name ?? this.app_user_name,
      app_user_password: app_user_password ?? this.app_user_password,
      app_user_preferences: app_user_preferences ?? this.app_user_preferences,
      app_user_type_desc: app_user_type_desc ?? this.app_user_type_desc,
      idPerson: idPerson ?? this.idPerson,
      personDetailsId: personDetailsId ?? this.personDetailsId,
      personLastName: personLastName ?? this.personLastName,
      personBirthDate: personBirthDate ?? this.personBirthDate,
      personGender: personGender ?? this.personGender,
      personNationality: personNationality ?? this.personNationality,
      idBloodType: idBloodType ?? this.idBloodType,
      idLocation: idLocation ?? this.idLocation,
      locationLatitude: locationLatitude ?? this.locationLatitude,
      locationLongitude: locationLongitude ?? this.locationLongitude,
      locationName: locationName ?? this.locationName,
      locationAddressId: locationAddressId ?? this.locationAddressId,
      addressStreet: addressStreet ?? this.addressStreet,
      addressCity: addressCity ?? this.addressCity,
      addressPostalCode: addressPostalCode ?? this.addressPostalCode,
      addressCountry: addressCountry ?? this.addressCountry,
      bloodTypeDesc: bloodTypeDesc ?? this.bloodTypeDesc,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Uint8List? imageData;
    // if (json['app_user_image'] != null && json['app_user_image']!.isNotEmpty) {
    //   final imageBase64 = json['app_user_image'];
    //   if (imageBase64 != null && imageBase64 != "" && imageBase64 != "string") {
    //     imageData = base64Decode(imageBase64);
    //   }
    // }

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
      // app_user_image: imageData,
      app_user_image_url: json['app_user_image_url'] ?? "",
      idPerson: json['idPerson'] ?? 0,
      personDetailsId: idPersonDetails ?? 0,
      personFirstName: personFirstName ?? "",
      personLastName: personLastName ?? "",
      personBirthDate: personBirthDate ?? "",
      personGender: personGender ?? "",
      personNationality: personNationality ?? "",
      idBloodType: idBloodType ?? 0,
      idLocation: json['app_user_person']?["person_location_id"] ?? 0,
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

  factory AppUser.fromGoogleJson(Map<String, dynamic> json) {
    // Extract user data from the Google response
    final userData = json['user'];
    final tokenData = json['token'];
    final userInfo = tokenData?['userinfo'] ?? {};

    // Extract basic user information
    final idAppUser = userData?['id_app_user'] ?? 0;
    final appUserName = userData?['app_user_name'] ?? userInfo['email'] ?? "";
    final appUserImageUrl =
        userData?['app_user_image_url'] ?? userInfo['picture'] ?? "";
    final appUserTypeId = userData?['app_user_type_id'] ?? 0;

    // Extract person information from userinfo
    final givenName = userInfo['given_name'] ?? "";
    final familyName = userInfo['family_name'] ?? "";
    final fullName = userInfo['name'] ?? "$givenName $familyName".trim();
    final email = userInfo['email'] ?? appUserName;
    final emailVerified = userInfo['email_verified'] ?? false;

    // Split full name into first and last names if not provided separately
    String personFirstName = givenName;
    String personLastName = familyName;

    if (personFirstName.isEmpty &&
        personLastName.isEmpty &&
        fullName.isNotEmpty) {
      final nameParts = fullName.split(' ');
      personFirstName = nameParts.first;
      personLastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }

    return AppUser(
      id_app_user: idAppUser,
      app_user_person_id: userData?['app_user_person_id'] ?? 0,
      app_user_type_id: appUserTypeId,
      app_user_name: appUserName,
      app_user_password:
          userData?['app_user_password'] ?? "", // Empty for social logins
      app_user_preferences: userData?['app_user_preferences'] ?? "",
      app_user_type_desc:
          "", // You might need to map this based on app_user_type_id
      app_user_image_url: appUserImageUrl,

      // Person details from Google userinfo
      idPerson: 0, // This will likely be set by your backend
      personDetailsId: 0, // This will likely be set by your backend
      personFirstName: personFirstName,
      personLastName: personLastName,
      personBirthDate: "", // Google doesn't provide birthdate by default
      personGender: "", // Google doesn't provide gender by default
      personNationality: "", // Google doesn't provide nationality by default

      // Location information (not provided by Google)
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
      bloodTypeDesc: "",
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
      // app_user_image: null,
      app_user_image_url: "",
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
    double _locationLatitude = 36.42;
    double _locationLongitude = 3.05;
    if (locationLatitude != 0 && locationLongitude != 0) {
      _locationLatitude = locationLatitude;
      _locationLongitude = locationLongitude;
    }

    return {
      "user": {
        "id_app_user": id_app_user,
        "app_user_name": app_user_name,
        "app_user_password": app_user_password,
        "app_user_person_id": personDetailsId,
        "app_user_preferences": app_user_preferences,
        "app_user_image_url": app_user_image_url,
        "app_user_type_id": app_user_type_id
      },
      "person_record": {
        "id_person": app_user_person_id,
        "person_details_id": personDetailsId,
        "id_person_details": personDetailsId,
        "person_first_name": personFirstName,
        "person_last_name": personLastName,
        "person_birth_date": personBirthDate,
        "person_gender": personGender,
        "person_nationality": personNationality,
        "id_blood_type": idBloodType
      },
      "location_record": {
        "id_location": idLocation,
        "location_latitude": _locationLatitude,
        "location_longitude": _locationLongitude,
        "location_name": locationName,
        "location_address_id": locationAddressId,
        "id_address": locationAddressId,
        "address_street": addressStreet,
        "address_city": addressCity,
        "address_postal_code": addressPostalCode,
        "address_country": addressCountry
      }
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
