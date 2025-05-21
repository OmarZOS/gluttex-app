import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_chef/screens/recipe_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:provider/provider.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final double aspectRatio;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.aspectRatio = 1.5, // Default aspect ratio (width:height)
  });

  static String getRecipePreparationTime(
      BuildContext context, Duration? preparationTime) {
    if (preparationTime != null) {
      return AppLocalizations.of(context)!.preparationTimeText(
          preparationTime.inHours.toInt(),
          preparationTime.inMinutes.toInt() % 60);
    }
    return AppLocalizations.of(context)!.noPreparationTimeText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryId = recipe.recipe_category_id ?? 0;
    final categoryName = AppLocalizations.of(context)!
        .recipeCategoryTextList
        .split(",")[(recipe.recipe_category_id ?? 1) - 1];

    return Card(
      // color: GluttexConstants().getCardColor(
      //     categoryId - 1, Theme.of(context).brightness == Brightness.dark),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetails(context),
        splashColor: colorScheme.primary.withOpacity(0.1),
        highlightColor: colorScheme.primary.withOpacity(0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            AspectRatio(
              aspectRatio: aspectRatio,
              child: _buildRecipeImage(context, categoryId),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // Important for proper sizing
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          // color: colorScheme.primary,
                          child: SvgPicture.asset(
                            'assets/icons/${recipe.recipe_category_id}.svg',
                            package: "gluttex_chef",
                            color: Theme.of(context).colorScheme.primary,
                          ), // Replace with desired icon
                        ),

                        const SizedBox(
                            width: 4), // Add spacing between icon and text
                        Text(
                          categoryName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Recipe Name
                  Text(
                    recipe.recipe_name ?? '',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Preparation Time
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        getRecipePreparationTime(
                            context, recipe.recipe_preparation_time),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage(BuildContext context, int categoryId) {
    return SizedBox.expand(
      // Forces full parent space
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: recipe.recipe_image_url != null
            ? Container(
                constraints:
                    const BoxConstraints.expand(), // Expands within parent
                child: Hero(
                    tag: 'recipe-image-${recipe.id_recipe}',
                    child: Image.network(
                      GluttexConstants.fsBaseUrl + recipe.recipe_image_url!,
                      fit: BoxFit.cover, // Covers all available space
                      alignment: Alignment.center, // Centers the image
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
                        return SizedBox.expand(
                          // Fallback also fills space
                          child: _buildFallbackImage(context, categoryId),
                        );
                      },
                      key: ValueKey(recipe.id_recipe_image),
                    )),
              )
            : SizedBox.expand(
                // Placeholder fills space
                child: _buildPlaceholder(context),
              ),
      ),
    );
  }

  Widget _buildFallbackImage(BuildContext context, int categoryId) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/$categoryId.svg',
          package: "medicom_catalog",
          width: 40,
          height: 40,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Center(
        child: Icon(
          Icons.fastfood_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DetailsScreen(recipe: recipe),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return FadeTransition(
            opacity: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
