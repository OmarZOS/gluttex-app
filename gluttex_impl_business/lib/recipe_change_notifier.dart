import 'dart:collection';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:locator/locator.dart';

class RecipeNotifier extends ChangeNotifier {
  final RecipeService _recipeService = GluttexLocator.get<RecipeService>();

  final Map<int, Recipe> _recipes = {};
  final Map<int, RecipeIngredient> _recipeIngredients = {};
  bool isLoading = false;
  int currentPage = 0;
  int currentCategory = 0; // Track the current category
  final int itemsPerPage = GluttexConstants.itemsPerPage;
  List<String> get categories => _recipeCategories;
  List<String> _recipeCategories = [];
  set recipeCategories(List<String> value) {
    _recipeCategories = value;
  }

  List<Recipe> get recipes => _recipes.values.toList();
  List<RecipeIngredient> get recipeIngredients =>
      _recipeIngredients.values.toList();

  RecipeNotifier() {
    // fetchRecipes(0);
    // fetchIngredients();
  }

  /// Fetches all ingredients and stores them in a map for fast lookups
  Future<void> fetchIngredients() async {
    try {
      final fetchedIngredients = await _recipeService.getAllIngredients();
      if (fetchedIngredients != null) {
        _recipeIngredients.clear();
        for (var ingredient in fetchedIngredients) {
          _recipeIngredients[ingredient.id_ingredient] = ingredient;
        }
        notifyListeners();
      }
    } catch (e) {
      log("Failed to fetch ingredients: $e");
    }
  }

  /// Fetches paginated recipes and prevents duplicates
  Future<void> fetchRecipes(int categoryId, {bool reset = false}) async {
    if (isLoading) return;

    if (reset || currentCategory != categoryId) {
      currentCategory = categoryId;
      currentPage = 0;
      if (reset) {
        _recipes.clear(); // Only clear recipes if reset is true
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      final fetchedRecipes = await _recipeService.getAllRecipes(
          categoryId, currentPage * itemsPerPage, itemsPerPage);

      if (fetchedRecipes != null && fetchedRecipes.isNotEmpty) {
        for (var recipe in fetchedRecipes) {
          _recipes[recipe.id_recipe!] = recipe;
        }
        currentPage++;
        notifyListeners();
      }
    } catch (e) {
      log("Failed to fetch recipes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new recipe and updates the local state without refetching all recipes
  Future<int?> addRecipe(Recipe recipe) async {
    try {
      int? status = await _recipeService.addRecipe(recipe);
      if (status != null) {
        _recipes[recipe.id_recipe!] = recipe;
        notifyListeners();
      }
      return status;
    } catch (e) {
      log("Failed to add recipe: $e");
      return null;
    }
  }

  /// Updates a recipe and updates the local state efficiently
  Future<int?> updateRecipe(Recipe recipe) async {
    try {
      int? status = await _recipeService.updateRecipe(recipe);
      if (status != null && _recipes.containsKey(recipe.id_recipe)) {
        _recipes[recipe.id_recipe!] = recipe;
        notifyListeners();
      }
      return status;
    } catch (e) {
      log("Failed to update recipe: $e");
      return null;
    }
  }

  /// Deletes a recipe and updates the local state efficiently
  Future<int?> deleteRecipe(int idRecipe) async {
    try {
      int? status = await _recipeService.deleteRecipe(idRecipe.toString());
      if (status != null) {
        _recipes.remove(idRecipe);
        notifyListeners();
      }
      return status;
    } catch (e) {
      log("Failed to delete recipe: $e");
      return null;
    }
  }

  /// Helper method to filter recipes by category
  List<Recipe> filterRecipesByCategory(int categoryId) {
    if (categoryId == 0) {
      return _recipes.values.toList(); // Return all recipes for "All" category
    }
    return _recipes.values
        .where((recipe) => recipe.recipe_category_id == categoryId)
        .toList();
  }
}
