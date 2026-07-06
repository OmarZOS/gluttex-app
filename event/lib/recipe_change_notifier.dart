import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:event/TraceableNotifier.dart';
import 'package:locator/locator.dart';

class RecipeNotifier extends TraceableNotifier {
  final RecipeService _recipeService = AppLocator.get<RecipeService>();

  final Map<int, Recipe> _recipes = {};
  final Map<int, RecipeIngredient> _recipeIngredients = {};
  bool isLoading = false;
  String currentSearch = "";
  int currentPage = 0;
  int currentCategory = 0;
  final int itemsPerPage = AppConstants.itemsPerPage;

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
    await fetchCategories();
    await fetchRecipes(reset: true);
  }

  RecipeNotifier() {
    initialize();
  }

  // ==================== Category Management ====================

  Future<void> fetchCategories({String? callerKey}) async {
    final key = callerKey ?? getCallerKey('fetchCategories');

    try {
      final fetchedCategories =
          await _recipeService.getCategories(callerKey: key);

      if (fetchedCategories?.isNotEmpty ?? false) {
        _recipeCategories = fetchedCategories!
            .map((category) => category.recipe_category_name)
            .toList();
        storeSuccess(key, _recipeCategories);
      } else {
        storeSuccess(key, [], responseCode: 'EMPTY');
      }
      notifyListeners();
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Failed to fetch categories', error: e);
    }
  }

  // ==================== Recipe Management ====================

  Future<bool> addOrUpdateRecipe(Recipe recipe, {String? callerKey}) async {
    final key = callerKey ??
        getCallerKey(
            recipe.id_recipe == null || recipe.id_recipe == 0
                ? 'addRecipe'
                : 'updateRecipe',
            id: recipe.id_recipe?.toString(),
            suffix: recipe.recipe_name);

    try {
      logInfo('Adding/updating recipe: ${recipe.recipe_name}');

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
          storeSuccess(key, data);
        } else {
          storeFailure(key, null, code: 500, errorCode: 'ADD_FAILED');
        }
      } else {
        data = await _recipeService.updateRecipe(recipe, callerKey: key);
        if (data != null) {
          _recipes[recipe.id_recipe!] = data;
          storeSuccess(key, data);
        } else {
          storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
        }
      }

      if (data != null) {
        await fetchRecipes(categoryId: currentCategory, reset: true);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Failed to add/update recipe', error: e);
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
        getCallerKey('fetchRecipes',
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
        storeSuccess(key, fetchedRecipes);

        if (fetchedRecipes.length < itemsPerPage) {
          _hasMoreRecipes = false;
        }
      } else {
        _hasMoreRecipes = false;
        storeSuccess(key, [], responseCode: 'EMPTY');
      }

      notifyListeners();
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Failed to fetch recipes', error: e);
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
        callerKey ?? getCallerKey('deleteRecipe', id: idRecipe.toString());

    try {
      int? status = await _recipeService.deleteRecipe(idRecipe.toString(),
          callerKey: key);

      if (status == 200 || status == 204) {
        _recipes.remove(idRecipe);
        storeSuccess(key, true);
        notifyListeners();
        return true;
      } else {
        storeFailure(key, false, code: status);
        return false;
      }
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Failed to delete recipe', error: e);
      return false;
    }
  }

  // ==================== Ingredient Management ====================

  Future<void> fetchIngredients({bool reset = false, String? callerKey}) async {
    final key = callerKey ??
        getCallerKey('fetchIngredients',
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
        storeSuccess(key, fetchedIngredients);

        if (fetchedIngredients.length < ingredientsPerPage) {
          hasMoreIngredients = false;
        }
      } else {
        hasMoreIngredients = false;
        storeSuccess(key, [], responseCode: 'EMPTY');
      }

      notifyListeners();
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Failed to fetch ingredients', error: e);
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
    final key = callerKey ?? getCallerKey('getUserById', id: id.toString());

    final existingUser = _users.firstWhere(
      (user) => user.idAppUser == id,
      orElse: () => AppUser.empty(),
    );

    if (existingUser.idAppUser != 0) {
      storeSuccess(key, existingUser, responseCode: 'CACHED');
      return existingUser;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result_user =
          await AppLocator.get<AppUserService>().getAppUser(id.toString());

      if (result_user != null && result_user.idAppUser != 0) {
        _users.add(result_user);
        storeSuccess(key, result_user);
        notifyListeners();
        return result_user;
      }
      storeFailure(key, null, code: 404, errorCode: 'NOT_FOUND');
      return null;
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Error fetching user by ID', error: e);
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
    logInfo('Cache cleared');
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
    logInfo('Notifier reset');
    notifyListeners();
  }

  // ============ Additional Ingredient Methods ============

  Future<void> fetchAllIngredients({String? callerKey}) async {
    final key = callerKey ?? getCallerKey('fetchAllIngredients');

    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final fetchedIngredients = await _recipeService.getAllIngredients(
        0,
        1000,
        callerKey: key,
      );

      if (fetchedIngredients != null && fetchedIngredients.isNotEmpty) {
        _recipeIngredients.clear();
        for (var ingredient in fetchedIngredients) {
          _recipeIngredients[ingredient.id_ingredient] = ingredient;
        }
        storeSuccess(key, fetchedIngredients);
      } else {
        storeSuccess(key, [], responseCode: 'EMPTY');
      }
      notifyListeners();
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Failed to fetch all ingredients', error: e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  RecipeIngredient? getIngredient(int id) {
    return _recipeIngredients[id];
  }

  List<RecipeIngredient> getAllIngredients() {
    return _recipeIngredients.values.toList();
  }

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

  Future<bool> addIngredient(String name, String iconUrl,
      {String? callerKey}) async {
    final key = callerKey ?? getCallerKey('addIngredient', suffix: name);

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
        storeSuccess(key, created);
        notifyListeners();
        return true;
      }
      storeFailure(key, null, code: 500, errorCode: 'ADD_FAILED');
      return false;
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Failed to add ingredient', error: e);
      return false;
    }
  }

  Future<bool> updateIngredient(int id, String name, String iconUrl,
      {String? callerKey}) async {
    final key =
        callerKey ?? getCallerKey('updateIngredient', id: id.toString());

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
        storeSuccess(key, updated);
        notifyListeners();
        return true;
      }
      storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
      return false;
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Failed to update ingredient', error: e);
      return false;
    }
  }

  Future<bool> deleteIngredient(int id, {String? callerKey}) async {
    final key =
        callerKey ?? getCallerKey('deleteIngredient', id: id.toString());

    try {
      final result =
          await _recipeService.deleteIngredient(id.toString(), callerKey: key);

      if (result == 200 || result == 204) {
        _recipeIngredients.remove(id);
        storeSuccess(key, true);
        notifyListeners();
        return true;
      }
      storeFailure(key, false, code: result);
      return false;
    } catch (e) {
      storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      logError('Failed to delete ingredient', error: e);
      return false;
    }
  }

  Future<void> refreshIngredients({String? callerKey}) async {
    _recipeIngredients.clear();
    currentIngredientPage = 0;
    hasMoreIngredients = true;
    await fetchAllIngredients(callerKey: callerKey);
  }
}
