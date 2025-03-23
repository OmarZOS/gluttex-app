import 'dart:typed_data';

import '../Recipe.dart';

// RecipeService.dart
abstract class RecipeService {
  Future<List<RecipeIngredient>?> getAllIngredients() async {
    return null;
  }

  Future<Uint8List?> getRecipeImage(String id) async {
    return null;
  }

  Future<List<RecipeCategory>?>? getCategories() async {
    return null;
  }

  Future<List<Recipe>?>? getAllRecipes(int page, int limit) async {
    return null;
  }

  Future<Recipe?> getRecipe(String idRecipe) async {
    return null;
  }

  Future<int?> addRecipe(Recipe recipe) async {
    return null;
  }

  Future<int?> updateRecipe(Recipe updatedRecipe) async {
    return null;
  }

  Future<int?> deleteRecipe(String recipeId) async {
    return null;
  }
}
