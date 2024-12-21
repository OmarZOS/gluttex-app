import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_chef/components/category_picker.dart';
import 'package:gluttex_chef/components/ingredientCard.dart';
import 'package:gluttex_chef/components/ingredient_popup.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
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
  final Uint8List? initialRecipeImage;
  final int? initialRecipeTypeId;
  final double? initialRecipePrice;
  final int? initialRecipeQuantity;

  final int? initialRecipe_provider_id;
  final int? initialRecipe_category_id;
  final int? initialIdRecipe;
  final int? initialIdRecipeImage;
  final String? initialRecipeDescription;
  final String? initialRecipeInstruction;
  final String? initialRecipePreparationTime;
  final Map<int, String>? initialIngredients;

  const RecipeEditFormScreen(
      {super.key,
      this.initialRecipeName,
      this.initialRecipeBrand,
      this.initialRecipeBarcode,
      this.initialRecipeImage,
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
  Uint8List? _recipeImage;
  int? _recipe_category_id;
  int? _recipe_owner_id;
  int? _id_recipe;
  int? _id_recipe_image;
  String? _recipeDescription;
  String? _recipeInstruction;
  String? _recipePreparationTime;
  late Duration preparationTime;
  DateTime? recipe_created_at;
  DateTime? recipe_last_updated;
  late Map<int, String> _selectedIngredients;

  @override
  void initState() {
    super.initState();
    // Initialize state variables with initial values from the widget
    _recipeName = widget.initialRecipeName;
    _recipeImage = widget.initialRecipeImage;

    _recipeDescription = widget.initialRecipeDescription;

    _recipeInstruction = widget.initialRecipeInstruction;
    _recipe_category_id = widget.initialRecipe_category_id;
    _id_recipe = widget.initialIdRecipe;
    _id_recipe_image = widget.initialIdRecipeImage;
    _recipePreparationTime = widget.initialRecipePreparationTime;
    _selectedIngredients = widget.initialIngredients ?? {};
    preparationTime = ParseDurationString(_recipePreparationTime ?? "");
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageData = await pickedFile.readAsBytes();
      Uint8List resizedImage = resizeImage(
          imageData,
          MediaQuery.of(context).size.width.floor(),
          MediaQuery.of(context).size.width.floor());
      setState(() {
        _recipeImage = resizedImage;
      });
    }
  }

  void _selectDuration(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          // color: Colors.white,
          child: CupertinoTimerPicker(
            initialTimerDuration:
                ParseDurationString(_recipePreparationTime ?? ""),
            mode: CupertinoTimerPickerMode.hm,
            onTimerDurationChanged: (Duration newDuration) {
              setState(() {
                preparationTime = newDuration;
                _recipePreparationTime = ((newDuration.inHours != 0)
                        ? AppLocalizations.of(context)!
                            .hoursTextValue(newDuration.inHours.toString())
                        : '') +
                    ((newDuration.inMinutes.remainder(60) != 0)
                        ? AppLocalizations.of(context)!.minutesTextValue(
                            newDuration.inMinutes.remainder(60).toString())
                        : '.');
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
              FutureBuilder<List<RecipeCategory>?>(
                future: GluttexLocator.get<RecipeService>().getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(); // Show a loading indicator while waiting
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text(
                        AppLocalizations.of(context)!.categoriesNotFoundTxt);
                  } else {
                    return CategoryPicker(
                      category_id: _recipe_category_id ?? 1,
                      categories: snapshot.data!,
                      onCategoryChanged: (selectedCategoryId) {
                        _onCategoryChanged(selectedCategoryId);
                      },
                    );
                  }
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
              _recipeImage != null
                  ? Image.memory(_recipeImage!,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width)
                  : Text(AppLocalizations.of(context)!.noImageSelectedTxt),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(AppLocalizations.of(context)!.pickImageMsg),
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
                      recipe_image_data: _recipeImage,
                      recipe_description: _recipeDescription,
                      recipe_created_at: null,
                      recipe_last_updated: null,
                      recipe_instruction: _recipeInstruction,
                      recipe_preparation_time: _recipePreparationTime,
                      recipe_category_desc: "",
                      recipe_ingredients: {},
                    );

                    // Handle recipe submission
                    int? statusCode = await GluttexLocator.get<RecipeService>()
                        .updateRecipe(recipe);

                    Response response = Response();

                    switch (statusCode) {
                      case 200:
                        response.color = Colors.green;
                        response.text =
                            AppLocalizations.of(context)!.putSuccess;
                        await Provider.of<RecipeNotifier>(context,
                                listen: false)
                            .fetchRecipes();
                        Navigator.pop(context, recipe);
                        break;
                      case 406:
                        response.color = Colors.amberAccent;
                        response.text =
                            'Error $statusCode: ${AppLocalizations.of(context)!.putFailure}';
                        break;
                      case 422:
                        response.color = Colors.amberAccent;
                        response.text =
                            'Error $statusCode: ${AppLocalizations.of(context)!.putFailure}';
                        break;

                      default:
                        response.color = Colors.red;
                        response.text =
                            'Error $statusCode: ${AppLocalizations.of(context)!.serverError}';
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response.text),
                        backgroundColor: response.color,
                      ),
                    );

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
