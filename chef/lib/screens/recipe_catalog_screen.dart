import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chef/components/RecipeCard.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:event/user_change_notifier.dart';
import 'package:event/recipe_change_notifier.dart';
import 'package:app_constants/app_constants.dart';
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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);

    // Get reference to notifier
    notifier = Provider.of<RecipeNotifier>(context, listen: false);

    // Use addPostFrameCallback to avoid calling during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeData();
      }
    });
  }

  void _initializeData() {
    // Initialize categories
    _initializeCategories();

    // Fetch initial data
    notifier.fetchRecipes(categoryId: _selectedCategoryId);

    if (notifier.recipeIngredients.isEmpty) {
      log("Fetching ingredients");
      notifier.fetchIngredients();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialize once, and not during build
    if (!_initialized && mounted) {
      _initialized = true;
      // Don't call fetch here, just initialize categories if needed
      _categories = _getCategories();
      notifier.recipeCategories = _categories.skip(1).toList();
    }
  }

  List<String> _getCategories() {
    final categs =
        AppLocalizations.of(context)!.recipeCategoryTextList.split(",");
    return [AppLocalizations.of(context)!.allText, ...categs];
  }

  void _initializeCategories() {
    final categs =
        AppLocalizations.of(context)!.recipeCategoryTextList.split(",");
    setState(() {
      _categories = [AppLocalizations.of(context)!.allText, ...categs];
    });
    notifier.recipeCategories = categs;
  }

  void _onSearchChanged() {
    // Use a debouncer to avoid too many API calls
    _filterRecipesBySearch();
  }

  void _selectCategory(int index) {
    if (_selectedCategoryId == index) return;

    setState(() {
      _selectedCategoryId = index;
    });
    // Use reset=true to clear existing recipes when changing category
    notifier.fetchRecipes(categoryId: _selectedCategoryId, reset: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !notifier.isLoading) {
      notifier.fetchRecipes(categoryId: _selectedCategoryId);
    }
  }

  Future<void> _refreshRecipes() async {
    await notifier.fetchRecipes(categoryId: _selectedCategoryId, reset: true);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      floatingActionButton: Consumer<AppUserNotifier>(
        builder: (context, userNotifier, child) {
          if (!userNotifier.isCookingChef) return Container();
          return FloatingActionButton(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.post_add),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.recipeCreate,
              arguments: {"recipe": Recipe.empty()},
            ),
          );
        },
      ),
      appBar: _buildAppBar(context, colorScheme),
      body: Consumer<RecipeNotifier>(
        builder: (context, recipeNotifier, child) {
          // Only filter recipes if we have categories
          final recipes = _categories.isEmpty
              ? recipeNotifier.recipes
              : recipeNotifier.filterRecipesByCategory(_selectedCategoryId);

          return Column(
            children: [
              if (_categories.isNotEmpty) _buildCategoryChips(colorScheme),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.kDefaultPaddin),
                  child: _buildRecipeList(recipeNotifier, recipes),
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
          onSubmitted: (_) => _filterRecipesBySearch(),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)?.searchTxt,
            prefixIcon: Icon(Icons.search_outlined,
                color: Theme.of(context).colorScheme.onSurface),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () {
                      _searchController.clear();
                      _filterRecipesBySearch();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: _categories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final isSelected = _selectedCategoryId == index;

          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.kDefaultPaddin / 4),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(
                      'assets/icons/$index.svg',
                      package: "chef",
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
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
                horizontal: AppConstants.kDefaultPaddin / 2,
                vertical: AppConstants.kDefaultPaddin / 4,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _filterRecipesBySearch() {
    final query = _searchController.text.trim();
    // Don't search if query is too short
    if (query.isNotEmpty && query.length < 2) return;

    // Use a debouncer to avoid too many API calls
    notifier.fetchRecipes(searchQuery: query, reset: true);
  }

  Widget _buildRecipeList(RecipeNotifier recipeNotifier, List<Recipe> recipes) {
    // Loading state for initial load
    if (recipes.isEmpty && recipeNotifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
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
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        controller: _scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(
                  bottom: AppConstants.kDefaultPaddin,
                ),
                child: RecipeCard(recipe: recipes[index]),
              ),
              childCount: recipes.length,
            ),
          ),

          // Show bottom loader only when we already have data and are loading more
          if (recipeNotifier.isLoading && recipes.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
