import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:locator/locator.dart';

class RecipeNotifier extends ChangeNotifier {
  final RecipeService _recipeService = GluttexLocator.get<RecipeService>();
  List<Recipe> _recipes = [];
  List<RecipeIngredient> _recipeIngredients = [];
  List<Recipe> get recipes => _recipes;
  List<RecipeIngredient> get recipeIngredients =>
      _recipeIngredients.map((ingredient) {
        return RecipeIngredient(
            id_ingredient: ingredient.id_ingredient,
            ingredient_name: ingredient.ingredient_name,
            ingredient_icon: ""); // remove the icon data from the object
      }).toList();
  // Getter method to retrieve an ingredient by its id
  RecipeIngredient? getIngredientById(int id) {
    try {
      return _recipeIngredients.firstWhere(
        (ingredient) => ingredient.id_ingredient == id,
        // orElse: () => null, // Returns null if the ingredient is not found
      );
    } catch (e) {
      return null;
    }
  }

  RecipeNotifier() {
    fetchRecipes();
    fetchIngredients();
  }

  Future<void> getRecipeImage(Recipe recipe) async {
    Uint8List? image =
        await _recipeService.getRecipeImage('${recipe.id_recipe_image}');
    // await fetchRecipes();
    // log("Changing recipe image");
    // log('${_recipes.where((element) => element.id_recipe == recipe.id_recipe)}');
    _recipes
        .where((element) => element.id_recipe == recipe.id_recipe)
        .first
        .recipe_image_data = image;
    notifyListeners();
  }

  Future<void> fetchIngredients() async {
    var recipeIngredients = await _recipeService.getAllIngredients();

    // log('${recipes}');
    _recipeIngredients = recipeIngredients ?? [];
    notifyListeners();
  }

  Future<void> fetchRecipes() async {
    var recipes = await _recipeService.getAllRecipes();

    // log('${recipes}');
    _recipes = recipes ?? [];
    notifyListeners();
  }

  Future<int?> addRecipe(Recipe recipe) async {
    int? status = await _recipeService.addRecipe(recipe);
    await fetchRecipes();
    return status;
  }

  Future<int?> updateRecipe(Recipe recipe) async {
    int? status = await _recipeService.updateRecipe(recipe);
    await fetchRecipes();
    return status;
  }

  Future<int?> deleteRecipe(String idRecipe) async {
    int? status = await _recipeService.deleteRecipe(idRecipe);
    await fetchRecipes();
    return status;
  }
}
