import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:provider/provider.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  static String getRecipePreparationTime(
      BuildContext context, Duration? preparationTime) {
    if (preparationTime != null)
      // ignore: curly_braces_in_flow_control_structures
      return AppLocalizations.of(context)!.preparationTimeText(
          preparationTime.inHours.toInt(),
          preparationTime.inMinutes.toInt() % 60);
    return AppLocalizations.of(context)!.noPreparationTimeText;
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = MediaQuery.of(context).size.height / 4;

    // if (recipe.id_recipe_image != null &&
    //     recipe.id_recipe_image != 0 &&
    //     recipe.recipe_image_data == null) {
    //   Provider.of<RecipeNotifier>(context, listen: false)
    //       .getRecipeImage(recipe);
    // }
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            recipe: recipe,
          ),
        ),
      ),
      child: Card(
        child: SizedBox(
          height: cardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                    width: double
                        .infinity, // Make the container take up the full width
                    child: recipe.recipe_image_url != null
                        ? Image.network(
                            GluttexConstants.fsBaseUrl +
                                recipe.recipe_image_url!,
                            fit: BoxFit.fill, // Fit the image within the space
                          )
                        : Container(
                            // color: Colors.grey[200],
                            child: const Placeholder(),
                          )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!
                          .recipeCategoryTextList
                          .split(",")[(recipe.recipe_category_id ?? 1) - 1],
                    ),
                    Text(
                      recipe.recipe_name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(getRecipePreparationTime(
                        context, recipe.recipe_preparation_time)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
