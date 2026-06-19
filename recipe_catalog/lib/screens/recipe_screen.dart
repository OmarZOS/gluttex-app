import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:recipe_catalog/components/RecipeCard.dart';
import 'package:recipe_catalog/components/RecipeOwner.dart';
import 'package:recipe_catalog/components/ingredientCard.dart';
import 'package:recipe_catalog/screens/recipe_form_screen.dart';
import 'package:ui/components/confirmation_dialogue.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:event/user_change_notifier.dart';
import 'package:event/recipe_change_notifier.dart';
import 'package:ui/Services/ResponseHandler.dart';
import 'package:provider/provider.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late Recipe _recipe;
  final double _imageHeightRatio = 0.35;

  late RecipeNotifier notifier;

  AppUser? _provider;
  bool _isLoadingProvider = true;
  bool _ingredientsLoaded = false;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    notifier = Provider.of<RecipeNotifier>(context, listen: false);
    _loadProviderData();
    _loadIngredients();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    notifier = Provider.of<RecipeNotifier>(context, listen: false);

    if (_recipe != widget.recipe) {
      _recipe = widget.recipe;
    }
    if (_isLoadingProvider) {
      _loadProviderData();
    }
  }

  Future<void> _loadIngredients() async {
    if (_ingredientsLoaded) return;

    if (notifier.recipeIngredients.isEmpty) {
      await notifier.fetchAllIngredients();
    }
    _ingredientsLoaded = true;
    setState(() {});
  }

  late Future<AppUser?> _providerFuture;

  Future<void> _loadProviderData() async {
    if (_recipe.recipe_owner_id == null) {
      if (mounted) setState(() => _isLoadingProvider = false);
      return;
    }

    if (mounted) setState(() => _isLoadingProvider = true);

    try {
      _providerFuture = notifier.getUserById(_recipe.recipe_owner_id!);
      final provider = await _providerFuture;

      if (!mounted) return;

      setState(() {
        _provider = provider;
        _isLoadingProvider = false;
      });
    } on TimeoutException {
      debugPrint('Timeout loading provider');
      if (mounted) setState(() => _isLoadingProvider = false);
    } catch (e) {
      debugPrint('Error loading provider: $e');
      if (mounted) setState(() => _isLoadingProvider = false);
    }
  }

  /// Get ingredient name from notifier's ingredients
  String _getIngredientName(int id) {
    final ingredient = notifier.getIngredient(id);
    if (ingredient != null && ingredient.ingredient_name.isNotEmpty) {
      return ingredient.ingredient_name;
    }

    // Fallback to translations if API name not available
    try {
      final names = AppLocalizations.of(context)!.ingredientTextList.split(',');
      if (id > 0 && id <= names.length) {
        return names[id - 1];
      }
      return 'Ingredient $id';
    } catch (e) {
      return 'Ingredient $id';
    }
  }

  /// Get ingredient icon URL from notifier's ingredients
  String? _getIngredientIconUrl(int id) {
    final ingredient = notifier.getIngredient(id);
    return ingredient?.ingredient_icon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isOwner = is_recipe_owner(context, _recipe.recipe_owner_id ?? 0);
    final categoryName = AppLocalizations.of(context)!
        .recipeCategoryTextList
        .split(",")[(_recipe.recipe_category_id ?? 1) - 1];

    return Scaffold(
      floatingActionButton: Provider.of<AppUserNotifier>(context, listen: false)
              .isCookingrecipe_catalog
          ? FloatingActionButton(
              heroTag: 'floating-button-2',
              onPressed: () => _navigateToEditScreen(context),
              child: Icon(color: theme.colorScheme.secondary, Icons.edit),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: size.height * _imageHeightRatio,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildRecipeImage(size),
                collapseMode: CollapseMode.parallax,
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: isOwner ? _buildAppBarActions(context) : null,
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRecipeHeader(theme),
              const SizedBox(height: 16),
              _buildPreparationTime(theme),
              const SizedBox(height: 24),
              _buildCategoryTag(theme, categoryName),
              const SizedBox(height: 24),
              if (_recipe.recipe_ingredients?.isNotEmpty ?? false)
                Column(
                  children: [
                    _buildIngredientsList(context),
                    const SizedBox(height: 24),
                  ],
                ),
              _buildInstructionsSection(theme),
              _isLoadingProvider
                  ? const CircularProgressIndicator()
                  : _buildProviderTileContent(_provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(Size size) {
    final hasValidUrl = _recipe.recipe_image_url != null &&
        _recipe.recipe_image_url!.isNotEmpty &&
        (_recipe.recipe_image_url!.startsWith('http') ||
            _recipe.recipe_image_url!.startsWith('https'));

    return hasValidUrl
        ? Hero(
            tag: 'recipe-image-${_recipe.id_recipe}',
            child: Image.network(
              _recipe.recipe_image_url!,
              height: size.height * _imageHeightRatio,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder(size);
              },
            ))
        : _buildImagePlaceholder(size);
  }

  Widget _buildImagePlaceholder(Size size) {
    return Container(
      height: size.height * _imageHeightRatio,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (Theme.of(context).brightness == Brightness.dark)
              ? [
                  const Color.fromARGB(255, 100, 110, 105),
                  AppConstants.backgroundDarkColor,
                ]
              : [
                  AppConstants.backgroundColor,
                  const Color.fromARGB(255, 143, 197, 166),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/${_recipe.recipe_category_id}.svg',
          package: "recipe_catalog",
          color: Theme.of(context).colorScheme.onPrimary,
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.width * 0.2,
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.tertiary),
        onPressed: () => _showDeleteConfirmation(context),
      ),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildRecipeHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _recipe.recipe_name ?? AppLocalizations.of(context)!.recipeNameText,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          notifier.categories.isNotEmpty &&
                  _recipe.recipe_category_id! - 1 < notifier.categories.length
              ? notifier.categories[_recipe.recipe_category_id! - 1]
              : '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildPreparationTime(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          RecipeCard.getRecipePreparationTime(
              context, _recipe.recipe_preparation_time),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildCategoryTag(ThemeData theme, String categoryName) {
    return Chip(
      avatar: SvgPicture.asset(
        'assets/icons/${_recipe.recipe_category_id}.svg',
        package: "recipe_catalog",
        color: theme.colorScheme.onSurface,
      ),
      label: Text(categoryName),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
    );
  }

  Widget _buildIngredientsList(BuildContext context) {
    log("Recipe ingredients: ${_recipe.recipe_ingredients}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.ingredientText,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recipe.recipe_ingredients!.length,
            itemBuilder: (context, index) {
              final key = _recipe.recipe_ingredients!.keys.elementAt(index);
              final quantity = _recipe.recipe_ingredients![key]!;
              final ingredientName = _getIngredientName(key);
              final ingredientIconUrl = _getIngredientIconUrl(key);

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IngredientCard(
                  onClicked: () {},
                  name: ingredientName,
                  quantity: quantity,
                  id: key,
                  imageUrl: ingredientIconUrl,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.instructionsText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _recipe.recipe_instruction ??
              AppLocalizations.of(context)!.noInstructionsAvailableText,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Future<void> _navigateToEditScreen(BuildContext context) async {
    await Navigator.pushNamed(
      context,
      AppRoutes.recipeCreate,
      arguments: {"recipe": _recipe},
    );
    // Refresh the recipe data when coming back
    if (mounted) {
      // Could refresh recipe details if needed
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showConfirmationDialog(
      context,
      AppLocalizations.of(context)!.recipedeletionConfirmationMessage,
      () async {
        try {
          await notifier.deleteRecipe(_recipe.id_recipe!);
          ResponseHandler.handleResponse(
            context: context,
            statusCode: 200,
            responseCode: "SUCCESS",
            finalMessage: AppLocalizations.of(context)!.deleteSuccess,
          );
          if (mounted) Navigator.pop(context);
        } on GluttexException catch (e) {
          ResponseHandler.handleResponse(
            context: context,
            statusCode: e.statusCode ?? 300,
            responseCode: e.message,
            finalMessage: AppLocalizations.of(context)!.deleteFailure,
          );
        }
      },
    );
  }

  Widget _buildProviderTileContent(AppUser? provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.kDefaultPaddin / 8,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.providedBy,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: provider != null && provider.id_app_user != 0
                      ? provider.app_user_image_url != null &&
                              provider.app_user_image_url!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                provider.app_user_image_url!,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    size: 32,
                                    color: colorScheme.primary,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 32,
                              color: colorScheme.primary,
                            )
                      : Icon(
                          Icons.store_outlined,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider != null && provider.id_app_user != 0
                            ? "${provider.personFirstName} ${provider.personLastName}"
                                .trim()
                            : AppLocalizations.of(context)!.unknownProvider,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (provider?.addressCity != null &&
                          provider!.addressCity!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.addressCity!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
