// ingredient_management_screen.dart
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Recipe.dart';
import 'package:gluttex_event/recipe_change_notifier.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:provider/provider.dart';

class IngredientManagementScreen extends StatefulWidget {
  const IngredientManagementScreen({super.key});

  @override
  State<IngredientManagementScreen> createState() =>
      _IngredientManagementScreenState();
}

class _IngredientManagementScreenState
    extends State<IngredientManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iconController = TextEditingController();

  bool _isLoading = false;
  String? _currentOperationKey;
  RecipeIngredient? _editingIngredient;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _loadIngredients() async {
    final notifier = context.read<RecipeNotifier>();
    if (notifier.recipeIngredients.isEmpty) {
      await notifier.fetchAllIngredients();
    }
    setState(() {});
  }

  Future<void> _addOrUpdateIngredient() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ingredient name')),
      );
      return;
    }

    _currentOperationKey = _editingIngredient == null
        ? 'add_ingredient_${DateTime.now().millisecondsSinceEpoch}'
        : 'update_ingredient_${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isLoading = true);

    final notifier = context.read<RecipeNotifier>();
    bool success;

    if (_editingIngredient == null) {
      success = await notifier.addIngredient(
        _nameController.text.trim(),
        _iconController.text.trim(),
        callerKey: _currentOperationKey,
      );
    } else {
      success = await notifier.updateIngredient(
        _editingIngredient!.id_ingredient,
        _nameController.text.trim(),
        _iconController.text.trim(),
        callerKey: _currentOperationKey,
      );
    }

    if (!mounted) return;

    if (success) {
      final response = notifier.getResponse(_currentOperationKey!);
      ResponseHandler.handleResponse(
        context: context,
        statusCode: response?.statusCode ?? 200,
        responseCode: response?.responseCode ?? 'SUCCESS',
        finalMessage: _editingIngredient == null
            ? 'Ingredient added successfully'
            : 'Ingredient updated successfully',
      );
      _resetForm();
      await _loadIngredients();
    } else {
      final response = notifier.getResponse(_currentOperationKey!);
      ResponseHandler.handleResponse(
        context: context,
        statusCode: response?.statusCode ?? 500,
        responseCode: response?.responseCode ?? 'FAILED',
        finalMessage: response?.message ?? 'Operation failed',
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _deleteIngredient(RecipeIngredient ingredient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ingredient'),
        content: Text(
            'Are you sure you want to delete "${ingredient.ingredient_name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    _currentOperationKey =
        'delete_ingredient_${DateTime.now().millisecondsSinceEpoch}';
    setState(() => _isLoading = true);

    final notifier = context.read<RecipeNotifier>();
    final success = await notifier.deleteIngredient(
      ingredient.id_ingredient,
      callerKey: _currentOperationKey,
    );

    if (!mounted) return;

    if (success) {
      final response = notifier.getResponse(_currentOperationKey!);
      ResponseHandler.handleResponse(
        context: context,
        statusCode: response?.statusCode ?? 200,
        responseCode: response?.responseCode ?? 'SUCCESS',
        finalMessage: 'Ingredient deleted successfully',
      );
      await _loadIngredients();
    } else {
      final response = notifier.getResponse(_currentOperationKey!);
      ResponseHandler.handleResponse(
        context: context,
        statusCode: response?.statusCode ?? 500,
        responseCode: response?.responseCode ?? 'FAILED',
        finalMessage: response?.message ?? 'Failed to delete ingredient',
      );
    }

    setState(() => _isLoading = false);
  }

  void _resetForm() {
    _nameController.clear();
    _iconController.clear();
    setState(() => _editingIngredient = null);
  }

  void _editIngredient(RecipeIngredient ingredient) {
    setState(() {
      _editingIngredient = ingredient;
      _nameController.text = ingredient.ingredient_name;
      _iconController.text = ingredient.ingredient_icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<RecipeNotifier>();
    final ingredients = notifier.getAllIngredients();
    final filteredIngredients = _searchController.text.isEmpty
        ? ingredients
        : notifier.searchIngredients(_searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Ingredients'),
        actions: [
          if (_editingIngredient != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _resetForm,
              tooltip: 'Cancel edit',
            ),
        ],
      ),
      body: Column(
        children: [
          // Add/Edit Form
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredient Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _iconController,
                  decoration: const InputDecoration(
                    labelText: 'Icon URL (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _addOrUpdateIngredient,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _editingIngredient == null ? Icons.add : Icons.save),
                  label: Text(_editingIngredient == null
                      ? 'Add Ingredient'
                      : 'Update Ingredient'),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search ingredients...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Ingredients List
          Expanded(
            child: notifier.isLoading && ingredients.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredIngredients.isEmpty
                    ? const Center(child: Text('No ingredients found'))
                    : ListView.builder(
                        itemCount: filteredIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = filteredIngredients[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: ingredient.ingredient_icon.isNotEmpty
                                  ? Image.network(
                                      ingredient.ingredient_icon,
                                      width: 40,
                                      height: 40,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.food_bank),
                                    )
                                  : const Icon(Icons.food_bank, size: 40),
                              title: Text(ingredient.ingredient_name),
                              subtitle: Text('ID: ${ingredient.id_ingredient}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        _editIngredient(ingredient),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _deleteIngredient(ingredient),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
