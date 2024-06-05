import '../Recipe.dart';

// RecipeService.dart
abstract class RecipeService {
  Future<List<RecipeCategory>?>? getCategories() async {
    return null;
  }

  Future<List<Recipe>?>? getAllRecipes() async {
    return null;
  }

  Future<Recipe?> getRecipe(String idRecipe) async {
    return null;
  }

  Future<int?> addRecipe(Recipe recipe) async {
    return null;
  }

  Future<int?> updateRecipe(Recipe updatedRecipe) async {
    return null;
  }

  Future<int?> deleteRecipe(String recipeId) async {
    return null;
  }
}
