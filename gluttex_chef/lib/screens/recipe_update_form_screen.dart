import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_chef/components/ImagePickerSection.dart';
import 'package:gluttex_chef/components/category_picker.dart';
import 'package:gluttex_chef/components/ingredientCard.dart';
import 'package:gluttex_chef/components/ingredient_popup.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/app/ResponseHandler.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:gluttex_chef/tools/duration.dart';
import 'package:gluttex_chef/tools/image_picker.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/services/RecipeService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locator/locator.dart';
import 'package:provider/provider.dart';

class RecipeEditFormScreen extends StatefulWidget {
  final String? initialRecipeName;
  final String? initialRecipeBrand;
  final String? initialRecipeBarcode;
  // final Uint8List? initialRecipeImage;
  final String? initialRecipeImageUrl;
  final int? initialRecipeTypeId;
  final double? initialRecipePrice;
  final int? initialRecipeQuantity;

  final int? initialRecipe_provider_id;
  final int? initialRecipe_category_id;
  final int? initialIdRecipe;
  final int? initialIdRecipeImage;
  final String? initialRecipeDescription;
  final String? initialRecipeInstruction;
  final Duration? initialRecipePreparationTime;
  final Map<int, String>? initialIngredients;

  const RecipeEditFormScreen(
      {super.key,
      this.initialRecipeName,
      this.initialRecipeBrand,
      this.initialRecipeBarcode,
      // this.initialRecipeImage,
      this.initialRecipeImageUrl,
      this.initialRecipeTypeId,
      this.initialRecipePrice,
      this.initialRecipeQuantity,
      this.initialRecipe_provider_id,
      this.initialRecipe_category_id,
      this.initialIdRecipe,
      this.initialIdRecipeImage,
      this.initialRecipeDescription,
      this.initialRecipeInstruction,
      this.initialRecipePreparationTime,
      this.initialIngredients});

  @override
  _RecipeEditFormScreenState createState() => _RecipeEditFormScreenState();
}

class _RecipeEditFormScreenState extends State<RecipeEditFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _recipeName;
  GluttexImage? _recipeImage;
  int? _recipe_category_id;
  int? _recipe_owner_id;
  int? _id_recipe;
  int? _id_recipe_image;
  String? _recipeDescription;
  String? _recipeInstruction;
  Duration? _recipePreparationTime;
  late Duration preparationTime;
  DateTime? recipe_created_at;
  DateTime? recipe_last_updated;
  String imageUrl = "";
  String _initialRecipeImageUrl = "";
  late Map<int, String> _selectedIngredients;

  @override
  void initState() {
    super.initState();
    // Initialize state variables with initial values from the widget
    _recipeName = widget.initialRecipeName;
    // _recipeImage = widget.initialRecipeImage;
    _recipeDescription = widget.initialRecipeDescription;
    _initialRecipeImageUrl = widget.initialRecipeImageUrl ?? "";
    _recipeInstruction = widget.initialRecipeInstruction;
    _recipe_category_id = widget.initialRecipe_category_id;
    _id_recipe = widget.initialIdRecipe;
    _id_recipe_image = 0;
    _recipePreparationTime = widget.initialRecipePreparationTime;
    _recipe_owner_id = widget.initialRecipe_provider_id ?? 1;
    preparationTime = _recipePreparationTime!;
    _selectedIngredients = widget.initialIngredients ?? {};
  }

  void _selectDuration(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          // color: Colors.white,
          child: CupertinoTimerPicker(
            initialTimerDuration: _recipePreparationTime!,
            mode: CupertinoTimerPickerMode.hm,
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                preparationTime = newDuration;
                _recipePreparationTime = newDuration;
              });
            },
          ),
        );
      },
    );
  }

  void _onCategoryChanged(int identifier) {
    _recipe_category_id = identifier;
  }

  @override
  Widget build(BuildContext context) {
    final ingredientNames =
        AppLocalizations.of(context)!.ingredientTextList.split(',');
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.updateRecipeMsg),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _recipeName,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.recipeNameText),
                onSaved: (value) => _recipeName = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputRecipeNameMsg;
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _recipeDescription ?? "",
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.recipeDescriptionText),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputRecipeDescriptionMsg;
                  }

                  if ((value).length >= 300) {
                    return AppLocalizations.of(context)!
                        .descriptionCharacterConstraintMsg;
                  }
                  return null;
                },
                onSaved: (value) => _recipeDescription = value,
              ),
              TextFormField(
                initialValue: _recipeInstruction ?? "",
                maxLines: null, // Allow for multiline input
                keyboardType:
                    TextInputType.multiline, // Show multiline keyboard
                decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.recipeinstructiontext),
                // keyboardType: TextInputType.number,
                // validator: (value) {
                //   return null;
                // },
                onSaved: (value) => _recipeInstruction = value,
              ),
              const SizedBox(height: 16.0),
              CategoryPicker(
                category_id: _recipe_category_id ?? 1,
                categories: Provider.of<RecipeNotifier>(context).categories,
                onCategoryChanged: (selectedCategoryId) {
                  _onCategoryChanged(selectedCategoryId);
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.preparationTimeText(
                      preparationTime.inHours.toString(),
                      preparationTime.inMinutes.remainder(60).toString()),
                ),
                trailing: const Icon(Icons.timer),
                onTap: () => _selectDuration(context),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: [
                  // Other form fields...
                  (_selectedIngredients.isNotEmpty)
                      ? SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedIngredients.length,
                            itemBuilder: (context, index) {
                              // Extract the key and corresponding value
                              int key =
                                  _selectedIngredients.keys.elementAt(index);
                              String quantity = _selectedIngredients[key]!;

                              // Return the IngredientCard with the correct data
                              return IngredientCard(
                                onClicked: () {
                                  setState(() {
                                    _selectedIngredients.remove(key);
                                  });
                                },
                                name: ingredientNames[key - 1],
                                quantity: quantity,
                                id: key,
                              );
                            },
                          ),
                        )
                      : Container(),

                  const SizedBox(height: 16.0),
                  ListTile(
                    title: Text(AppLocalizations.of(context)!.addIngredientMsg),
                    trailing: const Icon(Icons.add),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // AlertDialog(title: Text('Select Ingredient'));
                          return IngredientPopup(
                              onIngredientSelected: (ingredient, quantity) {
                            // Handle adding the selected ingredient and quantity to the form
                            setState(() {
                              _selectedIngredients[ingredient] = quantity;
                            });
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ImagePickerSection(
                initialImageUrl: _initialRecipeImageUrl,
                entityType: 'recipe',
                ownerId: '$_recipe_owner_id',
                entityId: '$_id_recipe',
                onImageUploaded: (newImage) {
                  setState(() {
                    _recipeImage = newImage;
                    _id_recipe_image = 0; // Reset image ID to 0 for new uploads
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final recipe = Recipe(
                      id_recipe: _id_recipe,
                      recipe_owner_id: _recipe_owner_id,
                      recipe_category_id: _recipe_category_id,
                      id_recipe_image: _id_recipe_image,
                      recipe_name: _recipeName,
                      // recipeImage: _recipeImage,
                      recipe_image_url: imageUrl,
                      recipe_description: _recipeDescription,
                      recipe_created_at: null,
                      recipe_last_updated: null,
                      recipe_instruction: _recipeInstruction,
                      recipe_preparation_time: preparationTime,
                      recipe_category_desc: "",
                      recipe_ingredients: _selectedIngredients,
                    );
                    try {
                      if (_recipeImage != null)
                        // ignore: curly_braces_in_flow_control_structures
                        recipe.recipeImage = _recipeImage!;
                      final statusCode = await Provider.of<RecipeNotifier>(
                              context,
                              listen: false)
                          .addOrUpdateRecipe(recipe);

                      ResponseHandler.handleResponse(
                        context: context,
                        statusCode: 200,
                        responseCode: "PUT_SUCCESS",
                        finalMessage: AppLocalizations.of(context)!.putSuccess,
                      );
                      Navigator.pop(context);
                      await Provider.of<RecipeNotifier>(context, listen: false)
                          .fetchRecipes(0);
                    } on GluttexException catch (e) {
                      // Handle recipe submission

                      ResponseHandler.handleResponse(
                        context: context,
                        statusCode: e.statusCode ?? 300,
                        responseCode: e.message,
                        finalMessage: AppLocalizations.of(context)!.putFailure,
                      );
                    }

                    // You can use a provider or any state management to save the recipe
                  }
                },
                child: Text(AppLocalizations.of(context)!.submitText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
