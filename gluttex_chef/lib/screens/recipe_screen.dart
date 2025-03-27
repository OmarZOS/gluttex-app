import 'package:flutter/material.dart';
import 'package:gluttex_chef/components/RecipeCard.dart';
import 'package:gluttex_chef/components/RecipeOwner.dart';
import 'package:gluttex_chef/components/ingredientCard.dart';
import 'package:gluttex_chef/screens/recipe_update_form_screen.dart';
import 'package:gluttex_chef/tools/confirmation_dialogue.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:provider/provider.dart';

class DetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const DetailsScreen({super.key, required this.recipe});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Recipe _recipe;
  final double _imageHeightRatio = 0.35;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
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
                _buildIngredientsList(context),
              const SizedBox(height: 24),
              _buildInstructionsSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(Size size) {
    return Hero(
      tag: 'recipe-image-${_recipe.id_recipe}-recipe.recipe_image_url',
      child: _recipe.recipe_image_url != null &&
              _recipe.recipe_image_url!.isNotEmpty
          ? Image.network(
              GluttexConstants.fsBaseUrl + _recipe.recipe_image_url!,
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
            )
          : _buildImagePlaceholder(size),
    );
  }

  Widget _buildImagePlaceholder(Size size) {
    return Container(
      height: size.height * _imageHeightRatio,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.fastfood, size: 60, color: Colors.white),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _navigateToEditScreen(context),
      ),
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
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
          Provider.of<RecipeNotifier>(context, listen: false)
              .categories[_recipe.recipe_category_id! - 1],
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
        label: Text(categoryName),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        labelStyle: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
        shape: StadiumBorder(
          side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
        ));
  }

  Widget _buildIngredientsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.ingredientSelect,
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
              final currentIngredient =
                  Provider.of<RecipeNotifier>(context, listen: false)
                      .recipeIngredients[key];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IngredientCard(
                  onClicked: () {},
                  name: AppLocalizations.of(context)!
                      .ingredientTextList
                      .split(',')[key - 1],
                  quantity: quantity,
                  icon: currentIngredient.ingredient_icon,
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
    final updatedRecipe = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeEditFormScreen(
          initialRecipeName: _recipe.recipe_name,
          initialRecipeImage: _recipe.recipe_image_data,
          initialRecipeTypeId: _recipe.recipe_category_id,
          initialRecipe_provider_id: _recipe.recipe_owner_id,
          initialRecipe_category_id: _recipe.recipe_category_id,
          initialIdRecipe: _recipe.id_recipe,
          initialIdRecipeImage: _recipe.id_recipe_image,
          initialRecipeDescription: _recipe.recipe_category_desc,
          initialRecipeInstruction: _recipe.recipe_instruction,
          initialRecipePreparationTime: _recipe.recipe_preparation_time,
        ),
      ),
    );

    if (updatedRecipe != null) {
      setState(() => _recipe = updatedRecipe);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showConfirmationDialog(
      context,
      AppLocalizations.of(context)!.recipedeletionConfirmationMessage,
      () async {
        final statusCode =
            await Provider.of<RecipeNotifier>(context, listen: false)
                .deleteRecipe(_recipe.id_recipe!);

        final response = Response();

        if (statusCode == 200) {
          response.color = Colors.green;
          response.text = AppLocalizations.of(context)!.deleteSuccess;
          Navigator.pop(context);
        } else if (statusCode == 406 || statusCode == 422) {
          response.color = Colors.amber;
          response.text = AppLocalizations.of(context)!.deleteFailure;
        } else {
          response.color = Colors.red;
          response.text = AppLocalizations.of(context)!.serverError;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.text),
            backgroundColor: response.color,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
