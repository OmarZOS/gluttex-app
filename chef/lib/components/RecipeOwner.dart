import 'package:flutter/material.dart';
import 'package:chef/screens/recipe_screen.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:event/user_change_notifier.dart';
import 'package:event/recipe_change_notifier.dart';
import 'package:provider/provider.dart';

bool is_recipe_owner(BuildContext context, int ownerId) {
  AppUser appUser =
      Provider.of<AppUserNotifier>(context, listen: false).appUser!;

  return appUser.id_app_user == ownerId || appUser.isAdmin;
}

class RecipeOwner extends StatelessWidget {
  final Recipe recipe;

  const RecipeOwner({super.key, required this.recipe});

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
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.recipeCreate,
        arguments: {"recipe": recipe},
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
                    child: Image.network(
                      recipe.recipe_image_url!,
                      fit: BoxFit.fill, // Fit the image within the space
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
                      // style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      recipe.recipe_name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.recipe_preparation_time}',
                      // style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
