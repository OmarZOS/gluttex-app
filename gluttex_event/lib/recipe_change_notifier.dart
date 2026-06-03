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
  String currentSearch = "";
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
  bool _hasMoreRecipes = true;
  bool get hasMoreRecipes => _hasMoreRecipes;

  Future<void> initialize() async {
    await fetchCategories(); // First fetch categories
    await fetchRecipes(reset: true);
  }

  RecipeNotifier() {
    initialize();
  }

  // ==================== Category Management ====================

  /// Fetch recipe categories from API
  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await _recipeService.getCategories();
      if (fetchedCategories?.isNotEmpty ?? false) {
        _recipeCategories = fetchedCategories!
            .map((category) => category.recipe_category_desc)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      log("Failed to fetch categories: $e");
    }
  }

  // ==================== Recipe Management ====================

  Future<Recipe?> addOrUpdateRecipe(Recipe recipe) async {
    try {
      log('Adding/updating recipe: ${recipe.recipe_name}');
      log('Recipe owner ID: ${recipe.recipe_owner_id}');
      log('Recipe ID: ${recipe.id_recipe}');
      log('Recipe image URL: ${recipe.recipe_image_url}');

      // Handle image upload if present
      if (recipe.recipeImage != null) {
        String? imageUrl = await recipe.recipeImage?.uploadImage();
        recipe.recipe_image_url = imageUrl;
        recipe.id_recipe_image = 0;
      }

      // Determine if new or existing
      final isNewRecipe = recipe.id_recipe == null || recipe.id_recipe == 0;

      Recipe? data;

      if (isNewRecipe) {
        log('Creating new recipe');
        data = await _recipeService.addRecipe(recipe);
        if (data != null && data.id_recipe != null) {
          _recipes[data.id_recipe!] = data;
        }
      } else {
        log('Updating existing recipe: ${recipe.id_recipe}');
        data = await _recipeService.updateRecipe(recipe);
        if (data != null) {
          _recipes[recipe.id_recipe!] = data;
        }
      }

      if (data != null) {
        await fetchRecipes(categoryId: currentCategory, reset: true);
      }

      notifyListeners();
      return data;
    } catch (e) {
      log("Failed to add/update recipe: $e");
      return null;
    }
  }

  /// Fetch recipes with pagination and filtering
  Future<void> fetchRecipes({
    int categoryId = 0,
    String searchQuery = "",
    bool reset = false,
  }) async {
    if (isLoading) return;

    // Reset if category or search changes
    if (reset ||
        currentCategory != categoryId ||
        currentSearch != searchQuery) {
      currentCategory = categoryId;
      currentSearch = searchQuery;
      currentPage = 0;
      _hasMoreRecipes = true;

      if (reset) {
        _recipes.clear(); // Clear recipes only if reset is true
      }
    }

    // Don't fetch if no more recipes
    if (!_hasMoreRecipes) return;

    isLoading = true;
    notifyListeners();

    try {
      final fetchedRecipes = await _recipeService.getAllRecipes(
        currentCategory,
        currentPage * itemsPerPage,
        itemsPerPage,
        user_id: 0, // Pass user_id if needed
        query: currentSearch,
      );

      if (fetchedRecipes != null && fetchedRecipes.isNotEmpty) {
        for (var recipe in fetchedRecipes) {
          if (recipe.id_recipe != null) {
            _recipes[recipe.id_recipe!] = recipe; // Prevent duplicates
          }
        }
        currentPage++;

        // Check if we've reached the end
        if (fetchedRecipes.length < itemsPerPage) {
          _hasMoreRecipes = false;
        }
      } else {
        _hasMoreRecipes = false;
      }

      notifyListeners();
    } catch (e) {
      log("Failed to fetch recipes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load more recipes for infinite scrolling
  Future<void> loadMoreRecipes() async {
    if (!isLoading && _hasMoreRecipes) {
      await fetchRecipes();
    }
  }

  // ==================== Ingredient Management ====================

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

        // Check if we've reached the end
        if (fetchedIngredients.length < ingredientsPerPage) {
          hasMoreIngredients = false;
        }
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

  /// Get ingredient by ID (with caching)
  RecipeIngredient? getIngredientById(int id) {
    return _recipeIngredients[id];
  }

  /// Load more ingredients for infinite scrolling
  Future<void> loadMoreIngredients() async {
    if (!isLoading && hasMoreIngredients) {
      await fetchIngredients();
    }
  }

  // ==================== User Management ====================

  Future<AppUser?> getUserById(int id) async {
    // First check if user exists in local list
    final existingUser = _users.firstWhere(
      (user) => user.id_app_user == id,
      orElse: () => AppUser.empty(),
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
      if (result_user != null && result_user.id_app_user != 0) {
        // Add to local cache
        _users.add(result_user);
        notifyListeners();
        return result_user;
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user by ID: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== Local Recipe Operations ====================

  /// Adds a new recipe to local state without API call (for optimistic updates)
  void addRecipeLocally(Recipe recipe) {
    if (recipe.id_recipe != null && recipe.id_recipe != 0) {
      _recipes[recipe.id_recipe!] = recipe;
      notifyListeners();
    }
  }

  /// Updates a recipe in local state efficiently
  void updateLocalRecipe(Recipe recipe) {
    if (recipe.id_recipe != null && _recipes.containsKey(recipe.id_recipe)) {
      _recipes[recipe.id_recipe!] = recipe;
      notifyListeners();
    }
  }

  /// Deletes a recipe and updates the local state efficiently
  Future<void> deleteRecipe(int idRecipe) async {
    try {
      int? status = await _recipeService.deleteRecipe(idRecipe.toString());
      if (status != null) {
        _recipes.remove(idRecipe);
        notifyListeners();
      }
    } catch (e) {
      log("Failed to delete recipe: $e");
    }
  }

  // ==================== Filtering Helpers ====================

  /// Helper method to filter recipes by category
  List<Recipe> filterRecipesByCategory(int categoryId) {
    if (categoryId == 0) {
      return _recipes.values.toList(); // Return all recipes for "All" category
    }
    return _recipes.values
        .where((recipe) => recipe.recipe_category_id == categoryId)
        .toList();
  }

  /// Search recipes locally (client-side filtering)
  List<Recipe> searchRecipesLocally(String query) {
    if (query.isEmpty) {
      return _recipes.values.toList();
    }
    return _recipes.values
        .where((recipe) =>
            recipe.recipe_name?.toLowerCase().contains(query.toLowerCase()) ??
            false)
        .toList();
  }

  // ==================== Cache Management ====================

  /// Clear all cached data
  void clearCache() {
    _recipes.clear();
    _recipeIngredients.clear();
    _users.clear();
    currentPage = 0;
    currentIngredientPage = 0;
    _hasMoreRecipes = true;
    hasMoreIngredients = true;
    notifyListeners();
  }

  /// Refresh all data from API
  Future<void> refreshAll() async {
    clearCache();
    await fetchCategories();
    await fetchRecipes(reset: true);
    await fetchIngredients(reset: true);
  }

  // ==================== State Helpers ====================

  /// Check if a recipe exists in local cache
  bool hasRecipe(int id) {
    return _recipes.containsKey(id);
  }

  /// Get recipe by ID from local cache
  Recipe? getRecipeById(int id) {
    return _recipes[id];
  }

  /// Get the total count of recipes
  int get totalRecipeCount => _recipes.length;

  /// Get the total count of ingredients
  int get totalIngredientCount => _recipeIngredients.length;

  /// Reset all state
  void reset() {
    _recipes.clear();
    _recipeIngredients.clear();
    _users.clear();
    _recipeCategories.clear();
    currentSearch = "";
    currentPage = 0;
    currentCategory = 0;
    currentIngredientPage = 0;
    _hasMoreRecipes = true;
    hasMoreIngredients = true;
    isLoading = false;
    _isLoading = false;
    notifyListeners();
  }
}
