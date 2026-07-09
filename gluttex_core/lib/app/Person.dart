import 'dart:developer';

class Person {
  final int id_person;
  final int person_details_id;
  final String? person_blood_type; // Changed from person_blood_type_id
  final int? person_location_id;
  final PersonDetails person_details;
  final DateTime? created_at;
  final DateTime? updated_at;

  const Person({
    required this.id_person,
    required this.person_details_id,
    this.person_blood_type, // Changed
    this.person_location_id,
    required this.person_details,
    this.created_at,
    this.updated_at,
  });

  // Get full name
  String get fullName =>
      '${person_details.person_first_name ?? ''} ${person_details.person_last_name ?? ''}'
          .trim();

  // Get first name
  String? get firstName => person_details.person_first_name;

  // Get last name
  String? get lastName => person_details.person_last_name;

  // Get gender
  String? get gender => person_details.person_gender;

  // Get nationality
  String? get nationality => person_details.person_country_code;

  // Get birth date
  DateTime? get birthDate => person_details.person_birth_date;

  // Get age (if birth date is available)
  int? get age {
    if (person_details.person_birth_date == null) return null;
    final now = DateTime.now();
    int age = now.year - person_details.person_birth_date!.year;
    if (now.month < person_details.person_birth_date!.month ||
        (now.month == person_details.person_birth_date!.month &&
            now.day < person_details.person_birth_date!.day)) {
      age--;
    }
    return age;
  }

  // Check if person is adult (18+ years)
  bool get isAdult {
    final currentAge = age;
    return currentAge != null && currentAge >= 18;
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    // Parse person_details from nested structure
    final personDetailsJson =
        json['person_details'] as Map<String, dynamic>? ?? {};

    return Person(
      id_person: (json['id_person'] as num?)?.toInt() ?? 0,
      person_details_id: (json['person_details_id'] as num?)?.toInt() ?? 0,
      person_blood_type:
          json['person_blood_type'] as String?, // Direct string from JSON
      person_location_id: (json['person_location_id'] as num?)?.toInt(),
      person_details: PersonDetails.fromJson(personDetailsJson),
      created_at: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_person': id_person,
      'person_details_id': person_details_id,
      'person_blood_type': person_blood_type,
      'person_location_id': person_location_id,
      'person_details': person_details.toJson(),
      if (created_at != null) 'created_at': created_at!.toIso8601String(),
      if (updated_at != null) 'updated_at': updated_at!.toIso8601String(),
    };
  }

  // Copy with method
  Person copyWith({
    int? id_person,
    int? person_details_id,
    String? person_blood_type,
    int? person_location_id,
    PersonDetails? person_details,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return Person(
      id_person: id_person ?? this.id_person,
      person_details_id: person_details_id ?? this.person_details_id,
      person_blood_type: person_blood_type ?? this.person_blood_type,
      person_location_id: person_location_id ?? this.person_location_id,
      person_details: person_details ?? this.person_details,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  // Empty person factory
  factory Person.empty() {
    return Person(
      id_person: 0,
      person_details_id: 0,
      person_blood_type: null,
      person_location_id: null,
      person_details: PersonDetails.empty(),
      created_at: null,
      updated_at: null,
    );
  }

  // Check if person is empty (has only ID 0)
  bool get isEmpty => id_person == 0;

  // Check if person has basic information
  bool get hasBasicInfo => person_details.hasName;

  // Get display name (full name or "Unknown Person")
  String get displayName {
    if (hasBasicInfo) return fullName;
    return 'Unknown Person #$id_person';
  }

  // Get initials for avatar
  String get initials {
    if (!hasBasicInfo) return '?';
    final firstInitial = person_details.person_first_name?.isNotEmpty == true
        ? person_details.person_first_name![0]
        : '';
    final lastInitial = person_details.person_last_name?.isNotEmpty == true
        ? person_details.person_last_name![0]
        : '';
    return (firstInitial + lastInitial).toUpperCase();
  }

  // Get gender icon
  String get genderIcon {
    switch (person_details.person_gender?.toLowerCase()) {
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
    if (person_details.person_birth_date == null) return null;
    return '${person_details.person_birth_date!.day}/${person_details.person_birth_date!.month}/${person_details.person_birth_date!.year}';
  }

  @override
  String toString() {
    return 'Person(id_person: $id_person, name: "$fullName", gender: $gender, nationality: $nationality)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Person && other.id_person == id_person;
  }

  @override
  int get hashCode => id_person.hashCode;
}

class PersonDetails {
  final int id_person_details;
  final String person_last_name;
  final String person_first_name;
  final DateTime? person_birth_date;
  final String person_gender;
  final String person_country_code; // Changed from person_nationality
  final String? person_email;
  final String? person_phone;
  final String? person_address;
  final String? person_city;
  final String? person_postal_code;
  final String? person_country;
  final String? person_notes;
  final DateTime? created_at;
  final DateTime? updated_at;

  const PersonDetails({
    required this.id_person_details,
    required this.person_last_name,
    required this.person_first_name,
    this.person_birth_date,
    required this.person_gender,
    required this.person_country_code, // Changed
    this.person_email,
    this.person_phone,
    this.person_address,
    this.person_city,
    this.person_postal_code,
    this.person_country,
    this.person_notes,
    this.created_at,
    this.updated_at,
  });

  // Check if has name
  bool get hasName =>
      person_first_name.isNotEmpty || person_last_name.isNotEmpty;

  // Get full name
  String get fullName => '$person_first_name $person_last_name'.trim();

  // Get nationality (alias for person_country_code)
  String? get person_nationality => person_country_code;

  // Get formatted phone number
  String? get formattedPhone {
    if (person_phone == null || person_phone!.isEmpty) return null;
    if (person_phone!.length == 10) {
      return '${person_phone!.substring(0, 4)}-${person_phone!.substring(4, 7)}-${person_phone!.substring(7)}';
    }
    return person_phone;
  }

  // Get address line
  String? get addressLine {
    if (person_address == null && person_city == null && person_country == null)
      return null;

    final parts = <String>[];
    if (person_address != null) parts.add(person_address!);
    if (person_city != null) parts.add(person_city!);
    if (person_country != null) parts.add(person_country!);

    return parts.join(', ');
  }

  // Factory constructor from JSON
  factory PersonDetails.fromJson(Map<String, dynamic> json) {
    return PersonDetails(
      id_person_details: (json['id_person_details'] as num?)?.toInt() ?? 0,
      person_last_name: json['person_last_name'] as String? ?? '',
      person_first_name: json['person_first_name'] as String? ?? '',
      person_birth_date: json['person_birth_date'] != null
          ? DateTime.tryParse(json['person_birth_date'] as String)
          : null,
      person_gender: json['person_gender'] as String? ?? '',
      person_country_code:
          json['person_country_code'] as String? ?? '', // Changed key
      person_email: json['person_email'] as String?,
      person_phone: json['person_phone'] as String?,
      person_address: json['person_address'] as String?,
      person_city: json['person_city'] as String?,
      person_postal_code: json['person_postal_code'] as String?,
      person_country: json['person_country'] as String?,
      person_notes: json['person_notes'] as String?,
      created_at: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updated_at: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_person_details': id_person_details,
      'person_last_name': person_last_name,
      'person_first_name': person_first_name,
      'person_birth_date': person_birth_date?.toIso8601String(),
      'person_gender': person_gender,
      'person_country_code': person_country_code, // Changed key
      'person_email': person_email,
      'person_phone': person_phone,
      'person_address': person_address,
      'person_city': person_city,
      'person_postal_code': person_postal_code,
      'person_country': person_country,
      'person_notes': person_notes,
      if (created_at != null) 'created_at': created_at!.toIso8601String(),
      if (updated_at != null) 'updated_at': updated_at!.toIso8601String(),
    };
  }

  // Copy with method
  PersonDetails copyWith({
    int? id_person_details,
    String? person_last_name,
    String? person_first_name,
    DateTime? person_birth_date,
    String? person_gender,
    String? person_country_code,
    String? person_email,
    String? person_phone,
    String? person_address,
    String? person_city,
    String? person_postal_code,
    String? person_country,
    String? person_notes,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return PersonDetails(
      id_person_details: id_person_details ?? this.id_person_details,
      person_last_name: person_last_name ?? this.person_last_name,
      person_first_name: person_first_name ?? this.person_first_name,
      person_birth_date: person_birth_date ?? this.person_birth_date,
      person_gender: person_gender ?? this.person_gender,
      person_country_code: person_country_code ?? this.person_country_code,
      person_email: person_email ?? this.person_email,
      person_phone: person_phone ?? this.person_phone,
      person_address: person_address ?? this.person_address,
      person_city: person_city ?? this.person_city,
      person_postal_code: person_postal_code ?? this.person_postal_code,
      person_country: person_country ?? this.person_country,
      person_notes: person_notes ?? this.person_notes,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  // Empty details factory
  factory PersonDetails.empty() {
    return PersonDetails(
      id_person_details: 0,
      person_last_name: '',
      person_first_name: '',
      person_birth_date: null,
      person_gender: '',
      person_country_code: '',
      person_email: null,
      person_phone: null,
      person_address: null,
      person_city: null,
      person_postal_code: null,
      person_country: null,
      person_notes: null,
      created_at: null,
      updated_at: null,
    );
  }

  @override
  String toString() {
    return 'PersonDetails(id_person_details: $id_person_details, name: "$fullName", email: $person_email, phone: $person_phone)';
  }
}

// Helper extensions for easier usage
extension PersonExtensions on Person {
  // Check if person matches search query
  bool matchesQuery(String query) {
    if (query.isEmpty) return true;

    final searchQuery = query.toLowerCase();
    return fullName.toLowerCase().contains(searchQuery) ||
        person_details.person_email?.toLowerCase().contains(searchQuery) ==
            true ||
        person_details.person_phone?.contains(query) == true ||
        person_details.person_country_code.toLowerCase().contains(searchQuery);
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
