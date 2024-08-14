import 'package:flutter/material.dart';
import 'package:gluttex_chef/screens/recipe_screen.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:provider/provider.dart';

bool is_recipe_owner(BuildContext context, int ownerId) {
  return true;
  return Provider.of<AppUserNotifier>(context, listen: false)
          .appUser!
          .id_app_user ==
      ownerId;
}

class RecipeOwner extends StatelessWidget {
  final Recipe recipe;

  const RecipeOwner({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cardHeight = MediaQuery.of(context).size.height / 4;

    if (recipe.id_recipe_image != null &&
        recipe.id_recipe_image != 0 &&
        recipe.recipe_image_data == null) {
      Provider.of<RecipeNotifier>(context, listen: false)
          .getRecipeImage(recipe);
    }
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
        child: Container(
          height: cardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                    width: double
                        .infinity, // Make the container take up the full width
                    child: recipe.recipe_image_data != null &&
                            recipe.recipe_image_data!.isNotEmpty
                        ? Image.memory(
                            recipe.recipe_image_data!,
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
                      '${recipe.recipe_category_desc}',
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

Widget _buildRecipeGrid(List<Recipe> recipes) {
  if (recipes.isEmpty) {
    return const Center(child: Text(GluttexConstants.noRecipesFound));
  }

  return GridView.builder(
    itemCount: recipes.length,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      mainAxisSpacing: GluttexConstants.kDefaultPaddin,
      crossAxisSpacing: GluttexConstants.kDefaultPaddin,
      childAspectRatio: 0.5, // Adjust childAspectRatio to fit your layout needs
    ),
    itemBuilder: (context, index) => RecipeOwner(
      recipe: recipes[index],
    ),
  );
}
