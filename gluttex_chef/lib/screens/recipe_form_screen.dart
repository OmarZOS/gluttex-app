import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:gluttex_chef/components/category_picker.dart';
import 'package:gluttex_chef/components/ingredientCard.dart';
import 'package:gluttex_chef/components/ingredient_popup.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/ResponseHandler.dart';
import 'package:gluttex_core/app/Services/SnackbarService.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class RecipeFormScreen extends StatefulWidget {
  const RecipeFormScreen({super.key});

  @override
  _RecipeFormScreenState createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();

  late RecipeNotifier _recipeNotifier;
  Uint8List? _recipeImage;
  int? _recipeCategoryId;
  Duration _preparationTime = Duration.zero;
  final Map<int, String> _selectedIngredients = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _recipeNotifier = Provider.of<RecipeNotifier>(context, listen: false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final imageData = await pickedFile.readAsBytes();
        setState(() => _recipeImage = imageData);
      }
    } catch (e) {
      SnackbarService.showSnackbar(
          context: context,
          message: AppLocalizations.of(context)!.noImageSelectedTxt,
          backgroundColor: Colors.red);
    }
  }

  void _selectDuration(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: _preparationTime,
              onTimerDurationChanged: (Duration newDuration) {
                setState(() {
                  _preparationTime = newDuration;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.confirmTxt),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final recipe = Recipe(
        id_recipe: null,
        recipe_owner_id: Provider.of<AppUserNotifier>(context, listen: false)
                .appUser
                ?.id_app_user ??
            1,
        recipe_category_id: _recipeCategoryId ?? 0,
        id_recipe_image: null,
        recipe_name: _nameController.text,
        recipe_image_data: _recipeImage,
        recipe_image_url: null,
        recipe_description: _descriptionController.text,
        recipe_created_at: null,
        recipe_last_updated: null,
        recipe_instruction: _instructionsController.text,
        recipe_preparation_time: _preparationTime,
        recipe_category_desc: "",
        recipe_ingredients: _selectedIngredients,
      );

      await _recipeNotifier.addRecipe(recipe);

      ResponseHandler.handleResponse(
        context: context,
        statusCode: 200,
        responseCode: "PUT_SUCCESS",
        finalMessage: AppLocalizations.of(context)!.putSuccess,
      );

      // _handleResponse(statusCode, recipe);
    } on GluttexException catch (e) {
      ResponseHandler.handleResponse(
        context: context,
        statusCode: e.statusCode ?? 300,
        responseCode: e.message,
        finalMessage: e.message,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.insertRecipeText),
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImageSection(loc),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: loc.recipeNameText,
                validator: (value) => value?.isEmpty ?? true
                    ? loc.pleaseInputRecipeNameMsg
                    : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: loc.recipeDescriptionText,
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true)
                    return loc.pleaseInputRecipeDescriptionMsg;
                  if (value!.length >= 300)
                    return loc.descriptionCharacterConstraintMsg;
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _instructionsController,
                label: loc.recipeinstructiontext,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              CategoryPicker(
                category_id: 0,
                categories: _recipeNotifier.categories,
                onCategoryChanged: (id) => _recipeCategoryId = id,
              ),
              const SizedBox(height: 16),
              _buildDurationPicker(loc),
              const SizedBox(height: 16),
              _buildIngredientsSection(loc),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : Text(loc.submitText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildImageSection(AppLocalizations loc) {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _recipeImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _recipeImage!,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.grey.shade400),
                      Text(loc.noImageSelectedTxt),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: Text(loc.pickImageMsg),
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: _pickImage,
        ),
      ],
    );
  }

  Widget _buildDurationPicker(AppLocalizations loc) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(
          AppLocalizations.of(context)!.preparationTimeText(
              _preparationTime.inHours.toString(),
              _preparationTime.inMinutes.remainder(60).toString()),
        ),
        trailing: const Icon(Icons.timer),
        onTap: () => _selectDuration(context),
      ),
    );
  }

  Widget _buildIngredientsSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.ingredientSelect,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (_selectedIngredients.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedIngredients.length,
              itemBuilder: (context, index) {
                final key = _selectedIngredients.keys.elementAt(index);
                final quantity = _selectedIngredients[key]!;
                final ingredient = _recipeNotifier.recipeIngredients[key - 1];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IngredientCard(
                    onClicked: () =>
                        setState(() => _selectedIngredients.remove(key)),
                    name: loc.ingredientTextList
                        .split(",")[ingredient.id_ingredient - 1],
                    quantity: quantity,
                    icon: ingredient.ingredient_icon,
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: Text(loc.addIngredientMsg),
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => IngredientPopup(
              onIngredientSelected: (ingredient, quantity) {
                setState(() => _selectedIngredients[ingredient] = quantity);
              },
            ),
          ),
        ),
      ],
    );
  }
}
