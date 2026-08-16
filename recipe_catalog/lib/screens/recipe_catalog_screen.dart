import 'dart:async';
import 'dart:developer';

import 'package:app_constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recipe_catalog/components/RecipeCard.dart';
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

  late RecipeNotifier _recipeNotifier;
  late AppUserNotifier _userNotifier;

  List<String> _categories = [];
  int _selectedCategoryId = 0;
  bool _isSearching = false;
  bool _initialized = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get notifiers from parent
    _recipeNotifier = context.read<RecipeNotifier>();
    _userNotifier = context.read<AppUserNotifier>();

    // Initialize once
    if (!_initialized && mounted) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeData();
        }
      });
    }
  }

  void _initializeData() {
    // Initialize categories
    _initializeCategories();

    // Fetch initial data
    _recipeNotifier.fetchRecipes(categoryId: _selectedCategoryId);

    if (_recipeNotifier.recipeIngredients.isEmpty) {
      log("Fetching ingredients");
      _recipeNotifier.fetchIngredients();
    }
  }

  List<String> _getCategories() {
    final loc = AppLocalizations.of(context)!;
    final categs = loc.recipeCategoryTextList.split(",");
    return [loc.allText, ...categs];
  }

  void _initializeCategories() {
    final loc = AppLocalizations.of(context)!;
    final categs = loc.recipeCategoryTextList.split(",");
    setState(() {
      _categories = [loc.allText, ...categs];
    });
    _recipeNotifier.recipeCategories = categs;
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      _recipeNotifier.fetchRecipes(
          categoryId: _selectedCategoryId, reset: true);
      return;
    }

    // Debounce search
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 2) {
        _recipeNotifier.fetchRecipes(searchQuery: query, reset: true);
      }
    });
  }

  void _selectCategory(int index) {
    if (_selectedCategoryId == index) return;

    setState(() {
      _selectedCategoryId = index;
    });
    _recipeNotifier.fetchRecipes(categoryId: index, reset: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_recipeNotifier.isLoading) {
      _recipeNotifier.fetchRecipes(categoryId: _selectedCategoryId);
    }
  }

  Future<void> _refreshRecipes() async {
    await _recipeNotifier.fetchRecipes(
      categoryId: _selectedCategoryId,
      reset: true,
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: _buildFAB(colorScheme),
      appBar: _buildAppBar(colorScheme, loc),
      body: _buildBody(theme, colorScheme, loc),
    );
  }

  Widget _buildFAB(ColorScheme colorScheme) {
    if (!_userNotifier.isCookingRecipe) return const SizedBox.shrink();

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
  }

  AppBar _buildAppBar(ColorScheme colorScheme, AppLocalizations loc) {
    return AppBar(
      elevation: 0,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _onSearchChanged(),
          decoration: InputDecoration(
            hintText: loc.searchTxt,
            prefixIcon:
                Icon(Icons.search_outlined, color: colorScheme.onSurface),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear,
                        size: 18, color: colorScheme.onSurface),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged();
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

  Widget _buildBody(
      ThemeData theme, ColorScheme colorScheme, AppLocalizations loc) {
    final recipes = _categories.isEmpty
        ? _recipeNotifier.recipes
        : _recipeNotifier.filterRecipesByCategory(_selectedCategoryId);

    return Column(
      children: [
        if (_categories.isNotEmpty) _buildCategoryChips(colorScheme),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.kDefaultPaddin,
            ),
            child: _buildRecipeList(theme, colorScheme, loc, recipes),
          ),
        ),
      ],
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
                      package: "recipe_catalog",
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

  Widget _buildRecipeList(
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations loc,
    List<Recipe> recipes,
  ) {
    // Loading state for initial load
    if (recipes.isEmpty && _recipeNotifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (recipes.isEmpty && !_recipeNotifier.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? loc.noRecipesFound
                  : loc.notFoundError,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshRecipes,
      color: colorScheme.primary,
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
          if (_recipeNotifier.isLoading && recipes.isNotEmpty)
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
