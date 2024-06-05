import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:locator/locator.dart';

class RecipeNotifier extends ChangeNotifier {
  final RecipeService _recipeService = GluttexLocator.get<RecipeService>();
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  RecipeNotifier() {
    fetchRecipes();
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

  Future<int?> deleteRecipe(String id_recipe) async {
    int? status = await _recipeService.deleteRecipe(id_recipe);
    await fetchRecipes();
    return status;
  }
}
