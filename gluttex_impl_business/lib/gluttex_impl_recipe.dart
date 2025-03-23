library gluttex_impl_business;

import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class RecipeServiceImpl implements RecipeService {
  List<RecipeCategory> categories = [];

  @override
  Future<Uint8List?> getRecipeImage(String id) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    List<dynamic> data = await storageService.get(
        GluttexConstants.apiBaseUrl + GluttexConstants.getRecipeImageEndpoint,
        id) as List<dynamic>;
    return Recipe.imageFromJson(data);
  }

  @override
  Future<int?> addRecipe(Recipe Recipe) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addRecipeEndpoint,
        Recipe.toJson());
  }

  @override
  Future<int?> deleteRecipe(String RecipeId) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.delete(
        GluttexConstants.apiBaseUrl + GluttexConstants.deleteRecipeEndpoint,
        RecipeId);
  }

  @override
  Future<int?> updateRecipe(Recipe updatedRecipe) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    return await storageService.update(
        GluttexConstants.apiBaseUrl + GluttexConstants.recipeEndpoint,
        '${updatedRecipe.id_recipe}',
        updatedRecipe.toJson());
  }

  @override
  Future<Recipe?> getRecipe(String id) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    Map<String, dynamic> data = storageService.get(
            GluttexConstants.apiBaseUrl + GluttexConstants.recipeEndpoint, id)
        as Map<String, dynamic>;
    return Recipe.fromJson(data) as Future<Recipe?>;
  }

  @override
  Future<List<Recipe>?>? getAllRecipes(int page, int limit) async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all recipes
      List<dynamic> responseData = await storageService.getAll(
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllRecipesEndpoint}/$page/$limit");
      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Recipe objects
      List dateien = responseData;
      List<Recipe?> recipes = dateien
          .map((data) => Recipe.fromJson(data as Map<String, dynamic>))
          .toList();
      return recipes as List<Recipe>?;
    } catch (e, stacktrace) {
      developer.log(e.toString());
      developer.log(stacktrace.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<List<RecipeCategory>>? getCategories() async {
    if (categories.isNotEmpty) return categories;
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all categories
      List<dynamic> responseData = await storageService.getAll(
          GluttexConstants.apiBaseUrl +
              GluttexConstants.getRecipeCategoriesEndpoint);

      // Check if the response data is not null and is a list
      // Convert the list of RecipeCategory maps to a list of Supplier objects
      List dateien = responseData;
      List<RecipeCategory?> categories = dateien
          .map((data) => RecipeCategory.fromJson(data as Map<String, dynamic>))
          .toList();
      // developer.//log('${dateien.length}');
      return categories as List<RecipeCategory>;
    } catch (e) {
      developer.log(e.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<List<RecipeIngredient>?> getAllIngredients() async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all categories
      List<dynamic> responseData = await storageService.getAll(
          GluttexConstants.apiBaseUrl + GluttexConstants.getIngredientEndpoint);

      // Check if the response data is not null and is a list
      // Convert the list of RecipeCategory maps to a list of Supplier objects
      List dateien = responseData;
      developer.log(dateien.toString());
      List<RecipeIngredient>? mappedIngredients = dateien
          .map(
              (data) => RecipeIngredient.fromJson(data as Map<String, dynamic>))
          .toList();
      // developer.//log('${dateien.length}');
      return mappedIngredients;
    } catch (e) {
      developer.log(e.toString());
      // Handle exceptions here
      return [];
    }
  }
}
