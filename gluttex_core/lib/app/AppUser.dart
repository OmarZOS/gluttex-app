class AppUser {
  final int id_app_user;
  final int app_user_person_id;
  final int app_user_type_id;
  final int id_app_user_type;
  final String app_user_name;
  final String app_user_password;
  final String app_user_preferences;
  final String app_user_type_desc;
  // final bytes app_user_image;

  AppUser(
      {required this.id_app_user,
      required this.app_user_person_id,
      required this.app_user_type_id,
      required this.id_app_user_type,
      required this.app_user_name,
      required this.app_user_password,
      required this.app_user_preferences,
      required this.app_user_type_desc});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
