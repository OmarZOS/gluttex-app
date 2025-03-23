import 'package:flutter/material.dart';
import 'package:gluttex_chef/components/RecipeCard.dart';
import 'package:gluttex_chef/screens/recipe_form_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:provider/provider.dart';

class RecipeCatalogScreen extends StatefulWidget {
  const RecipeCatalogScreen({super.key});

  @override
  _RecipeCatalogScreenState createState() => _RecipeCatalogScreenState();
}

class _RecipeCatalogScreenState extends State<RecipeCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRecipes);
  }

  void _filterRecipes() {
    // This method can be updated to filter recipes based on _searchController's text
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchTxt,
              border: InputBorder.none,
              icon: const Icon(Icons.search_outlined)),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RecipeFormScreen()),
              );
            },
          ),
          const SizedBox(width: GluttexConstants.kDefaultPaddin / 2)
        ],
      ),
      body: Consumer<RecipeNotifier>(
        builder: (context, recipeNotifier, child) {
          var recipes = recipeNotifier.recipes;
          var filteredRecipes = recipes.where((recipe) {
            var query = _searchController.text.toLowerCase();
            return recipe.recipe_name?.toLowerCase().contains(query) ?? false;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GluttexConstants.kDefaultPaddin),
                  child: RefreshIndicator(
                    onRefresh: recipeNotifier.fetchRecipes,
                    child: _buildRecipeGrid(filteredRecipes),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecipeGrid(List<Recipe> recipes) {
    if (recipes.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noRecipesFound));
    }

    return GridView.builder(
      itemCount: recipes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: GluttexConstants.kDefaultPaddin,
        crossAxisSpacing: GluttexConstants.kDefaultPaddin,
        // childAspectRatio:
        // 0.5, // Adjust childAspectRatio to fit your layout needs
      ),
      itemBuilder: (context, index) => RecipeCard(
        recipe: recipes[index],
      ),
    );
  }
}
