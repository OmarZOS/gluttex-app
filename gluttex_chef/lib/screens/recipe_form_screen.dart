import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_chef/components/ingredientCard.dart';
import 'package:gluttex_chef/components/ingredient_popup.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_response_codes.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_event/recipe_change_notifier.dart';
import 'package:gluttex_chef/tools/duration.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:gluttex_ui/components/ImagePickerSection.dart';
import 'package:gluttex_ui/components/category_picker.dart';
import 'package:provider/provider.dart';

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key});

  @override
  _RecipeFormScreenState createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _recipeName;
  GluttexImage? _recipeImage;
  String? _recipeDescription;
  String? _recipeInstruction;
  Duration? _recipePreparationTime;
  late Duration preparationTime;
  int? _recipe_category_id;
  int? _recipe_owner_id;
  bool updatePage = false;
  int? _id_recipe;
  int? _id_recipe_image;
  String imageUrl = "";
  String? _initialRecipeImageUrl;
  late Map<int, String> _selectedIngredients;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    preparationTime = const Duration(minutes: 0);
    _selectedIngredients = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final Recipe? recipe = args?["recipe"];

      final currentUserId = Provider.of<AppUserNotifier>(context, listen: false)
          .appUser
          ?.id_app_user;

      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        Navigator.pop(context);
        return;
      }

      // Set owner ID - always use current user's ID for new recipes
      if (recipe?.id_recipe != null && recipe!.id_recipe != 0) {
        updatePage = true;
        _id_recipe = recipe.id_recipe; // ← This is set correctly for update
        _recipe_owner_id = recipe.recipe_owner_id ?? currentUserId;
        _recipeName = recipe.recipe_name;
        _recipeDescription = recipe.recipe_description;
        _initialRecipeImageUrl = recipe.recipe_image_url;
        _recipeInstruction = recipe.recipe_instruction;
        _recipe_category_id = recipe.recipe_category_id;
        _recipePreparationTime =
            recipe.recipe_preparation_time ?? const Duration(minutes: 0);
        _selectedIngredients = recipe.recipe_ingredients ?? {};
        _id_recipe_image = 0;
        preparationTime = _recipePreparationTime!;
      } else {
        // NEW RECIPE: Ensure _id_recipe is 0 (not null)
        updatePage = false;
        _id_recipe = 0; // ← FIX: Explicitly set to 0 for new recipes
        _recipe_owner_id = currentUserId;
        _recipePreparationTime = const Duration(minutes: 0);
        preparationTime = const Duration(minutes: 0);
        _selectedIngredients = {};
      }

      _initialized = true;
    }
  }

  void showTimePickerModal(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator.resolveFrom(context),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 40),
                    Text(
                      AppLocalizations.of(context)!.preparationTimeText(
                        preparationTime.inHours,
                        preparationTime.inMinutes % 60,
                      ),
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  initialTimerDuration: _recipePreparationTime!,
                  mode: CupertinoTimerPickerMode.hm,
                  backgroundColor:
                      CupertinoColors.systemBackground.resolveFrom(context),
                  onTimerDurationChanged: (Duration newDuration) {
                    setState(() {
                      preparationTime = newDuration;
                      _recipePreparationTime = newDuration;
                    });
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
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
        title: Text(updatePage
            ? AppLocalizations.of(context)!.updateRecipeMsg
            : AppLocalizations.of(context)!.insertRecipeText),
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
                  labelText: AppLocalizations.of(context)!.recipeNameText,
                ),
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
                      AppLocalizations.of(context)!.recipeDescriptionText,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .pleaseInputRecipeDescriptionMsg;
                  }
                  if (value.length >= 300) {
                    return AppLocalizations.of(context)!
                        .descriptionCharacterConstraintMsg;
                  }
                  return null;
                },
                onSaved: (value) => _recipeDescription = value,
              ),
              TextFormField(
                initialValue: _recipeInstruction ?? "",
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.recipeinstructiontext,
                ),
                onSaved: (value) => _recipeInstruction = value,
              ),
              const SizedBox(height: 16.0),
              CategoryPicker(
                category_id: _recipe_category_id ?? 1,
                categories: Provider.of<RecipeNotifier>(context).categories,
                onCategoryChanged: (selectedCategoryId) {
                  _onCategoryChanged(selectedCategoryId);
                },
                pathFunction: (int id) => 'assets/icons/${id}.svg',
                package: "gluttex_chef",
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        key: ValueKey(preparationTime),
                        AppLocalizations.of(context)!.preparationTimeText(
                          preparationTime.inHours.toString(),
                          preparationTime.inMinutes.remainder(60).toString(),
                        ),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                      ),
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.timer_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  showTimePickerModal(context);
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: [
                  if (_selectedIngredients.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedIngredients.length,
                        itemBuilder: (context, index) {
                          int key = _selectedIngredients.keys.elementAt(index);
                          String quantity = _selectedIngredients[key]!;
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
                    ),
                  if (_selectedIngredients.isNotEmpty)
                    const SizedBox(height: 16.0),
                  ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.addIngredientMsg,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return IngredientPopup(
                            onIngredientSelected: (ingredient, quantity) {
                              setState(() {
                                _selectedIngredients[ingredient] = quantity;
                              });
                            },
                          );
                        },
                      );
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.2),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              if (_id_recipe != null && _id_recipe != 0)
                ImagePickerSection(
                  initialImageUrl:
                      _initialRecipeImageUrl, // Now String? - can be null
                  entityType: 'recipe',
                  ownerId: '$_recipe_owner_id',
                  entityId: '$_id_recipe',
                  landscape: true,
                  onImageUploaded: (newImage) {
                    setState(() {
                      _recipeImage = newImage;
                      _id_recipe_image = 0;
                    });
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    print('Recipe owner ID: $_recipe_owner_id');
                    print('Recipe ID: $_id_recipe');

                    // Create the recipe object WITHOUT wrapping
                    Recipe recipe = Recipe(
                      id_recipe: _id_recipe ?? 0,
                      recipe_owner_id: _recipe_owner_id ?? 0,
                      recipe_category_id: _recipe_category_id,
                      id_recipe_image: _id_recipe_image ?? 0,
                      recipe_name: _recipeName,
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
                      // Handle image
                      if (_recipeImage != null) {
                        recipe.recipeImage = _recipeImage!;
                      } else if (recipe.id_recipe == 0) {
                        // Only upload image for new recipes
                        final imageUrlResult = await Navigator.pushNamed(
                          context,
                          AppRoutes.imageUpload,
                          arguments: {
                            "entity": "recipe",
                            "id": recipe.id_recipe ?? 0,
                          },
                        ) as String?;
                        if (imageUrlResult != null) {
                          recipe.recipe_image_url = imageUrlResult;
                        }
                      }

                      // Send ONLY the recipe object, NOT wrapped
                      final insertedRecipe = await Provider.of<RecipeNotifier>(
                        context,
                        listen: false,
                      ).addOrUpdateRecipe(recipe); // This sends recipe.toJson()

                      ResponseHandler.handleResponse(
                        context: context,
                        statusCode: 200,
                        responseCode: GluttexResponseCodes.put_success,
                        finalMessage: AppLocalizations.of(context)!.putSuccess,
                      );

                      Navigator.popUntil(
                        context,
                        (route) => route.settings.name == AppRoutes.home,
                      );
                    } on GluttexException catch (e) {
                      ResponseHandler.handleResponse(
                        context: context,
                        statusCode: e.statusCode ?? 300,
                        responseCode: e.message,
                        finalMessage: AppLocalizations.of(context)!.putFailure,
                      );
                    }
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
