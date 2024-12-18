import 'package:flutter/material.dart';
import 'package:gluttex_chef/components/RecipeOwner.dart';
import 'package:gluttex_chef/components/ingredientCard.dart';
import 'package:gluttex_chef/screens/recipe_update_form_screen.dart';
import 'package:gluttex_chef/tools/confirmation_dialogue.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:provider/provider.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Recipe _recipe;

  // final List<Map<String, String>> ingredients = [
  //   {
  //     "imageUrl": "https://via.placeholder.com/100",
  //     "name": "Flour",
  //     "quantity": "2 cups"
  //   },
  //   {
  //     "imageUrl": "https://via.placeholder.com/100",
  //     "name": "Sugar",
  //     "quantity": "1 cup"
  //   },
  //   {
  //     "imageUrl": "https://via.placeholder.com/100",
  //     "name": "Eggs",
  //     "quantity": "3"
  //   },
  //   {
  //     "imageUrl": "https://via.placeholder.com/100",
  //     "name": "Eggs",
  //     "quantity": "3"
  //   },
  //   {
  //     "imageUrl": "https://via.placeholder.com/100",
  //     "name": "Eggs",
  //     "quantity": "3"
  //   },
  //   {
  //     "imageUrl": "https://via.placeholder.com/100",
  //     "name": "Eggs",
  //     "quantity": "3"
  //   },
  //   {
  //     "imageUrl": "https://via.placeholder.com/100",
  //     "name": "Eggs",
  //     "quantity": "3"
  //   },
  //   {
  //     "imageUrl": "https://via.placeholder.com/100",
  //     "name": "Eggs",
  //     "quantity": "3"
  //   },
  //   {
  //     "imageUrl": "https://via.placeholder.com/100",
  //     "name": "Eggs",
  //     "quantity": "3"
  //   },
  //   // Add more ingredients as needed
  // ];

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          is_recipe_owner(context, _recipe.recipe_owner_id ?? 0)
              ? IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    showConfirmationDialog(
                      context,
                      'Are you sure you want to delete this recipe?',
                      () async {
                        int? statusCode = await Provider.of<RecipeNotifier>(
                                context,
                                listen: false)
                            .deleteRecipe('${_recipe.id_recipe}');

                        Response response = Response();

                        switch (statusCode) {
                          case 200:
                            response.color = Colors.green;
                            response.text = GluttexConstants.deleteSuccess;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response.text),
                                backgroundColor: response.color,
                              ),
                            );
                            Navigator.pop(context);
                            break;
                          case 406:
                            response.color = Colors.amberAccent;
                            response.text = GluttexConstants.deleteFailure;
                            break;
                          case 422:
                            response.color = Colors.amberAccent;
                            response.text = GluttexConstants.deleteFailure;
                            break;

                          default:
                            response.color = Colors.red;
                            response.text = GluttexConstants.serverError;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.text),
                            backgroundColor: response.color,
                          ),
                        );
                      },
                    );
                  },
                )
              : Container(),
          is_recipe_owner(context, _recipe.recipe_owner_id ?? 0)
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
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
                          initialRecipeDescription: _recipe.recipe_description,
                          initialRecipeInstruction: _recipe.recipe_instruction,
                          initialRecipePreparationTime:
                              _recipe.recipe_preparation_time,
                        ),
                      ),
                    );

                    if (updatedRecipe != null) {
                      setState(() {
                        _recipe = updatedRecipe;
                      });
                    }
                  },
                )
              : Container(),
          const SizedBox(width: GluttexConstants.kDefaultPaddin / 2)
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: _recipe.recipe_image_data != null &&
                        _recipe.recipe_image_data!.isNotEmpty
                    ? Image.memory(
                        _recipe.recipe_image_data!,
                        height: size.height / 3,
                        fit: BoxFit.cover,
                      )
                    : SizedBox(
                        height: size.height / 3,
                        child: const Placeholder(),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                _recipe.recipe_name ?? 'Recipe Name',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _recipe.recipe_description ?? 'No description available.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.timer),
                  const SizedBox(width: 8),
                  Text(
                    _recipe.recipe_preparation_time ?? 'No preparation time',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () {},
                  child: Text('${_recipe.recipe_category_desc}')),
              const SizedBox(height: 16),
              (_recipe.recipe_ingredients!.isNotEmpty)
                  ? SizedBox(
                      height: 120, // Set a fixed height for the ListView
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _recipe.recipe_ingredients!.length,
                        itemBuilder: (context, index) {
                          // Extract the key and corresponding value
                          int key =
                              _recipe.recipe_ingredients!.keys.elementAt(index);
                          String quantity = _recipe.recipe_ingredients![key]!;

                          // Return the IngredientCard with the correct data
                          return IngredientCard(
                            onClicked: () {},
                            name: Provider.of<RecipeNotifier>(context,
                                    listen: false)
                                .getIngredientById(key)!
                                .ingredient_name,
                            quantity: quantity,
                            icon: Provider.of<RecipeNotifier>(context,
                                    listen: false)
                                .getIngredientById(key)!
                                .ingredient_icon,
                          );
                        },
                      ),
                    )
                  : Container(),
              Text(
                'Instructions',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _recipe.recipe_instruction ?? 'No instructions available.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
