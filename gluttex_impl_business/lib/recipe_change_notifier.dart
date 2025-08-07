import 'dart:collection';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
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
  final List<AppUser> _users = [];
  List<AppUser> get users => _users;
  bool _isLoading = false;
  bool get userIsLoading => _isLoading;
  set recipeCategories(List<String> value) {
    _recipeCategories = value;
  }

  List<Recipe> get recipes => _recipes.values.toList();
  List<RecipeIngredient> get recipeIngredients =>
      _recipeIngredients.values.toList();

  int currentIngredientPage = 0;
  final int ingredientsPerPage = 50;
  bool hasMoreIngredients = true;

  Future<void> initialize() async {
    await fetchIngredients(reset: true);
    await fetchRecipes(0, reset: true);
  }

  RecipeNotifier() {
    initialize();
  }

  Future<int?> addOrUpdateRecipe(Recipe recipe) async {
    try {
      log('Adding/updating recipe: ${recipe.recipe_name}');
      if (recipe.recipeImage != null) {
        String? imageUrl = await recipe.recipeImage?.uploadImage();
        recipe.recipe_image_url = imageUrl;
        recipe.id_recipe_image = 0; // Reset image ID to ensure new upload
      }

      int? status = (recipe.id_recipe == 0
          ? await _recipeService.addRecipe(recipe)
          : await _recipeService.updateRecipe(recipe));
      if (status != null) {
        updateLocalRecipe(recipe);
        await fetchRecipes(currentCategory, reset: true);
      }
      return status;
    } catch (e) {
      log("Failed to add/update recipe: $e");
      return null;
    }
  }

  /// Fetches all ingredients and stores them in a map for fast lookups
  Future<void> fetchIngredients({bool reset = false}) async {
    if (reset) {
      _recipeIngredients.clear();
      currentIngredientPage = 0;
      hasMoreIngredients = true;
    }

    if (!hasMoreIngredients || isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final fetchedIngredients = await _recipeService.getAllIngredients(
        currentIngredientPage * ingredientsPerPage,
        ingredientsPerPage,
      );

      if (fetchedIngredients != null && fetchedIngredients.isNotEmpty) {
        for (var ingredient in fetchedIngredients) {
          _recipeIngredients[ingredient.id_ingredient] = ingredient;
        }
        currentIngredientPage++;
      } else {
        hasMoreIngredients = false;
      }

      notifyListeners();
    } catch (e) {
      log("Failed to fetch ingredients: $e");
    } finally {
      isLoading = false;
      notifyListeners();
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

  Future<AppUser?> getUserById(int id) async {
    // First check if supplier exists in local list
    final existingUser = _users.firstWhere(
      (user) => user.id_app_user == id,
      orElse: () => AppUser.empty(), // Returns empty user if not found
    );

    // Return if found (and not empty)
    if (existingUser.id_app_user != 0) {
      return existingUser;
    }

    // If not found locally, fetch from API
    _isLoading = true;
    notifyListeners();

    try {
      final result_user =
          await GluttexLocator.get<AppUserService>().getAppUser(id.toString());
      if (result_user != null) {
        // Add to local cache
        _users.add(result_user);
      }
      return result_user;
    } catch (e) {
      debugPrint("Error fetching user by ID: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new recipe and updates the local state without refetching all recipes
  Future<void> addRecipe(Recipe recipe) async {
    if (recipe.recipeImage != null) {
      String? imageUrl = await recipe.recipeImage?.uploadImage();
      recipe.recipe_image_url = imageUrl;
    }
    int? status = await _recipeService.addRecipe(recipe);
    if (status != null) {
      _recipes[recipe.id_recipe!] = recipe;
      notifyListeners();
    }
    // return status;
  }

  /// Updates a recipe and updates the local state efficiently
  void updateLocalRecipe(Recipe recipe) async {
    // int? status = await _recipeService.updateRecipe(recipe);
    if (_recipes.containsKey(recipe.id_recipe)) {
      _recipes[recipe.id_recipe!] = recipe;
      notifyListeners();
    }
  }

  /// Deletes a recipe and updates the local state efficiently
  Future<void> deleteRecipe(int idRecipe) async {
    int? status = await _recipeService.deleteRecipe(idRecipe.toString());
    if (status != null) {
      _recipes.remove(idRecipe);
      notifyListeners();
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
