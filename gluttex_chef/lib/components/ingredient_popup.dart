import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:provider/provider.dart';

class IngredientPopup extends StatefulWidget {
  final Function(int ingredient_id, String quantity) onIngredientSelected;

  const IngredientPopup({super.key, required this.onIngredientSelected});

  @override
  _IngredientPopupState createState() => _IngredientPopupState();
}

class _IngredientPopupState extends State<IngredientPopup> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<RecipeIngredient> _filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    // Initial ingredients list - replace with actual data source
    _filteredIngredients =
        Provider.of<RecipeNotifier>(context, listen: false).recipeIngredients;
  }

  void _filterIngredients(String query) {
    // Filter the ingredient list based on the search query
    setState(() {
      _filteredIngredients = _filteredIngredients
          .where((ingredient) => ingredient.ingredient_name
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.ingredientSelect),
      content: SizedBox(
          width: MediaQuery.of(context).size.height *
              0.7, // Set your desired width
          height: MediaQuery.of(context).size.height *
              0.7, // Set your desired height
          child: SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: _filterIngredients,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.ingredientSearch,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                    itemCount: _filteredIngredients.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title:
                            Text(_filteredIngredients[index].ingredient_name),
                        onTap: () {
                          // Handle ingredient selection and show quantity input
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(AppLocalizations.of(context)!
                                    .ingredientQuantity),
                                content: TextField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!
                                        .ingredientQuantity,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      widget.onIngredientSelected(
                                        _filteredIngredients[index]
                                            .id_ingredient,
                                        _quantityController.text,
                                      );
                                      // Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.addText),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.cancelTxt),
        ),
      ],
    );
  }
}
