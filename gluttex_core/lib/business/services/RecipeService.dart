import 'dart:typed_data';

import '../Recipe.dart';

// RecipeService.dart
abstract class RecipeService {
  Future<List<RecipeIngredient>?> getAllIngredients(int offset, int limit,
      {String? callerKey}) async {
    return null;
  }

  Future<List<RecipeCategory>?>? getCategories({String? callerKey}) async {
    return null;
  }

  Future<List<Recipe>?>? getAllRecipes(int category, int page, int limit,
      {int user_id = 0, String query = "", String? callerKey}) async {
    return null;
  }

  Future<Recipe?> getRecipe(String idRecipe, {String? callerKey}) async {
    return null;
  }

  Future<Recipe?> addRecipe(Recipe recipe, {String? callerKey}) async {
    return null;
  }

  Future<Recipe?> updateRecipe(Recipe updatedRecipe,
      {String? callerKey}) async {
    return null;
  }

  Future<int?> deleteRecipe(String recipeId, {String? callerKey}) async {
    return null;
  }
}
