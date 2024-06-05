import 'dart:convert';
import 'dart:typed_data';

class Recipe {
  final int? id_recipe;
  final int? recipe_owner_id;
  final int? recipe_category_id;

  final int? id_recipe_image;
  final Uint8List? recipe_image_data;
  final DateTime? recipe_created_at;
  final DateTime? recipe_last_updated;
  final String? recipe_name;
  final String? recipe_description;
  final String? recipe_instruction;
  final String? recipe_preparation_time;
  final String? recipe_category_desc;

  Recipe(
      {required this.id_recipe,
      required this.recipe_category_id,
      required this.id_recipe_image,
      required this.recipe_name,
      required this.recipe_image_data,
      required this.recipe_description,
      required this.recipe_created_at,
      required this.recipe_last_updated,
      required this.recipe_owner_id,
      required this.recipe_instruction,
      required this.recipe_preparation_time,
      required this.recipe_category_desc});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    Uint8List? imageData;
    if (json['recipe_image'] != null &&
        json['recipe_image'] is List &&
        json['recipe_image']!.isNotEmpty) {
      final imageBase64 = json['recipe_image'][0]["recipe_image_data"];
      if (imageBase64 != null && imageBase64 != "" && imageBase64 != "string") {
        imageData = base64Decode(imageBase64);
      }
    }
    return Recipe(
      id_recipe: json['id_recipe'] ?? 0,
      recipe_owner_id: json['recipe_owner_id'] ?? 0,
      recipe_category_id: json['recipe_category_id'] ?? 0,
      id_recipe_image: json['id_recipe_image'] ?? 0,
      recipe_image_data: imageData,
      recipe_name: json['recipe_name'] ?? "",
      recipe_description: json['recipe_description'],
      recipe_instruction: json['recipe_instructions'],
      recipe_preparation_time: json['recipe_preparation_time'],
      recipe_created_at: null,
      recipe_last_updated: null,
      recipe_category_desc:
          json['recipe_category']['recipe_category_desc'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "recipe": {
        "id_recipe": id_recipe ?? 0,
        "recipe_owner_id": recipe_owner_id ?? 0,
        "recipe_category_id": recipe_category_id ?? 0,
        "recipe_preparation_time": recipe_preparation_time ?? "",
        "recipe_name": recipe_name ?? "",
        "recipe_description": recipe_description ?? "",
        "recipe_instructions": recipe_instruction ?? "",
      },
      "image": {
        "id_recipe_image": id_recipe_image ?? 0,
        "recipe_image_data":
            recipe_image_data != null ? base64Encode(recipe_image_data!) : null,
        "recipe_ref_id": id_recipe ?? 0
      }
    };
  }
}

class RecipeCategory {
  final int recipe_category_id;
  final String recipe_category_desc;
  RecipeCategory(
      {required this.recipe_category_id, required this.recipe_category_desc});

  factory RecipeCategory.fromJson(Map<String, dynamic> json) {
    return RecipeCategory(
        recipe_category_id: json['id_recipe_category'] ?? 0,
        recipe_category_desc: json['recipe_category_desc'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_category_id': recipe_category_id,
      'recipe_category_desc': recipe_category_desc,
    };
  }
}
