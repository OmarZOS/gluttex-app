import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_chef/components/RecipeCard.dart';
import 'package:gluttex_chef/components/RecipeOwner.dart';
import 'package:gluttex_chef/screens/recipe_form_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:provider/provider.dart';

class RecipeCatalogScreen extends StatefulWidget {
  const RecipeCatalogScreen({super.key});

  @override
  State<RecipeCatalogScreen> createState() => _RecipeCatalogScreenState();
}

class _RecipeCatalogScreenState extends State<RecipeCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<String> _categories = [];
  late RecipeNotifier notifier;
  int _selectedCategoryId = 0;
  bool _isSearching = false;

  @override
  void initState() {
    notifier = Provider.of<RecipeNotifier>(context, listen: false);
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.fetchRecipes(_selectedCategoryId);
    });
    if (notifier.recipeIngredients.isEmpty) {
      log("Fetching ingredients again");
      notifier.fetchIngredients();
    }
    log("$notifier.recipeIngredients");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCategories();
  }

  void _initializeCategories() {
    final categs =
        AppLocalizations.of(context)!.recipeCategoryTextList.split(",");
    _categories = [AppLocalizations.of(context)!.allText, ...categs];
    notifier.recipeCategories = categs;
  }

  void _onSearchChanged() {
    setState(() => _isSearching = _searchController.text.isNotEmpty);
  }

  void _selectCategory(int index) {
    setState(() => _selectedCategoryId = index);
    notifier.fetchRecipes(_selectedCategoryId, reset: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !notifier.isLoading) {
      notifier.fetchRecipes(_selectedCategoryId);
    }
  }

  Future<void> _refreshRecipes() async {
    await notifier.fetchRecipes(_selectedCategoryId, reset: true);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _scrollController
      ..removeListener(_scrollListener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      floatingActionButton:
          Provider.of<AppUserNotifier>(context, listen: false).isCookingChef
              ? FloatingActionButton(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.post_add),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RecipeFormScreen()),
                  ),
                )
              : null,
      appBar: _buildAppBar(context, colorScheme),
      // floatingActionButton: _buildAddRecipeButton(context),
      body: Consumer<RecipeNotifier>(
        builder: (context, recipeNotifier, child) {
          final recipes =
              recipeNotifier.filterRecipesByCategory(_selectedCategoryId);
          final filteredRecipes = _filterRecipesBySearch(recipes);

          return Column(
            children: [
              _buildCategoryChips(colorScheme),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GluttexConstants.kDefaultPaddin),
                  child: _buildRecipeList(recipeNotifier, filteredRecipes),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      elevation: 0,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.searchTxt,
            prefixIcon: Icon(Icons.search_outlined,
                color: Theme.of(context).colorScheme.onSurface),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.add_circle),
      //     onPressed: () => Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const RecipeFormScreen()),
      //     ),
      //   ),
      // ],
    );
  }

  // Widget _buildAddRecipeButton(BuildContext context) {
  //   return FloatingActionButton(
  //     backgroundColor: Theme.of(context).colorScheme.primary,
  //     foregroundColor: Theme.of(context).colorScheme.onPrimary,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: const Icon(Icons.add),
  //     onPressed: () => Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const RecipeFormScreen()),
  //     ),
  //   );
  // }

  Widget _buildCategoryChips(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // padding: const EdgeInsets.symmetric(
      //     vertical: GluttexConstants.kDefaultPaddin / 2),
      child: Row(
        children: _categories.map((category) {
          final index = _categories.indexOf(category);
          final isSelected = _selectedCategoryId == index;

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: GluttexConstants.kDefaultPaddin / 4),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/icons/$index.svg',
                      package: "gluttex_chef",
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(category),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => _selectCategory(index),
              backgroundColor: colorScheme.surface,
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              shape: StadiumBorder(
                side: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: GluttexConstants.kDefaultPaddin / 2,
                vertical: GluttexConstants.kDefaultPaddin / 4,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Recipe> _filterRecipesBySearch(List<Recipe> recipes) {
    if (_searchController.text.isEmpty) return recipes;

    return recipes.where((recipe) {
      final query = _searchController.text.toLowerCase();
      return (recipe.recipe_name?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Widget _buildRecipeList(RecipeNotifier recipeNotifier, List<Recipe> recipes) {
    if (recipes.isEmpty && !recipeNotifier.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? AppLocalizations.of(context)!.noRecipesFound
                  : AppLocalizations.of(context)!.notFoundError,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshRecipes,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(
                    bottom: GluttexConstants.kDefaultPaddin),
                child: RecipeCard(recipe: recipes[index]),
              ),
              childCount: recipes.length,
            ),
          ),
          if (recipeNotifier.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
