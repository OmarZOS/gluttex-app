library gluttex_impl_business;

import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class RecipeServiceImpl implements RecipeService {
  List<RecipeCategory> _categories = [];

  // ==================== Recipe CRUD Operations ====================

  @override
  Future<Recipe?> addRecipe(Recipe recipe) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.addRecipeEndpoint}';

      // Convert recipe to JSON
      Map<String, dynamic> requestBody = recipe.toJson();

      // Remove any null values if necessary
      requestBody.removeWhere((key, value) => value == null);

      developer.log('Adding recipe at: $url', name: 'RecipeServiceImpl');
      developer.log('Request body: $requestBody', name: 'RecipeServiceImpl');

      final result = await storageService.insert(url, requestBody);

      if (result == null) {
        developer.log('Failed to add recipe: null response',
            name: 'RecipeServiceImpl');
        return null;
      }

      // Handle different response formats
      if (result is Map<String, dynamic>) {
        // If response contains 'data' field
        if (result.containsKey('data')) {
          return Recipe.fromJson(result['data'] as Map<String, dynamic>);
        }
        return Recipe.fromJson(result);
      }

      return null;
    } catch (e, stacktrace) {
      developer.log('Error adding recipe: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return null;
    }
  }

  @override
  Future<Recipe?> updateRecipe(Recipe updatedRecipe) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.updateRecipeEndpoint}/${updatedRecipe.id_recipe}';

      // Convert recipe to JSON
      Map<String, dynamic> requestBody = updatedRecipe.toJson();
      requestBody.removeWhere((key, value) => value == null);

      developer.log('Updating recipe at: $url', name: 'RecipeServiceImpl');
      developer.log('Request body: $requestBody', name: 'RecipeServiceImpl');

      final result = await storageService.update(
        url,
        updatedRecipe.id_recipe.toString(),
        {},
        requestBody,
      );

      if (result == null) {
        developer.log('Failed to update recipe: null response',
            name: 'RecipeServiceImpl');
        return null;
      }

      if (result is Map<String, dynamic>) {
        if (result.containsKey('data')) {
          return Recipe.fromJson(result['data'] as Map<String, dynamic>);
        }
        return Recipe.fromJson(result);
      }

      return null;
    } catch (e, stacktrace) {
      developer.log('Error updating recipe: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return null;
    }
  }

  @override
  Future<int?> deleteRecipe(String recipeId) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Using DELETE /api/v1/recipes/{recipe_id} (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteRecipeEndpoint}/$recipeId';
      developer.log('Deleting recipe at: $url', name: 'RecipeServiceImpl');

      final result = await storageService.delete(url, recipeId);

      developer.log('Delete result: $result', name: 'RecipeServiceImpl');
      return result;
    } catch (e, stacktrace) {
      developer.log('Error deleting recipe: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return null;
    }
  }

  @override
  Future<Recipe?> getRecipe(String id) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Using GET /api/v1/recipes/{recipe_id}?full=true (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.recipeEndpoint}/$id?full=true';
      developer.log('Getting recipe from: $url', name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('Recipe not found: $id', name: 'RecipeServiceImpl');
        return null;
      }

      // Handle response format (API returns data in 'data' field)
      if (responseData is Map && responseData.containsKey('data')) {
        return Recipe.fromJson(responseData['data'] as Map<String, dynamic>);
      } else if (responseData is Map) {
        return Recipe.fromJson(responseData as Map<String, dynamic>);
      }

      developer.log('Unexpected response format: ${responseData.runtimeType}',
          name: 'RecipeServiceImpl');
      return null;
    } catch (e, stacktrace) {
      developer.log('Error getting recipe: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return null;
    }
  }

  @override
  Future<List<Recipe>?> getAllRecipes(
    int category,
    int page,
    int limit, {
    int user_id = 0,
    String query = "",
  }) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // If there's a search query, use search endpoint
      if (query.isNotEmpty) {
        return await searchRecipesByToken(query, page, limit);
      }

      // Using GET /api/v1/recipes?user_id=&category_id=&offset=&limit= (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllRecipesEndpoint}'
          '?user_id=$user_id&category_id=$category&offset=$page&limit=$limit';

      developer.log('Getting all recipes from: $url',
          name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('No recipes found', name: 'RecipeServiceImpl');
        return [];
      }

      List<Recipe> recipes = [];

      // Handle response format (API returns data in 'data' field)
      if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          recipes = dataList
              .map((data) {
                try {
                  return Recipe.fromJson(data as Map<String, dynamic>);
                } catch (e) {
                  developer.log('Error parsing recipe: $e',
                      name: 'RecipeServiceImpl');
                  return null;
                }
              })
              .where((recipe) => recipe != null)
              .cast<Recipe>()
              .toList();
        }
      } else if (responseData is List) {
        recipes = responseData
            .map((data) {
              try {
                return Recipe.fromJson(data as Map<String, dynamic>);
              } catch (e) {
                developer.log('Error parsing recipe: $e',
                    name: 'RecipeServiceImpl');
                return null;
              }
            })
            .where((recipe) => recipe != null)
            .cast<Recipe>()
            .toList();
      }

      developer.log('Found ${recipes.length} recipes',
          name: 'RecipeServiceImpl');
      return recipes;
    } catch (e, stacktrace) {
      developer.log('Error getting all recipes: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return [];
    }
  }

  // ==================== Search Operations ====================

  Future<List<Recipe>> searchRecipesByToken(
      String token, int offset, int itemsPerPage) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Using GET /api/v1/recipes/search?query=&offset=&limit= (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getRecipeSearchByTokenEndpoint}'
          '?query=$token&offset=$offset&limit=$itemsPerPage';

      developer.log('Searching recipes with token: $token',
          name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('No recipes found for search', name: 'RecipeServiceImpl');
        return [];
      }

      List<Recipe> recipes = [];

      if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          recipes = dataList
              .map(
                  (data) => Recipe.fromSearchJson(data as Map<String, dynamic>))
              .toList();
        }
      } else if (responseData is List) {
        recipes = responseData
            .map((data) => Recipe.fromSearchJson(data as Map<String, dynamic>))
            .toList();
      }

      developer.log('Found ${recipes.length} recipes',
          name: 'RecipeServiceImpl');
      return recipes;
    } catch (e, stacktrace) {
      developer.log('Error searching recipes: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return [];
    }
  }

  // ==================== Category Operations ====================

  @override
  Future<List<RecipeCategory>> getCategories() async {
    if (_categories.isNotEmpty) {
      developer.log('Returning cached categories: ${_categories.length}',
          name: 'RecipeServiceImpl');
      return _categories;
    }

    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Using GET /api/v1/recipes/categories (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getRecipeCategoriesEndpoint}';
      developer.log('Getting recipe categories from: $url',
          name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('No categories found', name: 'RecipeServiceImpl');
        return [];
      }

      List<RecipeCategory> categories = [];

      if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          categories = dataList
              .map((data) =>
                  RecipeCategory.fromJson(data as Map<String, dynamic>))
              .toList();
        }
      } else if (responseData is List) {
        categories = responseData
            .map(
                (data) => RecipeCategory.fromJson(data as Map<String, dynamic>))
            .toList();
      }

      _categories = categories;
      developer.log('Found ${_categories.length} categories',
          name: 'RecipeServiceImpl');

      return _categories;
    } catch (e) {
      developer.log('Error getting categories: $e', name: 'RecipeServiceImpl');
      return [];
    }
  }

  // ==================== Ingredient Operations ====================

  @override
  Future<List<RecipeIngredient>?> getAllIngredients(
      int offset, int limit) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Using GET /api/v1/recipes/ingredients?offset=&limit= (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getIngredientEndpoint}'
          '?offset=$offset&limit=$limit';

      developer.log('Getting ingredients from: $url',
          name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('No ingredients found', name: 'RecipeServiceImpl');
        return [];
      }

      List<RecipeIngredient> ingredients = [];

      if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          ingredients = dataList
              .map((data) =>
                  RecipeIngredient.fromJson(data as Map<String, dynamic>))
              .toList();
        }
      } else if (responseData is List) {
        ingredients = responseData
            .map((data) =>
                RecipeIngredient.fromJson(data as Map<String, dynamic>))
            .toList();
      }

      developer.log('Found ${ingredients.length} ingredients',
          name: 'RecipeServiceImpl');
      return ingredients;
    } catch (e, stacktrace) {
      developer.log('Error getting ingredients: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return [];
    }
  }

  // ==================== Helper Methods ====================

  /// Clear the categories cache
  void clearCache() {
    _categories.clear();
    developer.log('Recipe service cache cleared', name: 'RecipeServiceImpl');
  }

  /// Refresh categories from API
  Future<List<RecipeCategory>> refreshCategories() async {
    _categories.clear();
    return await getCategories();
  }

  /// Get a specific ingredient by ID
  Future<RecipeIngredient?> getIngredientById(int ingredientId) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Using GET /api/v1/recipes/ingredients/{ingredient_id} (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getIngredientEndpoint}/$ingredientId';
      developer.log('Getting ingredient from: $url', name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('Ingredient not found: $ingredientId',
            name: 'RecipeServiceImpl');
        return null;
      }

      if (responseData is Map && responseData.containsKey('data')) {
        return RecipeIngredient.fromJson(
            responseData['data'] as Map<String, dynamic>);
      } else if (responseData is Map) {
        return RecipeIngredient.fromJson(responseData as Map<String, dynamic>);
      }

      return null;
    } catch (e, stacktrace) {
      developer.log('Error getting ingredient: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return null;
    }
  }

  /// Delete an ingredient
  Future<int?> deleteIngredient(int ingredientId) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Using DELETE /api/v1/recipes/ingredients/{ingredient_id} (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteIngredientEndpoint}/$ingredientId';
      developer.log('Deleting ingredient at: $url', name: 'RecipeServiceImpl');

      final result = await storageService.delete(url, ingredientId.toString());

      developer.log('Delete result: $result', name: 'RecipeServiceImpl');
      return result;
    } catch (e, stacktrace) {
      developer.log('Error deleting ingredient: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return null;
    }
  }

  /// Add a new ingredient
  Future<RecipeIngredient?> addIngredient(RecipeIngredient ingredient) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Using POST /api/v1/recipes/ingredients (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getIngredientEndpoint}';
      developer.log('Adding ingredient at: $url', name: 'RecipeServiceImpl');
      developer.log('Ingredient data: ${ingredient.toJson()}',
          name: 'RecipeServiceImpl');

      final result = await storageService.insert(url, ingredient.toJson());

      if (result == null) {
        developer.log('Failed to add ingredient: null response',
            name: 'RecipeServiceImpl');
        return null;
      }

      return RecipeIngredient.fromJson(result as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error adding ingredient: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return null;
    }
  }

  /// Update an existing ingredient
  Future<RecipeIngredient?> updateIngredient(
      RecipeIngredient updatedIngredient) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Using PUT /api/v1/recipes/ingredients/{ingredient_id} (from earlier agreement)
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getIngredientEndpoint}/${updatedIngredient.id_ingredient}';
      developer.log('Updating ingredient at: $url', name: 'RecipeServiceImpl');
      developer.log('Ingredient data: ${updatedIngredient.toJson()}',
          name: 'RecipeServiceImpl');

      final result = await storageService.update(
        url,
        updatedIngredient.id_ingredient.toString(),
        {},
        updatedIngredient.toJson(),
      );

      if (result == null) {
        developer.log('Failed to update ingredient: null response',
            name: 'RecipeServiceImpl');
        return null;
      }

      return RecipeIngredient.fromJson(result as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error updating ingredient: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');
      return null;
    }
  }
}
