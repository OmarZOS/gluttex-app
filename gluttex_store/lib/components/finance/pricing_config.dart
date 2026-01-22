import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_event/views/pricing_config_view_model.dart';
import 'package:gluttex_ui/components/pricing_config_card.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_event/product_change_notifier.dart';

class PricingConfigScreen extends StatefulWidget {
  final PricingConfigViewModel viewModel;
  final bool isLoading;
  final VoidCallback onSave;
  final ValueChanged<double> onBasePriceChanged;
  final ValueChanged<double> onTaxPercentageChanged;
  final ValueChanged<double> onProfitMarginChanged;
  final ValueChanged<double> onFinalPriceChanged;
  final ValueChanged<PricingMode> onModeChanged;
  final ValueChanged<Product> onToggleProductSelection;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onUpdateSelectedProducts;
  final VoidCallback onClearSelection;

  const PricingConfigScreen({
    super.key,
    required this.viewModel,
    required this.isLoading,
    required this.onSave,
    required this.onBasePriceChanged,
    required this.onTaxPercentageChanged,
    required this.onProfitMarginChanged,
    required this.onFinalPriceChanged,
    required this.onModeChanged,
    required this.onToggleProductSelection,
    required this.onToggleSelectAll,
    required this.onUpdateSelectedProducts,
    required this.onClearSelection,
  });

  @override
  State<PricingConfigScreen> createState() => _PricingConfigScreenState();
}

class _PricingConfigScreenState extends State<PricingConfigScreen> {
  late double _localBasePrice;
  late double _localTaxPercentage;
  late double _localProfitMargin;
  late double _localFinalPrice;
  late PricingMode _localMode;

  @override
  void initState() {
    super.initState();
    // Initialize with viewModel values
    _localBasePrice = widget.viewModel.basePrice;
    _localTaxPercentage = widget.viewModel.taxPercentage;
    _localProfitMargin = widget.viewModel.profitMargin;
    _localFinalPrice = widget.viewModel.finalPrice;
    _localMode = widget.viewModel.mode;
  }

  @override
  void didUpdateWidget(covariant PricingConfigScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only update local state when viewModel changes significantly
    // This prevents frequent updates that reset text fields
    if (widget.viewModel.basePrice != oldWidget.viewModel.basePrice &&
        !_isEditingBasePrice) {
      _localBasePrice = widget.viewModel.basePrice;
    }
    if (widget.viewModel.taxPercentage != oldWidget.viewModel.taxPercentage &&
        !_isEditingTax) {
      _localTaxPercentage = widget.viewModel.taxPercentage;
    }
    if (widget.viewModel.profitMargin != oldWidget.viewModel.profitMargin &&
        !_isEditingProfit) {
      _localProfitMargin = widget.viewModel.profitMargin;
    }
    if (widget.viewModel.finalPrice != oldWidget.viewModel.finalPrice &&
        !_isEditingFinalPrice) {
      _localFinalPrice = widget.viewModel.finalPrice;
    }
    if (widget.viewModel.mode != oldWidget.viewModel.mode) {
      _localMode = widget.viewModel.mode;
    }
  }

  bool _isEditingBasePrice = false;
  bool _isEditingTax = false;
  bool _isEditingProfit = false;
  bool _isEditingFinalPrice = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PricingConfigCard(
              basePrice: _localBasePrice,
              taxPercentage: _localTaxPercentage,
              profitMargin: _localProfitMargin,
              finalPrice: _localFinalPrice,
              mode: _localMode,
              onBasePriceChanged: (value) {
                setState(() => _localBasePrice = value);
                widget.onBasePriceChanged(value);
              },
              onTaxPercentageChanged: (value) {
                setState(() => _localTaxPercentage = value);
                widget.onTaxPercentageChanged(value);
              },
              onProfitMarginChanged: (value) {
                setState(() => _localProfitMargin = value);
                widget.onProfitMarginChanged(value);
              },
              onFinalPriceChanged: (value) {
                setState(() => _localFinalPrice = value);
                widget.onFinalPriceChanged(value);
              },
              onModeChanged: (value) {
                setState(() => _localMode = value);
                widget.onModeChanged(value);
              },
            ),
            // ... rest of your code remains the same
            const SizedBox(height: 20),
            _buildProductSelector(context),
            if (widget.viewModel.selectedProducts.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildBatchActions(context),
            ],
            if (widget.isLoading) ...[
              const SizedBox(height: 20),
              _buildLoadingIndicator(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelector(BuildContext context) {
    return Consumer<ProductNotifier>(
      builder: (context, productNotifier, _) {
        final products = productNotifier.products;

        if (products.isEmpty) {
          return _buildEmptyProductState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Select Products',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => widget.onToggleSelectAll(),
                  child: Text(
                    widget.viewModel.selectedProducts.length == products.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductSelectionCard(context, products[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductSelectionCard(BuildContext context, Product product) {
    final isSelected = widget.viewModel.selectedProducts.contains(product);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => widget.onToggleProductSelection(product),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.product_name ?? 'Product',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Current: DZD${product.product_price?.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Text(
                'New: DZD${widget.viewModel.finalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            const SizedBox(height: 2),
            if (isSelected)
              Text(
                'Profit: ${widget.viewModel.profitMargin.toStringAsFixed(2)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.viewModel.profitMargin >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update ${widget.viewModel.selectedProducts.length} Products',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.viewModel.profitMargin >= 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.viewModel.profitMargin.toStringAsFixed(2)}% Profit',
                  style: TextStyle(
                    color: widget.viewModel.profitMargin >= 0
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Final Price: DZD${widget.viewModel.finalPrice.toStringAsFixed(2)} per product',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onClearSelection,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Selection'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      widget.isLoading ? null : widget.onUpdateSelectedProducts,
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.update),
                  label:
                      Text(widget.isLoading ? 'Updating...' : 'Update Prices'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading pricing data...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProductState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.inventory_2,
            size: 48,
            color:
                Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Products Available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to configure pricing',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
