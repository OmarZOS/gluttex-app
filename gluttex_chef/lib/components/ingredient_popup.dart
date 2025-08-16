import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_impl_business/recipe_change_notifier.dart';
import 'package:provider/provider.dart';

class IngredientPopup extends StatefulWidget {
  final Function(int ingredientId, String quantity) onIngredientSelected;

  const IngredientPopup({super.key, required this.onIngredientSelected});

  @override
  State<IngredientPopup> createState() => _IngredientPopupState();
}

class _IngredientPopupState extends State<IngredientPopup> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<RecipeIngredient> _filteredIngredients = [];
  bool _isLoading = true;
  String? _error;
  late RecipeNotifier _notifier;
  bool _isFetchingMore = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _notifier = Provider.of<RecipeNotifier>(context, listen: false);
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadIngredients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Ensure ingredients are loaded
      if (_notifier.recipeIngredients.isEmpty) {
        await _notifier.fetchIngredients();
      }

      _filterIngredients('');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterIngredients(String query) {
    final ingredients = _notifier.recipeIngredients;

    setState(() {
      _filteredIngredients = ingredients.where((ingredient) {
        final name = _getIngredientName(ingredient.id_ingredient);
        return name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  String _getIngredientName(int id) {
    try {
      final names = AppLocalizations.of(context)!.ingredientTextList.split(',');
      return names[id - 1]; // Safe fallback
    } catch (e) {
      return 'Ingredient $id';
    }
  }

  Future<void> _showQuantityDialog(RecipeIngredient ingredient) async {
    // Map of unit short codes to full names
    var units = GluttexConstants.recipeUnits;
    final loc = AppLocalizations.of(context)!;
    String selectedUnit = 'g'; // Default selected unit
    final amountController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.ingredientQuantity),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: loc.amountText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedUnit,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: loc.unitText,
              ),
              items: units.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child:
                      Text(loc.ingredientUnits.split(',')[units.indexOf(unit)]),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedUnit = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancelTxt),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = amountController.text.trim();
              if (amount.isNotEmpty) {
                // Store in shortCode:value format
                Navigator.pop(context, '$selectedUnit:$amount');
              }
            },
            child: Text(AppLocalizations.of(context)!.addText),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      widget.onIngredientSelected(ingredient.id_ingredient, result);
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.notFoundError,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadIngredients,
            child: Text(AppLocalizations.of(context)!.notFoundError),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.notFoundError,
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isFetchingMore &&
        _notifier.hasMoreIngredients) {
      _fetchMoreIngredients();
    }
  }

  Future<void> _fetchMoreIngredients() async {
    _isFetchingMore = true;
    try {
      await _notifier.fetchIngredients(); // Should fetch the next page
      _filterIngredients(_searchController.text); // Re-filter after fetching
    } catch (e) {
      debugPrint("Failed to fetch more ingredients: $e");
    } finally {
      _isFetchingMore = false;
    }
  }

  Widget _buildIngredientList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount:
          _filteredIngredients.length + (_notifier.hasMoreIngredients ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _filteredIngredients.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final ingredient = _filteredIngredients[index];
        final name = _getIngredientName(ingredient.id_ingredient);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4, // Shadow depth
          child: ListTile(
            leading: SvgPicture.asset(
              'assets/ingredient_svg/${ingredient.id_ingredient}.svg',
              package: "gluttex_chef",
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              placeholderBuilder: (context) => const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            title: Text(name),
            trailing: const Icon(Icons.add),
            onTap: () => _showQuantityDialog(ingredient),
          ),
        );
        ;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
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
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: loc.searchTxt,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: _filterIngredients,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : _filteredIngredients.isEmpty
                            ? _buildEmptyState()
                            : _buildIngredientList(),
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
