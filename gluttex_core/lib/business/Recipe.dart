import 'dart:convert';
import 'dart:typed_data';

import 'package:gluttex_core/app/GluttexImage.dart';

class Recipe {
  final int? id_recipe;
  final int? recipe_owner_id;
  final int? recipe_category_id;

  int? id_recipe_image;
  String? recipe_image_url;
  final DateTime? recipe_created_at;
  final DateTime? recipe_last_updated;
  final String? recipe_name;
  final String? recipe_description;
  final String? recipe_instruction;
  final Duration? recipe_preparation_time;
  final String? recipe_category_desc;
  final Map<int, String>? recipe_ingredients;

  GluttexImage? recipeImage;

  Recipe(
      {required this.id_recipe,
      required this.recipe_category_id,
      required this.id_recipe_image,
      required this.recipe_name,
      required this.recipe_image_url,
      required this.recipe_description,
      required this.recipe_created_at,
      required this.recipe_last_updated,
      required this.recipe_owner_id,
      required this.recipe_instruction,
      required this.recipe_preparation_time,
      required this.recipe_category_desc,
      required this.recipe_ingredients});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    int cardImageId = 0;
    if (json['recipe_image'] != null &&
        json['recipe_image'] is List &&
        json['recipe_image']!.isNotEmpty) {
      final imageId = json['recipe_image'].last["id_recipe_image"];
      cardImageId = imageId;
      imageUrl = json['recipe_image'].last["recipe_image_url"];
    }

    List<String> preparationTime =
        json['recipe_preparation_time'].toString().split("h");
    Duration? preparationDuration = Duration(
        hours: int.parse(preparationTime[0]),
        minutes: int.parse(preparationTime[1]));

    Map<int, String> ingredientsMap = {};
    if (json['recipe_contains_ingredient'] != null)
      // ignore: curly_braces_in_flow_control_structures
      for (var ingredient in json['recipe_contains_ingredient']) {
        if (ingredient['contained_ingredient_id'] != null) {
          ingredientsMap[ingredient['contained_ingredient_id']] =
              ingredient['contained_quantity'] ?? "";
        }
      }

    return Recipe(
        id_recipe: json['id_recipe'] ?? 0,
        recipe_owner_id: json['recipe_owner_id'] ?? 0,
        recipe_category_id: json['recipe_category_id'] ?? 0,
        id_recipe_image: cardImageId,
        recipe_image_url: imageUrl ?? "",
        recipe_name: json['recipe_name'] ?? "",
        recipe_description: json['recipe_description'],
        recipe_instruction: json['recipe_instructions'],
        recipe_preparation_time: preparationDuration,
        recipe_created_at: null,
        recipe_last_updated: null,
        recipe_category_desc:
            json['recipe_category']['recipe_category_desc'] ?? "",
        recipe_ingredients: ingredientsMap);
  }

  static Map<String, dynamic> ingredientsFromJson(List<dynamic> json) {
    throw UnimplementedError();
  }

  Map<String, dynamic> toJson() {
    return {
      "recipe": {
        "id_recipe": id_recipe ?? 0,
        "recipe_owner_id": recipe_owner_id ?? 0,
        "recipe_category_id": recipe_category_id ?? 0,
        "recipe_preparation_time":
            "${recipe_preparation_time!.inHours}h${recipe_preparation_time!.inMinutes}",
        "recipe_name": recipe_name ?? "",
        "recipe_description": recipe_description ?? "",
        "recipe_instructions": recipe_instruction ?? "",
        "recipe_ingredients": recipe_ingredients!.map((key, value) {
          return MapEntry(key.toString(), value);
        })
      },
      "image": {
        "id_recipe_image": id_recipe_image ?? 0,
        "recipe_image_data": recipe_image_url ?? "",
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

class RecipeIngredient {
  final int id_ingredient;
  final String ingredient_name;
  final String ingredient_icon;
  RecipeIngredient(
      {required this.id_ingredient,
      required this.ingredient_name,
      required this.ingredient_icon});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
        id_ingredient: json['id_ingredient'] ?? 0,
        ingredient_icon: json['ingredient_icon'] ?? "",
        ingredient_name: json['ingredient_name'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'id_ingredient': id_ingredient,
      'ingredient_name': ingredient_name,
      'ingredient_icon': ingredient_icon
    };
  }
}
