class Person {
  final int id;
  final int? personDetailsId;
  final int? bloodTypeId;
  final int? locationId;
  final PersonDetails? details;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Person({
    required this.id,
    this.personDetailsId,
    this.bloodTypeId,
    this.locationId,
    this.details,
    this.createdAt,
    this.updatedAt,
  });

  // Get full name
  String get fullName =>
      '${details?.firstName ?? ''} ${details?.lastName ?? ''}'.trim();

  // Get first name
  String? get firstName => details?.firstName;

  // Get last name
  String? get lastName => details?.lastName;

  // Get gender
  String? get gender => details?.gender;

  // Get nationality
  String? get nationality => details?.nationality;

  // Get birth date
  DateTime? get birthDate => details?.birthDate;

  // Get age (if birth date is available)
  int? get age {
    if (details?.birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - details!.birthDate!.year;
    if (now.month < details!.birthDate!.month ||
        (now.month == details!.birthDate!.month &&
            now.day < details!.birthDate!.day)) {
      age--;
    }
    return age;
  }

  // Check if person is adult (18+ years)
  bool get isAdult {
    final currentAge = age;
    return currentAge != null && currentAge >= 18;
  }

  // Factory constructor from JSON
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id_person'] as int,
      personDetailsId: json['person_details_id'] as int?,
      bloodTypeId: json['person_blood_type_id'] as int?,
      locationId: json['person_location_id'] as int?,
      details: json['person_details'] != null
          ? PersonDetails.fromJson(json['person_details'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_person': id,
      'person_details_id': personDetailsId,
      'person_blood_type_id': bloodTypeId,
      'person_location_id': locationId,
      'person_details': details?.toJson(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Copy with method
  Person copyWith({
    int? id,
    int? personDetailsId,
    int? bloodTypeId,
    int? locationId,
    PersonDetails? details,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Person(
      id: id ?? this.id,
      personDetailsId: personDetailsId ?? this.personDetailsId,
      bloodTypeId: bloodTypeId ?? this.bloodTypeId,
      locationId: locationId ?? this.locationId,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Empty person factory
  factory Person.empty() {
    return Person(
      id: 0,
      personDetailsId: null,
      bloodTypeId: null,
      locationId: null,
      details: null,
      createdAt: null,
      updatedAt: null,
    );
  }

  // Check if person is empty (has only ID 0)
  bool get isEmpty => id == 0;

  // Check if person has basic information
  bool get hasBasicInfo => details != null && details!.hasName;

  // Get display name (full name or "Unknown Person")
  String get displayName {
    if (hasBasicInfo) return fullName;
    return 'Unknown Person #$id';
  }

  // Get initials for avatar
  String get initials {
    if (!hasBasicInfo) return '?';
    final firstInitial =
        details!.firstName?.isNotEmpty == true ? details!.firstName![0] : '';
    final lastInitial =
        details!.lastName?.isNotEmpty == true ? details!.lastName![0] : '';
    return (firstInitial + lastInitial).toUpperCase();
  }

  // Get gender icon
  String get genderIcon {
    switch (details?.gender?.toLowerCase()) {
      case 'male':
        return '♂';
      case 'female':
        return '♀';
      default:
        return '?';
    }
  }

  // Get formatted birth date
  String? get formattedBirthDate {
    if (details?.birthDate == null) return null;
    return '${details!.birthDate!.day}/${details!.birthDate!.month}/${details!.birthDate!.year}';
  }

  @override
  String toString() {
    return 'Person(id: $id, name: "$fullName", gender: $gender, nationality: $nationality)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class PersonDetails {
  final int id;
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;
  final String? gender;
  final String? nationality;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PersonDetails({
    required this.id,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.gender,
    this.nationality,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Check if has name
  bool get hasName =>
      (firstName?.isNotEmpty == true) || (lastName?.isNotEmpty == true);

  // Get full name
  String get fullName => '$firstName $lastName'.trim();

  // Get formatted phone number
  String? get formattedPhone {
    if (phone == null || phone!.isEmpty) return null;
    // Simple formatting - you can customize this
    if (phone!.length == 10) {
      return '${phone!.substring(0, 4)}-${phone!.substring(4, 7)}-${phone!.substring(7)}';
    }
    return phone;
  }

  // Get address line
  String? get addressLine {
    if (address == null && city == null && country == null) return null;

    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (country != null) parts.add(country!);

    return parts.join(', ');
  }

  // Factory constructor from JSON
  factory PersonDetails.fromJson(Map<String, dynamic> json) {
    return PersonDetails(
      id: json['id_person_details'] as int,
      firstName: json['person_first_name'] as String?,
      lastName: json['person_last_name'] as String?,
      birthDate: json['person_birth_date'] != null
          ? DateTime.tryParse(json['person_birth_date'] as String)
          : null,
      gender: json['person_gender'] as String?,
      nationality: json['person_nationality'] as String?,
      email: json['person_email'] as String?,
      phone: json['person_phone'] as String?,
      address: json['person_address'] as String?,
      city: json['person_city'] as String?,
      postalCode: json['person_postal_code'] as String?,
      country: json['person_country'] as String?,
      notes: json['person_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_person_details': id,
      'person_first_name': firstName,
      'person_last_name': lastName,
      'person_birth_date': birthDate?.toIso8601String(),
      'person_gender': gender,
      'person_nationality': nationality,
      'person_email': email,
      'person_phone': phone,
      'person_address': address,
      'person_city': city,
      'person_postal_code': postalCode,
      'person_country': country,
      'person_notes': notes,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Copy with method
  PersonDetails copyWith({
    int? id,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? gender,
    String? nationality,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonDetails(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Empty details factory
  factory PersonDetails.empty() {
    return PersonDetails(
      id: 0,
      firstName: null,
      lastName: null,
      birthDate: null,
      gender: null,
      nationality: null,
      email: null,
      phone: null,
      address: null,
      city: null,
      postalCode: null,
      country: null,
      notes: null,
      createdAt: null,
      updatedAt: null,
    );
  }

  @override
  String toString() {
    return 'PersonDetails(id: $id, name: "$fullName", email: $email, phone: $phone)';
  }
}

// Helper extensions for easier usage
extension PersonExtensions on Person {
  // Check if person matches search query
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;

    final searchQuery = query.toLowerCase();
    return fullName.toLowerCase().contains(searchQuery) ||
        details?.email?.toLowerCase().contains(searchQuery) == true ||
        details?.phone?.contains(query) == true ||
        details?.nationality?.toLowerCase().contains(searchQuery) == true;
  }
}

// Helper class for person search results
class PersonSearchResult {
  final Person person;
  final double score;

  const PersonSearchResult({
    required this.person,
    required this.score,
  });
}
