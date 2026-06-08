import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_event/recipe_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

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
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _notifier = Provider.of<RecipeNotifier>(context, listen: false);
    _scrollController = ScrollController()..addListener(_onScroll);
    _loadIngredients();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    _quantityController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  Future<void> _loadIngredients() async {
    if (_isDisposed || !mounted) return;

    try {
      _safeSetState(() {
        _isLoading = true;
        _error = null;
      });

      // Ensure ingredients are loaded
      if (_notifier.recipeIngredients.isEmpty) {
        await _notifier.fetchIngredients();
      }

      if (_isDisposed || !mounted) return;
      _filterIngredients('');
    } catch (e) {
      if (_isDisposed || !mounted) return;
      _safeSetState(() => _error = e.toString());
    } finally {
      if (_isDisposed || !mounted) return;
      _safeSetState(() => _isLoading = false);
    }
  }

  void _filterIngredients(String query) {
    if (_isDisposed || !mounted) return;

    final ingredients = _notifier.recipeIngredients;

    _safeSetState(() {
      _filteredIngredients = ingredients.where((ingredient) {
        final name = _getIngredientName(ingredient);
        return name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  String _getIngredientName(RecipeIngredient ingredient) {
    // First try to use the ingredient's actual name from the API
    if (ingredient.ingredient_name.isNotEmpty) {
      return ingredient.ingredient_name;
    }

    // Fallback to translation if available
    try {
      final names = AppLocalizations.of(context)!.ingredientTextList.split(',');
      final id = ingredient.id_ingredient;
      if (id > 0 && id <= names.length) {
        return names[id - 1];
      }
      return 'Ingredient $id';
    } catch (e) {
      return 'Ingredient ${ingredient.id_ingredient}';
    }
  }

  void _navigateToIngredientManagement() async {
    // Close the dialog first
    Navigator.pop(context);

    // Navigate to ingredient management screen
    await Navigator.pushNamed(
      context,
      AppRoutes.ingredientManagement,
    );

    // Don't try to reload ingredients here - the widget is disposed
    // The popup will be recreated when opened again
  }

  String? _validateQuantity(String? value) {
    if (value?.isEmpty == true) return 'Please enter quantity';
    if (double.tryParse(value ?? '') == null)
      return 'Please enter a valid number';
    return null;
  }

  Future<void> _showQuantityDialog(RecipeIngredient ingredient) async {
    // Map of unit short codes to full names
    var units = GluttexConstants.recipeUnits;
    final loc = AppLocalizations.of(context)!;
    String selectedUnit = 'g'; // Default selected unit
    final amountController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String? _amountError;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(loc.ingredientQuantity),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: loc.amountText,
                      border: const OutlineInputBorder(),
                      errorText: _amountError,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amountError = null;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.pleaseEnterAmount;
                      }
                      final number = double.tryParse(value.trim());
                      if (number == null) {
                        return loc.pleaseInputvalidnumberMsg;
                      }
                      if (number <= 0) {
                        return loc.amountMustBeGreaterThanZero;
                      }
                      return null;
                    },
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
                        child: Text(
                          loc.ingredientUnits.split(',')[units.indexOf(unit)],
                        ),
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
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancelTxt),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate the form
                  if (_formKey.currentState!.validate()) {
                    final amount = amountController.text.trim();
                    Navigator.pop(context, '$selectedUnit:$amount');
                  }
                },
                child: Text(AppLocalizations.of(context)!.addText),
              ),
            ],
          );
        },
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
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noIngredientsFound,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
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
    if (_isFetchingMore || _isDisposed || !mounted) return;

    _isFetchingMore = true;
    try {
      await _notifier.fetchIngredients();
      if (!_isDisposed && mounted) {
        _filterIngredients(_searchController.text);
      }
    } catch (e) {
      debugPrint("Failed to fetch more ingredients: $e");
    } finally {
      if (!_isDisposed && mounted) {
        _isFetchingMore = false;
      }
    }
  }

  /// Build ingredient icon with priority: URL > SVG asset > Fallback icon
  Widget _buildIngredientIcon(RecipeIngredient ingredient) {
    final imageUrl = ingredient.ingredient_icon;
    final svgAssetPath =
        'assets/ingredient_svg/${ingredient.id_ingredient}.svg';

    // Check if URL is valid
    final hasValidUrl = imageUrl.isNotEmpty &&
        (imageUrl.startsWith('http') || imageUrl.startsWith('https'));

    if (!hasValidUrl) {
      // No URL, try local SVG asset
      return _buildSvgIcon(svgAssetPath);
    }

    // Check if the URL points to an SVG file
    final isSvgUrl = imageUrl.toLowerCase().endsWith('.svg');

    if (isSvgUrl) {
      // Load SVG from network using flutter_svg
      return SizedBox(
        width: 40,
        height: 40,
        child: SvgPicture.network(
          imageUrl,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorBuilder: (context, error, stackTrace) {
            // If network SVG fails, try local SVG asset
            return _buildSvgIcon(svgAssetPath);
          },
        ),
      );
    }

    // Load raster image (PNG, JPG, JPEG, etc.) from network
    return SizedBox(
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // If network image fails, try local SVG asset
            return _buildSvgIcon(svgAssetPath);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build SVG icon with fallback - simplified, no FutureBuilder
  Widget _buildSvgIcon(String svgAssetPath) {
    return SizedBox(
      width: 40,
      height: 40,
      child: SvgPicture.asset(
        svgAssetPath,
        package: "gluttex_chef",
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorBuilder: (context, error, stackTrace) {
          // If SVG doesn't exist, show fallback icon
          return _buildFallbackIcon();
        },
      ),
    );
  }

  /// Build fallback icon when both URL and SVG fail
  Widget _buildFallbackIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.food_bank,
        size: 24,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
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
        final name = _getIngredientName(ingredient);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: ListTile(
            leading: _buildIngredientIcon(ingredient),
            title: Text(name),
            trailing: const Icon(Icons.add),
            onTap: () => _showQuantityDialog(ingredient),
          ),
        );
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
              // Header with title and manage button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.ingredientSelect,
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: _navigateToIngredientManagement,
                    icon: const Icon(Icons.settings),
                    tooltip: AppLocalizations.of(context)!.manageIngredients,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: loc.searchTxt,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterIngredients('');
                          },
                        )
                      : null,
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
