import 'dart:typed_data';

class AppUser {
  final int id_app_user;
  final int app_user_person_id;
  final int app_user_type_id;
  final int id_app_user_type;
  final String app_user_name;
  final String app_user_password;
  final String app_user_preferences;
  final String app_user_type_desc;
  final Uint8List app_user_image;

  AppUser({
    required this.id_app_user,
    required this.app_user_person_id,
    required this.app_user_type_id,
    required this.id_app_user_type,
    required this.app_user_name,
    required this.app_user_password,
    required this.app_user_preferences,
    required this.app_user_type_desc,
    required this.app_user_image,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
        id_app_user: json['id_app_user'] as int,
        app_user_person_id: json['app_user_person_id'] as int,
        app_user_type_id: json['app_user_type_id'] as int,
        id_app_user_type: json['id_app_user_type'] as int,
        app_user_name: json['app_user_name'] as String,
        app_user_password: json['app_user_password'] as String,
        app_user_preferences: json['app_user_preferences'] as String,
        app_user_type_desc: json['app_user_type_desc'] as String,
        app_user_image: json['app_user_image'] as Uint8List);
  }

  Map<String, dynamic> toJson() {
    return {
      'id_app_user': id_app_user,
      'app_user_person_id': app_user_person_id,
      'app_user_type_id': app_user_type_id,
      'id_app_user_type': id_app_user_type,
      'app_user_name': app_user_name,
      'app_user_password': app_user_password,
      'app_user_preferences': app_user_preferences,
      'app_user_type_desc': app_user_type_desc,
      'app_user_image': app_user_image
    };
  }
}
