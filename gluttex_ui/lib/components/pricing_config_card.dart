import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_event/views/pricing_config_view_model.dart';

class PricingConfigCard extends StatefulWidget {
  final double basePrice;
  final double taxPercentage;
  final double profitMargin;
  final double finalPrice;
  final PricingMode mode;
  final ValueChanged<double> onBasePriceChanged;
  final ValueChanged<double> onTaxPercentageChanged;
  final ValueChanged<double> onProfitMarginChanged;
  final ValueChanged<double> onFinalPriceChanged;
  final ValueChanged<PricingMode> onModeChanged;

  const PricingConfigCard({
    super.key,
    required this.basePrice,
    required this.taxPercentage,
    required this.profitMargin,
    required this.finalPrice,
    required this.mode,
    required this.onBasePriceChanged,
    required this.onTaxPercentageChanged,
    required this.onProfitMarginChanged,
    required this.onFinalPriceChanged,
    required this.onModeChanged,
  });

  @override
  State<PricingConfigCard> createState() => _PricingConfigCardState();
}

class _PricingConfigCardState extends State<PricingConfigCard> {
  late TextEditingController _taxController;
  late TextEditingController _profitController;
  late TextEditingController _finalPriceController;
  late TextEditingController _basePriceController;

  @override
  void initState() {
    super.initState();
    _taxController =
        TextEditingController(text: widget.taxPercentage.toStringAsFixed(2));
    _profitController =
        TextEditingController(text: widget.profitMargin.toStringAsFixed(2));
    _finalPriceController =
        TextEditingController(text: widget.finalPrice.toStringAsFixed(2));
    _basePriceController =
        TextEditingController(text: widget.basePrice.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(covariant PricingConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.taxPercentage != oldWidget.taxPercentage) {
      _taxController.text = widget.taxPercentage.toStringAsFixed(2);
    }
    if (widget.profitMargin != oldWidget.profitMargin) {
      _profitController.text = widget.profitMargin.toStringAsFixed(2);
    }
    if (widget.finalPrice != oldWidget.finalPrice) {
      _finalPriceController.text = widget.finalPrice.toStringAsFixed(2);
    }
    if (widget.basePrice != oldWidget.basePrice) {
      _basePriceController.text = widget.basePrice.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _taxController.dispose();
    _profitController.dispose();
    _finalPriceController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final taxAmount = widget.basePrice * widget.taxPercentage / 100;
    final priceAfterTax = widget.basePrice + taxAmount;
    final profitAmount = widget.mode == PricingMode.byProfit
        ? priceAfterTax * (widget.profitMargin / 100)
        : widget.finalPrice - priceAfterTax;
    final profitPercentage = widget.mode == PricingMode.byProfit
        ? widget.profitMargin
        : priceAfterTax > 0
            ? (profitAmount / priceAfterTax) * 100
            : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'Pricing Configuration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),

          // Mode selection
          _buildModeSelector(),
          const SizedBox(height: 16),

          // Tax field
          _buildConfigField(
            label: 'Tax Percentage',
            icon: Icons.account_balance,
            controller: _taxController,
            onChanged: (value) {
              final tax = double.tryParse(value) ?? 0.0;
              widget.onTaxPercentageChanged(tax);
            },
            suffix: '%',
          ),
          const SizedBox(height: 12),

          // Dynamic field based on mode
          if (widget.mode == PricingMode.byProfit)
            _buildConfigField(
              label: 'Profit Margin',
              icon: Icons.trending_up,
              controller: _profitController,
              onChanged: (value) {
                final profit = double.tryParse(value) ?? 0.0;
                widget.onProfitMarginChanged(profit);
              },
              suffix: '%',
            )
          else
            _buildConfigField(
              label: 'Final Price',
              icon: Icons.price_change,
              controller: _finalPriceController,
              onChanged: (value) {
                final price = double.tryParse(value) ?? 0.0;
                widget.onFinalPriceChanged(price);
              },
              suffix: '\$',
            ),

          const SizedBox(height: 12),

          // Base Price field
          _buildConfigField(
            label: 'Base Price',
            icon: Icons.price_check,
            controller: _basePriceController,
            onChanged: (value) {
              final price = double.tryParse(value) ?? 0.0;
              widget.onBasePriceChanged(price);
            },
            suffix: '\$',
          ),
          const SizedBox(height: 20),

          // Price preview
          _buildPricePreview(
            taxAmount: taxAmount,
            priceAfterTax: priceAfterTax,
            profitAmount: profitAmount,
            profitPercentage: profitPercentage,
            finalPrice: widget.mode == PricingMode.byProfit
                ? priceAfterTax * (1 + widget.profitMargin / 100)
                : widget.finalPrice,
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.settings, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            'Calculation Mode',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          _buildModeChip('By Profit', PricingMode.byProfit),
          const SizedBox(width: 8),
          _buildModeChip('By Final Price', PricingMode.byFinalPrice),
        ],
      ),
    );
  }

  Widget _buildModeChip(String label, PricingMode mode) {
    final isSelected = widget.mode == mode;
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color:
              isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          widget.onModeChanged(mode);
        }
      },
      backgroundColor: colorScheme.surfaceVariant,
      selectedColor: colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildConfigField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required String suffix,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
        filled: true,
        fillColor: colorScheme.surface,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }

  Widget _buildPricePreview({
    required double taxAmount,
    required double priceAfterTax,
    required double profitAmount,
    required double profitPercentage,
    required double finalPrice,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final taxPercentage = widget.taxPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base Price',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${widget.basePrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax (${taxPercentage.toStringAsFixed(2)}%)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${taxAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.mode == PricingMode.byProfit
                    ? 'Profit (${profitPercentage.toStringAsFixed(2)}%)'
                    : 'Profit',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${profitAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: profitAmount >= 0 ? Colors.green : Colors.red,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price After Tax',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${priceAfterTax.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Final Price',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '\$${finalPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.mode == PricingMode.byFinalPrice)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: profitAmount >= 0
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    profitAmount >= 0 ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: profitAmount >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Profit: ${profitPercentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: profitAmount >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
