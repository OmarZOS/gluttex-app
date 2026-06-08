library gluttex_impl_business;

import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class RecipeServiceImpl extends RecipeService {
  final StorageService _storageService = GluttexLocator.get<StorageService>();
  List<RecipeCategory> _categories = [];

  // Helper method to generate caller key
  String getCallerKey(String method, {String? id, String? suffix}) {
    final parts = [method];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    if (parts.length == 1) {
      parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    }
    debugPrint('🔑 Generated caller key: ${parts.join('_')}');
    return parts.join('_');
  }

  // ============ RESPONSE TRACKING METHODS ============

  void _storeSuccessResponse(String callerKey, dynamic data,
      {int? statusCode, String? responseCode}) {
    _storageService.setSuccessResponse(callerKey, data,
        statusCode: statusCode ?? 200, responseCode: responseCode ?? 'SUCCESS');
    debugPrint('✅ Stored SUCCESS: $callerKey - ${responseCode ?? 'SUCCESS'}');
    developer.log('✅ Stored SUCCESS: $callerKey - ${responseCode ?? 'SUCCESS'}',
        name: 'RecipeServiceImpl');
  }

  void _storeFailureResponse(String callerKey, dynamic data,
      {int? statusCode,
      String? errorCode,
      String? message,
      String? responseCode}) {
    final finalResponseCode = responseCode ?? 'FAILED';
    _storageService.setFailureResponse(callerKey,
        data: data,
        statusCode: statusCode ?? 500,
        errorCode: errorCode,
        message: message,
        responseCode: finalResponseCode);
    debugPrint('❌ Stored FAILURE: $callerKey - $finalResponseCode');
    developer.log('❌ Stored FAILURE: $callerKey - $finalResponseCode',
        name: 'RecipeServiceImpl');
  }

  // ==================== Recipe CRUD Operations ====================

  @override
  Future<Recipe?> addRecipe(Recipe recipe, {String? callerKey}) async {
    final key =
        callerKey ?? getCallerKey('addRecipe', suffix: recipe.recipe_name);

    debugPrint('📝 addRecipe - Starting for recipe: ${recipe.recipe_name}');
    debugPrint('   CallerKey: $key');

    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.addRecipeEndpoint}';

      Map<String, dynamic> requestBody = recipe.toJson();
      requestBody.removeWhere((key, value) => value == null);

      debugPrint('📤 POST to: $url');
      debugPrint('   Request body: ${requestBody.keys}');

      developer.log('Adding recipe at: $url', name: 'RecipeServiceImpl');
      developer.log('Request body: $requestBody', name: 'RecipeServiceImpl');

      final result =
          await storageService.insert(url, requestBody, callerKey: key);

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      debugPrint(
          '📥 Response - StatusCode: $statusCode, ResponseCode: $responseCode');

      if (result != null) {
        Recipe? createdRecipe;
        if (result is Map<String, dynamic>) {
          if (result.containsKey('data')) {
            createdRecipe =
                Recipe.fromJson(result['data'] as Map<String, dynamic>);
          } else {
            createdRecipe = Recipe.fromJson(result);
          }
        }

        if (createdRecipe != null) {
          debugPrint(
              '✅ Recipe created successfully. ID: ${createdRecipe.id_recipe}');
          _storeSuccessResponse(key, createdRecipe,
              statusCode: statusCode ?? 200,
              responseCode: responseCode ?? 'RECIPE_CREATED');
          return createdRecipe;
        }
      }

      debugPrint('❌ Failed to add recipe - Result is null or invalid');
      _storeFailureResponse(key, null,
          statusCode: statusCode ?? 500,
          errorCode: 'ADD_RECIPE_FAILED',
          message: 'Failed to add recipe',
          responseCode: responseCode ?? 'ADD_RECIPE_FAILED');
      return null;
    } catch (e, stacktrace) {
      debugPrint('❌ Exception in addRecipe: $e');
      debugPrint(
          '   Stacktrace: ${stacktrace.toString().substring(0, 200)}...');

      developer.log('Error adding recipe: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');

      String errorCode = 'ADD_RECIPE_ERROR';
      String message = 'Failed to add recipe: $e';
      String responseCode = 'ADD_RECIPE_ERROR';
      int statusCode = 500;

      if (e is GluttexException) {
        statusCode = e.statusCode ?? statusCode;
        errorCode = e.message;
        message = e.message;
        responseCode = e.message;
        debugPrint(
            '   GluttexException - Code: $errorCode, Status: $statusCode');
      }

      _storeFailureResponse(key, e.toString(),
          statusCode: statusCode,
          errorCode: errorCode,
          message: message,
          responseCode: responseCode);
      return null;
    }
  }

  @override
  Future<Recipe?> updateRecipe(Recipe updatedRecipe,
      {String? callerKey}) async {
    final key = callerKey ??
        getCallerKey('updateRecipe', id: updatedRecipe.id_recipe.toString());

    debugPrint(
        '✏️ updateRecipe - Starting for recipe ID: ${updatedRecipe.id_recipe}');
    debugPrint('   CallerKey: $key');

    try {
      final storageService = GluttexLocator.get<StorageService>();

      const url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.updateRecipeEndpoint}';

      Map<String, dynamic> requestBody = updatedRecipe.toJson();
      requestBody.removeWhere((key, value) => value == null);

      debugPrint('📤 PUT to: $url');
      debugPrint('   Recipe ID: ${updatedRecipe.id_recipe}');

      developer.log('Updating recipe at: $url', name: 'RecipeServiceImpl');
      developer.log('Request body: $requestBody', name: 'RecipeServiceImpl');

      final result = await storageService.update(
        url,
        updatedRecipe.id_recipe.toString(),
        {},
        requestBody,
        callerKey: key,
      );

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      debugPrint(
          '📥 Response - StatusCode: $statusCode, ResponseCode: $responseCode');

      if (result != null) {
        Recipe? updatedRecipeResult;
        if (result is Map<String, dynamic>) {
          if (result.containsKey('data')) {
            updatedRecipeResult =
                Recipe.fromJson(result['data'] as Map<String, dynamic>);
          } else {
            updatedRecipeResult = Recipe.fromJson(result);
          }
        }

        if (updatedRecipeResult != null) {
          debugPrint(
              '✅ Recipe updated successfully. ID: ${updatedRecipeResult.id_recipe}');
          _storeSuccessResponse(key, updatedRecipeResult,
              statusCode: statusCode ?? 200,
              responseCode: responseCode ?? 'RECIPE_UPDATED');
          return updatedRecipeResult;
        }
      }

      debugPrint('❌ Failed to update recipe - Result is null or invalid');
      _storeFailureResponse(key, null,
          statusCode: statusCode ?? 500,
          errorCode: 'UPDATE_RECIPE_FAILED',
          message: 'Failed to update recipe',
          responseCode: responseCode ?? 'UPDATE_RECIPE_FAILED');
      return null;
    } catch (e, stacktrace) {
      debugPrint('❌ Exception in updateRecipe: $e');

      developer.log('Error updating recipe: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');

      String errorCode = 'UPDATE_RECIPE_ERROR';
      String message = 'Failed to update recipe: $e';
      String responseCode = 'UPDATE_RECIPE_ERROR';
      int statusCode = 500;

      if (e is GluttexException) {
        statusCode = e.statusCode ?? statusCode;
        errorCode = e.message;
        message = e.message;
        responseCode = e.message;
      }

      _storeFailureResponse(key, e.toString(),
          statusCode: statusCode,
          errorCode: errorCode,
          message: message,
          responseCode: responseCode);
      return null;
    }
  }

  @override
  Future<int?> deleteRecipe(String recipeId, {String? callerKey}) async {
    final key = callerKey ?? getCallerKey('deleteRecipe', id: recipeId);

    debugPrint('🗑️ deleteRecipe - Starting for recipe ID: $recipeId');
    debugPrint('   CallerKey: $key');

    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteRecipeEndpoint}/$recipeId';

      debugPrint('📤 DELETE to: $url');

      developer.log('Deleting recipe at: $url', name: 'RecipeServiceImpl');

      final result = await storageService.delete(url, recipeId, callerKey: key);

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      debugPrint(
          '📥 Response - StatusCode: $statusCode, ResponseCode: $responseCode');

      if (result == 200 || result == 204) {
        debugPrint('✅ Recipe deleted successfully');
        _storeSuccessResponse(key, true,
            statusCode: result, responseCode: responseCode ?? 'RECIPE_DELETED');
      } else {
        debugPrint('❌ Failed to delete recipe - Status: $result');
        _storeFailureResponse(key, false,
            statusCode: result,
            errorCode: 'DELETE_RECIPE_FAILED',
            message: 'Failed to delete recipe',
            responseCode: responseCode ?? 'DELETE_RECIPE_FAILED');
      }

      return result;
    } catch (e, stacktrace) {
      debugPrint('❌ Exception in deleteRecipe: $e');

      developer.log('Error deleting recipe: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');

      String errorCode = 'DELETE_RECIPE_ERROR';
      String message = 'Failed to delete recipe: $e';
      String responseCode = 'DELETE_RECIPE_ERROR';
      int statusCode = 500;

      if (e is GluttexException) {
        statusCode = e.statusCode ?? statusCode;
        errorCode = e.message;
        message = e.message;
        responseCode = e.message;
      }

      _storeFailureResponse(key, e.toString(),
          statusCode: statusCode,
          errorCode: errorCode,
          message: message,
          responseCode: responseCode);
      return null;
    }
  }

  @override
  Future<Recipe?> getRecipe(String id, {String? callerKey}) async {
    final key = callerKey ?? getCallerKey('getRecipe', id: id);

    debugPrint('🔍 getRecipe - Starting for recipe ID: $id');
    debugPrint('   CallerKey: $key');

    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.recipeEndpoint}/$id?full=true';

      debugPrint('📤 GET from: $url');

      developer.log('Getting recipe from: $url', name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url, callerKey: key);

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      debugPrint(
          '📥 Response - StatusCode: $statusCode, ResponseCode: $responseCode');

      if (responseData == null) {
        debugPrint('❌ Recipe not found: $id');
        _storeFailureResponse(key, null,
            statusCode: statusCode ?? 404,
            errorCode: 'RECIPE_NOT_FOUND',
            message: 'Recipe not found',
            responseCode: responseCode ?? 'NOT_FOUND');
        return null;
      }

      Recipe? recipe;
      if (responseData is Map && responseData.containsKey('data')) {
        recipe = Recipe.fromJson(responseData['data'] as Map<String, dynamic>);
      } else if (responseData is Map) {
        recipe = Recipe.fromJson(responseData as Map<String, dynamic>);
      }

      if (recipe != null) {
        debugPrint(
            '✅ Recipe found: ${recipe.recipe_name} (ID: ${recipe.id_recipe})');
        _storeSuccessResponse(key, recipe,
            statusCode: statusCode ?? 200,
            responseCode: responseCode ?? 'SUCCESS');
      } else {
        debugPrint('❌ Invalid response format for recipe ID: $id');
        _storeFailureResponse(key, responseData,
            statusCode: statusCode ?? 500,
            errorCode: 'INVALID_RESPONSE',
            message: 'Invalid response format',
            responseCode: 'INVALID_RESPONSE');
      }

      return recipe;
    } catch (e, stacktrace) {
      debugPrint('❌ Exception in getRecipe: $e');

      developer.log('Error getting recipe: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');

      String errorCode = 'GET_RECIPE_ERROR';
      String message = 'Failed to get recipe: $e';
      String responseCode = 'GET_RECIPE_ERROR';
      int statusCode = 500;

      if (e is GluttexException) {
        statusCode = e.statusCode ?? statusCode;
        errorCode = e.message;
        message = e.message;
        responseCode = e.message;
      }

      _storeFailureResponse(key, e.toString(),
          statusCode: statusCode,
          errorCode: errorCode,
          message: message,
          responseCode: responseCode);
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
    String? callerKey,
  }) async {
    final key = callerKey ??
        getCallerKey('getAllRecipes', suffix: '${category}_${page}_$limit');

    debugPrint(
        '📋 getAllRecipes - Category: $category, Page: $page, Limit: $limit');
    debugPrint('   Query: "${query.isEmpty ? "(none)" : query}"');
    debugPrint('   CallerKey: $key');

    try {
      final storageService = GluttexLocator.get<StorageService>();

      if (query.isNotEmpty) {
        debugPrint('   Using search endpoint for query: $query');
        return await searchRecipesByToken(query, page, limit, callerKey: key);
      }

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllRecipesEndpoint}'
          '?user_id=$user_id&category_id=$category&offset=$page&limit=$limit';

      debugPrint('📤 GET from: $url');

      developer.log('Getting all recipes from: $url',
          name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url, callerKey: key);

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      debugPrint(
          '📥 Response - StatusCode: $statusCode, ResponseCode: $responseCode');

      if (responseData == null) {
        debugPrint('⚠️ No recipes found');
        _storeSuccessResponse(key, [],
            statusCode: statusCode ?? 200,
            responseCode: responseCode ?? 'NO_RECIPES');
        return [];
      }

      List<Recipe> recipes = [];

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

      debugPrint('✅ Found ${recipes.length} recipes');
      _storeSuccessResponse(key, recipes,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'SUCCESS');

      return recipes;
    } catch (e, stacktrace) {
      debugPrint('❌ Exception in getAllRecipes: $e');

      developer.log('Error getting all recipes: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');

      String errorCode = 'GET_RECIPES_ERROR';
      String message = 'Failed to get recipes: $e';
      String responseCode = 'GET_RECIPES_ERROR';
      int statusCode = 500;

      if (e is GluttexException) {
        statusCode = e.statusCode ?? statusCode;
        errorCode = e.message;
        message = e.message;
        responseCode = e.message;
      }

      _storeFailureResponse(key, e.toString(),
          statusCode: statusCode,
          errorCode: errorCode,
          message: message,
          responseCode: responseCode);
      return [];
    }
  }

  // ==================== Search Operations ====================

  Future<List<Recipe>> searchRecipesByToken(
      String token, int offset, int itemsPerPage,
      {String? callerKey}) async {
    final key =
        callerKey ?? getCallerKey('searchRecipesByToken', suffix: token);

    debugPrint('🔎 searchRecipesByToken - Token: "$token"');
    debugPrint('   Offset: $offset, ItemsPerPage: $itemsPerPage');
    debugPrint('   CallerKey: $key');

    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getRecipeSearchByTokenEndpoint}'
          '?query=$token&offset=$offset&limit=$itemsPerPage';

      debugPrint('📤 GET from: $url');

      developer.log('Searching recipes with token: $token',
          name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url, callerKey: key);

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      debugPrint(
          '📥 Response - StatusCode: $statusCode, ResponseCode: $responseCode');

      if (responseData == null) {
        debugPrint('⚠️ No recipes found for search');
        _storeSuccessResponse(key, [],
            statusCode: statusCode ?? 200,
            responseCode: responseCode ?? 'NO_RESULTS');
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

      debugPrint('✅ Found ${recipes.length} recipes matching search');
      _storeSuccessResponse(key, recipes,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'SEARCH_SUCCESS');

      return recipes;
    } catch (e, stacktrace) {
      debugPrint('❌ Exception in searchRecipesByToken: $e');

      developer.log('Error searching recipes: $e', name: 'RecipeServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'RecipeServiceImpl');

      String errorCode = 'SEARCH_RECIPES_ERROR';
      String message = 'Failed to search recipes: $e';
      String responseCode = 'SEARCH_RECIPES_ERROR';
      int statusCode = 500;

      if (e is GluttexException) {
        statusCode = e.statusCode ?? statusCode;
        errorCode = e.message;
        message = e.message;
        responseCode = e.message;
      }

      _storeFailureResponse(key, e.toString(),
          statusCode: statusCode,
          errorCode: errorCode,
          message: message,
          responseCode: responseCode);
      return [];
    }
  }

  // ==================== Category Operations ====================

  @override
  Future<List<RecipeCategory>> getCategories({String? callerKey}) async {
    final key = callerKey ?? getCallerKey('getCategories');

    debugPrint('📂 getCategories - Fetching recipe categories');
    debugPrint('   CallerKey: $key');

    if (_categories.isNotEmpty) {
      debugPrint('📦 Returning ${_categories.length} cached categories');
      _storeSuccessResponse(key, _categories,
          statusCode: 200, responseCode: 'CACHED');
      return _categories;
    }

    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getRecipeCategoriesEndpoint}';

      debugPrint('📤 GET from: $url');

      developer.log('Getting recipe categories from: $url',
          name: 'RecipeServiceImpl');

      final responseData = await storageService.getAll(url, callerKey: key);

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      debugPrint(
          '📥 Response - StatusCode: $statusCode, ResponseCode: $responseCode');

      if (responseData == null) {
        debugPrint('⚠️ No categories found');
        _storeFailureResponse(key, null,
            statusCode: statusCode ?? 404,
            errorCode: 'NO_CATEGORIES',
            message: 'No categories found',
            responseCode: responseCode ?? 'NO_CATEGORIES');
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
      debugPrint('✅ Found ${_categories.length} categories');

      _storeSuccessResponse(key, _categories,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'SUCCESS');

      return _categories;
    } catch (e) {
      debugPrint('❌ Exception in getCategories: $e');
      developer.log('Error getting categories: $e', name: 'RecipeServiceImpl');

      String errorCode = 'GET_CATEGORIES_ERROR';
      String message = 'Failed to get categories: $e';
      String responseCode = 'GET_CATEGORIES_ERROR';
      int statusCode = 500;

      if (e is GluttexException) {
        statusCode = e.statusCode ?? statusCode;
        errorCode = e.message;
        message = e.message;
        responseCode = e.message;
      }

      _storeFailureResponse(key, e.toString(),
          statusCode: statusCode,
          errorCode: errorCode,
          message: message,
          responseCode: responseCode);
      return [];
    }
  }
}
