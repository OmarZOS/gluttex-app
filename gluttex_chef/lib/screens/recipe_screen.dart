import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_chef/components/RecipeCard.dart';
import 'package:gluttex_chef/components/RecipeOwner.dart';
import 'package:gluttex_chef/components/ingredientCard.dart';
import 'package:gluttex_chef/screens/recipe_update_form_screen.dart';
import 'package:gluttex_chef/tools/confirmation_dialogue.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/app/ResponseHandler.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
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

  late RecipeNotifier notifier;

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
    notifier = Provider.of<RecipeNotifier>(context, listen: false);
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
      floatingActionButton:
          Provider.of<AppUserNotifier>(context, listen: false).isCookingChef
              ? FloatingActionButton(
                  onPressed: () => _navigateToEditScreen(context),
                  child: const Icon(Icons.edit),
                )
              : null,
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
              FutureBuilder<Widget>(
                future: _buildProviderTile(context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading provider tile');
                  } else {
                    return snapshot.data!;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeImage(Size size) {
    return _recipe.recipe_image_url != null &&
            _recipe.recipe_image_url!.isNotEmpty
        ? Hero(
            tag: 'recipe-image-${_recipe.id_recipe}',
            child: Image.network(
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
            ))
        : _buildImagePlaceholder(size);
  }

  Widget _buildImagePlaceholder(Size size) {
    return Container(
      height: size.height * _imageHeightRatio,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: (Theme.of(context).brightness == Brightness.dark)
              ? [
                  const Color.fromARGB(255, 100, 110, 105),
                  const Color(0xFF186A3B),
                ]
              : [
                  const Color(0xFF2ECC71),
                  const Color.fromARGB(255, 143, 197, 166),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/${_recipe.recipe_category_id}.svg',
          package: "gluttex_chef",
          color: Theme.of(context).colorScheme.primary,
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.width * 0.2,
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      // IconButton(
      //   icon: const Icon(Icons.edit),
      //   onPressed: () => _navigateToEditScreen(context),
      // ),
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
          notifier.categories[_recipe.recipe_category_id! - 1],
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
        avatar:
            // Add icon here
            SvgPicture.asset(
          'assets/icons/${_recipe.recipe_category_id}.svg',
          package: "gluttex_chef",
          color: Theme.of(context).colorScheme.secondary,
        ), // Replace with your desired icon
        // size: 18,
        // color: theme.colorScheme.primary,
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
          AppLocalizations.of(context)!.ingredientText,
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
              final currentIngredient = notifier.recipeIngredients[key - 1];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: IngredientCard(
                  onClicked: () {},
                  name: AppLocalizations.of(context)!
                      .ingredientTextList
                      .split(',')[key - 1],
                  quantity: quantity,
                  id: currentIngredient.id_ingredient,
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
          // initialRecipeImage: _recipe.recipe_image_data,
          initialRecipeTypeId: _recipe.recipe_category_id,
          initialRecipe_provider_id: _recipe.recipe_owner_id,
          initialRecipe_category_id: _recipe.recipe_category_id,
          initialIdRecipe: _recipe.id_recipe,
          initialRecipeImageUrl: _recipe.recipe_image_url,
          initialIdRecipeImage: _recipe.id_recipe_image,
          initialRecipeDescription: _recipe.recipe_category_desc,
          initialRecipeInstruction: _recipe.recipe_instruction,
          initialRecipePreparationTime: _recipe.recipe_preparation_time,
          initialIngredients: _recipe.recipe_ingredients,
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
        try {
          await notifier.deleteRecipe(_recipe.id_recipe!);
          ResponseHandler.handleResponse(
            context: context,
            statusCode: 200,
            responseCode: "SUCCESS",
            finalMessage: AppLocalizations.of(context)!.deleteSuccess,
          );
          Navigator.pop(context);
        } on GluttexException catch (e) {
          ResponseHandler.handleResponse(
            context: context,
            statusCode: e.statusCode ?? 300,
            responseCode: e.message,
            finalMessage: AppLocalizations.of(context)!.deleteFailure,
          );
        }
      },
    );
  }

  Future<Widget> _buildProviderTile(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final AppUser? provider =
        await notifier.getUserById(_recipe.recipe_owner_id ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: GluttexConstants.kDefaultPaddin / 8,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.providedBy,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Provider Avatar/Logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: provider != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 48,
                            color: Colors.lightGreen,
                          ),
                        )
                      : _buildDefaultProviderIcon(),
                ),
                const SizedBox(width: 12),

                // Provider Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${provider?.personFirstName} ${provider?.personLastName}" ??
                            AppLocalizations.of(context)!.unknownProvider,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (provider?.locationName != "") ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider!.locationName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Contact Button
                // IconButton(
                //   icon: Icon(
                //     Icons.contact_support_outlined,
                //     color: colorScheme.primary,
                //   ),
                //   onPressed: () => _showContactOptions(context, provider),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultProviderIcon() {
    return Center(
      child: Icon(
        Icons.store_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showContactOptions(BuildContext context, AppUser? provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.phone),
                title: Text(AppLocalizations.of(context)!.callProvider),
                onTap: () {
                  Navigator.pop(context);
                  // if (provider?.phone != null) {
                  //   // Implement phone call functionality
                  // }
                },
              ),
              ListTile(
                leading: const Icon(Icons.email),
                // title: Text("AppLocalizations.of(context)!.emailProvider"),
                onTap: () {
                  Navigator.pop(context);
                  // if (provider?.email != null) {
                  //   // Implement email functionality
                  // }
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: Text(AppLocalizations.of(context)!.viewOnMap),
                onTap: () {
                  Navigator.pop(context);
                  // if (provider?.location != null) {
                  //   // Implement map view functionality
                  // }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
