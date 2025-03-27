import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:provider/provider.dart';

class IngredientPopup extends StatefulWidget {
  final Function(int ingredientId, String quantity) onIngredientSelected;

  const IngredientPopup({super.key, required this.onIngredientSelected});

  @override
  _IngredientPopupState createState() => _IngredientPopupState();
}

class _IngredientPopupState extends State<IngredientPopup> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<RecipeIngredient> _filteredIngredients = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _loadIngredients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    setState(() => _isLoading = true);

    _filterIngredients('');
    setState(() => _isLoading = false);
  }

  void _filterIngredients(String query) {
    final ingredients =
        Provider.of<RecipeNotifier>(context, listen: false).recipeIngredients;

    setState(() {
      _filteredIngredients = ingredients.where((ingredient) {
        final name = AppLocalizations.of(context)!
            .ingredientTextList
            .split(',')[ingredient.id_ingredient - 1]
            .toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> _showQuantityDialog(RecipeIngredient ingredient) async {
    final quantity = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.ingredientQuantity),
        content: TextField(
          controller: _quantityController,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.ingredientQuantity,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelTxt),
          ),
          ElevatedButton(
            onPressed: () {
              if (_quantityController.text.trim().isNotEmpty) {
                Navigator.pop(context, _quantityController.text);
              }
            },
            child: Text(AppLocalizations.of(context)!.addText),
          ),
        ],
      ),
    );

    if (quantity != null && quantity.isNotEmpty) {
      widget.onIngredientSelected(ingredient.id_ingredient, quantity);
      _quantityController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.ingredientSelect,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: _filterIngredients,
                decoration: InputDecoration(
                  hintText: loc.ingredientSearch,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredIngredients.isEmpty
                        ? Center(
                            child: Text(
                              loc.notFoundError,
                              style: theme.textTheme.bodyLarge,
                            ),
                          )
                        : ListView.separated(
                            itemCount: _filteredIngredients.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final ingredient = _filteredIngredients[index];
                              final name = loc.ingredientTextList
                                  .split(',')[ingredient.id_ingredient - 1];

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: Text(
                                    name[0].toUpperCase(),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: theme.textTheme.titleMedium,
                                ),
                                trailing: const Icon(Icons.add),
                                onTap: () => _showQuantityDialog(ingredient),
                              );
                            },
                          ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.cancelTxt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
