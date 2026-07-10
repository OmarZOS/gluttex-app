import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'recipe_state.dart';
import 'recipe_cache.dart';

class RecipeCategoryManager {
  final RecipeService _service;
  final RecipeState _state;

  RecipeCategoryManager({
    required RecipeService service,
    required RecipeState state,
  })  : _service = service,
        _state = state;

  Future<void> fetchCategories({String? callerKey}) async {
    try {
      final fetched = await _service.getCategories(callerKey: callerKey);
      if (fetched?.isNotEmpty ?? false) {
        _state.categories =
            fetched!.map((category) => category.recipe_category_name).toList();
      } else {
        _state.categories = [];
      }
    } catch (e) {
      throw GluttexException('Failed to fetch categories: $e');
    }
  }

  List<String> get categories => _state.categories;
}
