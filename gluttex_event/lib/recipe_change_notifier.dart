import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class RecipeNotifier extends ChangeNotifier {
  final RecipeService _recipeService = GluttexLocator.get<RecipeService>();
  final StorageService _storageService = GluttexLocator.get<StorageService>();

  final Map<int, Recipe> _recipes = {};
  final Map<int, RecipeIngredient> _recipeIngredients = {};
  bool isLoading = false;
  String currentSearch = "";
  int currentPage = 0;
  int currentCategory = 0;
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

  // Helper method to generate caller key
  String _getCallerKey(String method, {String? id, String? suffix}) {
    final parts = [method];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    return parts.join('_');
  }

  Future<void> initialize() async {
    await fetchCategories();
    await fetchRecipes(reset: true);
  }

  RecipeNotifier() {
    initialize();
  }

  // ==================== Category Management ====================

  Future<void> fetchCategories({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('fetchCategories');

    try {
      final fetchedCategories =
          await _recipeService.getCategories(callerKey: key);

      if (fetchedCategories?.isNotEmpty ?? false) {
        _recipeCategories = fetchedCategories!
            .map((category) => category.recipe_category_desc)
            .toList();
      }
      notifyListeners();
    } catch (e) {
      log("Failed to fetch categories: $e");
    }
  }

  // ==================== Recipe Management ====================

  Future<bool> addOrUpdateRecipe(Recipe recipe, {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey(
            recipe.id_recipe == null || recipe.id_recipe == 0
                ? 'addRecipe'
                : 'updateRecipe',
            id: recipe.id_recipe?.toString(),
            suffix: recipe.recipe_name);

    try {
      log('Adding/updating recipe: ${recipe.recipe_name}');

      if (recipe.recipeImage != null) {
        String? imageUrl = await recipe.recipeImage?.uploadImage();
        recipe.recipe_image_url = imageUrl;
        recipe.id_recipe_image = 0;
      }

      final isNewRecipe = recipe.id_recipe == null || recipe.id_recipe == 0;

      Recipe? data;
      if (isNewRecipe) {
        data = await _recipeService.addRecipe(recipe, callerKey: key);
        if (data != null && data.id_recipe != null) {
          _recipes[data.id_recipe!] = data;
        }
      } else {
        data = await _recipeService.updateRecipe(recipe, callerKey: key);
        if (data != null) {
          _recipes[recipe.id_recipe!] = data;
        }
      }

      if (data != null) {
        await fetchRecipes(categoryId: currentCategory, reset: true);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      log("Failed to add/update recipe: $e");
      return false;
    }
  }

  Future<void> fetchRecipes({
    int categoryId = 0,
    String searchQuery = "",
    bool reset = false,
    String? callerKey,
  }) async {
    final key = callerKey ??
        _getCallerKey('fetchRecipes',
            suffix: '${categoryId}_${searchQuery}_$currentPage');

    if (isLoading) return;

    if (reset ||
        currentCategory != categoryId ||
        currentSearch != searchQuery) {
      currentCategory = categoryId;
      currentSearch = searchQuery;
      currentPage = 0;
      _hasMoreRecipes = true;

      if (reset) {
        _recipes.clear();
      }
    }

    if (!_hasMoreRecipes) return;

    isLoading = true;
    notifyListeners();

    try {
      final fetchedRecipes = await _recipeService.getAllRecipes(
        currentCategory,
        currentPage * itemsPerPage,
        itemsPerPage,
        user_id: 0,
        query: currentSearch,
        callerKey: key,
      );

      if (fetchedRecipes != null && fetchedRecipes.isNotEmpty) {
        for (var recipe in fetchedRecipes) {
          if (recipe.id_recipe != null) {
            _recipes[recipe.id_recipe!] = recipe;
          }
        }
        currentPage++;

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

  Future<void> loadMoreRecipes({String? callerKey}) async {
    if (!isLoading && _hasMoreRecipes) {
      await fetchRecipes(callerKey: callerKey);
    }
  }

  Future<bool> deleteRecipe(int idRecipe, {String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('deleteRecipe', id: idRecipe.toString());

    try {
      int? status = await _recipeService.deleteRecipe(idRecipe.toString(),
          callerKey: key);

      if (status == 200 || status == 204) {
        _recipes.remove(idRecipe);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      log("Failed to delete recipe: $e");
      return false;
    }
  }

  // ==================== Ingredient Management ====================

  Future<void> fetchIngredients({bool reset = false, String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('fetchIngredients',
            suffix: '${currentIngredientPage}_$reset');

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
        callerKey: key,
      );

      if (fetchedIngredients != null && fetchedIngredients.isNotEmpty) {
        for (var ingredient in fetchedIngredients) {
          _recipeIngredients[ingredient.id_ingredient] = ingredient;
        }
        currentIngredientPage++;

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

  RecipeIngredient? getIngredientById(int id) {
    return _recipeIngredients[id];
  }

  Future<void> loadMoreIngredients({String? callerKey}) async {
    if (!isLoading && hasMoreIngredients) {
      await fetchIngredients(callerKey: callerKey);
    }
  }

  // ==================== User Management ====================

  Future<AppUser?> getUserById(int id, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getUserById', id: id.toString());

    final existingUser = _users.firstWhere(
      (user) => user.id_app_user == id,
      orElse: () => AppUser.empty(),
    );

    if (existingUser.id_app_user != 0) {
      return existingUser;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result_user =
          await GluttexLocator.get<AppUserService>().getAppUser(id.toString());

      if (result_user != null && result_user.id_app_user != 0) {
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

  void addRecipeLocally(Recipe recipe) {
    if (recipe.id_recipe != null && recipe.id_recipe != 0) {
      _recipes[recipe.id_recipe!] = recipe;
      notifyListeners();
    }
  }

  void updateLocalRecipe(Recipe recipe) {
    if (recipe.id_recipe != null && _recipes.containsKey(recipe.id_recipe)) {
      _recipes[recipe.id_recipe!] = recipe;
      notifyListeners();
    }
  }

  // ==================== Filtering Helpers ====================

  List<Recipe> filterRecipesByCategory(int categoryId) {
    if (categoryId == 0) {
      return _recipes.values.toList();
    }
    return _recipes.values
        .where((recipe) => recipe.recipe_category_id == categoryId)
        .toList();
  }

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

  Future<void> refreshAll({String? callerKey}) async {
    clearCache();
    await fetchCategories(callerKey: callerKey);
    await fetchRecipes(reset: true, callerKey: callerKey);
    await fetchIngredients(reset: true, callerKey: callerKey);
  }

  // ==================== State Helpers ====================

  bool hasRecipe(int id) {
    return _recipes.containsKey(id);
  }

  Recipe? getRecipeById(int id) {
    return _recipes[id];
  }

  int get totalRecipeCount => _recipes.length;
  int get totalIngredientCount => _recipeIngredients.length;

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

  // ============ HELPER METHODS FOR RESPONSE RETRIEVAL ============

  // Get the stored response from the RecipeService (through StorageService)
  CallerResponse? getResponse(String callerKey) {
    return _storageService.getResponse(callerKey);
  }

  /// Check if a call was successful
  bool isSuccess(String callerKey) {
    return _storageService.isCallerSuccess(callerKey);
  }

  /// Get response data
  dynamic getResponseData(String callerKey) {
    return _storageService.getResponseData(callerKey);
  }

  /// Get status code
  int? getStatusCode(String callerKey) {
    return _storageService.getStatusCode(callerKey);
  }

  /// Get response code
  String? getResponseCode(String callerKey) {
    return _storageService.getResponseCode(callerKey);
  }

  /// Get error message
  String? getErrorMessage(String callerKey) {
    return _storageService.getErrorMessage(callerKey);
  }

  /// Clear response for a caller key
  void clearResponse(String callerKey) {
    _storageService.clearResponse(callerKey);
  }

  /// Clear all responses
  void clearAllResponses() {
    _storageService.clearAllResponses();
  }

  /// Fetch all ingredients (no pagination, simple version)
  Future<void> fetchAllIngredients({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('fetchAllIngredients');

    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final fetchedIngredients = await _recipeService.getAllIngredients(
        0,
        1000, // Fetch up to 1000 ingredients
        callerKey: key,
      );

      if (fetchedIngredients != null && fetchedIngredients.isNotEmpty) {
        _recipeIngredients.clear();
        for (var ingredient in fetchedIngredients) {
          _recipeIngredients[ingredient.id_ingredient] = ingredient;
        }
      }
      notifyListeners();
    } catch (e) {
      log("Failed to fetch all ingredients: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Get ingredient by ID (from local cache)
  RecipeIngredient? getIngredient(int id) {
    return _recipeIngredients[id];
  }

  /// Get all ingredients from local cache
  List<RecipeIngredient> getAllIngredients() {
    return _recipeIngredients.values.toList();
  }

  /// Search ingredients locally by name
  List<RecipeIngredient> searchIngredients(String query) {
    if (query.isEmpty) {
      return _recipeIngredients.values.toList();
    }
    return _recipeIngredients.values
        .where((ingredient) => ingredient.ingredient_name
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

  /// Add a new ingredient
  Future<bool> addIngredient(String name, String iconUrl,
      {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('addIngredient', suffix: name);

    try {
      final ingredient = RecipeIngredient(
        id_ingredient: 0,
        ingredient_name: name,
        ingredient_icon: iconUrl,
      );

      final created =
          await _recipeService.addIngredient(ingredient, callerKey: key);

      if (created != null) {
        _recipeIngredients[created.id_ingredient] = created;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      log("Failed to add ingredient: $e");
      return false;
    }
  }

  /// Update an existing ingredient
  Future<bool> updateIngredient(int id, String name, String iconUrl,
      {String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('updateIngredient', id: id.toString());

    try {
      final ingredient = RecipeIngredient(
        id_ingredient: id,
        ingredient_name: name,
        ingredient_icon: iconUrl,
      );

      final updated =
          await _recipeService.updateIngredient(ingredient, callerKey: key);

      if (updated != null) {
        _recipeIngredients[id] = updated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      log("Failed to update ingredient: $e");
      return false;
    }
  }

  /// Delete an ingredient
  Future<bool> deleteIngredient(int id, {String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('deleteIngredient', id: id.toString());

    try {
      final result =
          await _recipeService.deleteIngredient(id.toString(), callerKey: key);

      if (result == 200 || result == 204) {
        _recipeIngredients.remove(id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      log("Failed to delete ingredient: $e");
      return false;
    }
  }

  /// Refresh ingredients from API (clears and reloads)
  Future<void> refreshIngredients({String? callerKey}) async {
    _recipeIngredients.clear();
    currentIngredientPage = 0;
    hasMoreIngredients = true;
    await fetchAllIngredients(callerKey: callerKey);
  }
}
