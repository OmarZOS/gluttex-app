import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:event/views/pricing_config_view_model.dart';

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

  /// How long to wait after the last keystroke before firing the callback.
  final Duration debounce;

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
    this.debounce = const Duration(milliseconds: 400),
  });

  @override
  State<PricingConfigCard> createState() => _PricingConfigCardState();
}

class _PricingConfigCardState extends State<PricingConfigCard> {
  late final TextEditingController _basePriceController;
  late final TextEditingController _taxController;
  late final TextEditingController _profitController;
  late final TextEditingController _finalPriceController;

  final _basePriceFocus = FocusNode();
  final _taxFocus = FocusNode();
  final _profitFocus = FocusNode();
  final _finalPriceFocus = FocusNode();

  Timer? _debounce;
  String? _pendingField;

  @override
  void initState() {
    super.initState();
    _basePriceController = _controllerFor(widget.basePrice, _basePriceFocus);
    _taxController = _controllerFor(widget.taxPercentage, _taxFocus);
    _profitController = _controllerFor(widget.profitMargin, _profitFocus);
    _finalPriceController = _controllerFor(widget.finalPrice, _finalPriceFocus);

    // Commit on blur — instant feedback when the user tabs/clicks away.
    _basePriceFocus
        .addListener(() => _commitIfBlurred(_basePriceFocus, 'base'));
    _taxFocus.addListener(() => _commitIfBlurred(_taxFocus, 'tax'));
    _profitFocus.addListener(() => _commitIfBlurred(_profitFocus, 'profit'));
    _finalPriceFocus
        .addListener(() => _commitIfBlurred(_finalPriceFocus, 'final'));
  }

  TextEditingController _controllerFor(double value, FocusNode focus) {
    return TextEditingController(text: value.toStringAsFixed(2))
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: value.toStringAsFixed(2).length,
      );
  }

  @override
  void didUpdateWidget(covariant PricingConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only overwrite controllers when the value came from outside AND the
    // field isn't currently being edited. Otherwise typing gets clobbered.
    if (widget.basePrice != oldWidget.basePrice && !_basePriceFocus.hasFocus) {
      _basePriceController.text = widget.basePrice.toStringAsFixed(2);
    }
    if (widget.taxPercentage != oldWidget.taxPercentage &&
        !_taxFocus.hasFocus) {
      _taxController.text = widget.taxPercentage.toStringAsFixed(2);
    }
    if (widget.profitMargin != oldWidget.profitMargin &&
        !_profitFocus.hasFocus) {
      _profitController.text = widget.profitMargin.toStringAsFixed(2);
    }
    if (widget.finalPrice != oldWidget.finalPrice &&
        !_finalPriceFocus.hasFocus) {
      _finalPriceController.text = widget.finalPrice.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _basePriceController.dispose();
    _taxController.dispose();
    _profitController.dispose();
    _finalPriceController.dispose();
    _basePriceFocus.dispose();
    _taxFocus.dispose();
    _profitFocus.dispose();
    _finalPriceFocus.dispose();
    super.dispose();
  }

  // ==================== DEBOUNCE / COMMIT ====================

  void _commitIfBlurred(FocusNode focus, String field) {
    if (!focus.hasFocus) {
      _commitField(field);
    }
  }

  /// Schedule a debounced commit for the given field. Called from onChanged.
  void _scheduleCommit(String field) {
    _pendingField = field;
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () => _commitField(field));
  }

  /// Immediately commit whatever value is currently in the given field.
  void _commitField(String field) {
    _debounce?.cancel();
    _pendingField = null;

    switch (field) {
      case 'base':
        final value = double.tryParse(_basePriceController.text) ?? 0.0;
        widget.onBasePriceChanged(value);
        break;
      case 'tax':
        final value = double.tryParse(_taxController.text) ?? 0.0;
        widget.onTaxPercentageChanged(value);
        break;
      case 'profit':
        final value = double.tryParse(_profitController.text) ?? 0.0;
        widget.onProfitMarginChanged(value);
        break;
      case 'final':
        final value = double.tryParse(_finalPriceController.text) ?? 0.0;
        widget.onFinalPriceChanged(value);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
    final computedFinal = widget.mode == PricingMode.byProfit
        ? priceAfterTax * (1 + widget.profitMargin / 100)
        : widget.finalPrice;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Icon(Icons.tune_rounded, color: colorScheme.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Pricing Configuration',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Mode selector ──
          _ModeSelector(
            mode: widget.mode,
            onChanged: widget.onModeChanged,
          ),
          const SizedBox(height: 20),

          // ── Inputs ──
          _NumericField(
            label: 'Base Price',
            helper: 'Cost before tax',
            controller: _basePriceController,
            focusNode: _basePriceFocus,
            icon: Icons.inventory_2_outlined,
            suffix: 'DZD',
            onChanged: (_) => _scheduleCommit('base'),
            onSubmitted: (_) => _commitField('base'),
          ),
          const SizedBox(height: 14),
          _NumericField(
            label: 'Tax',
            helper: 'Applied on base price',
            controller: _taxController,
            focusNode: _taxFocus,
            icon: Icons.percent_rounded,
            suffix: '%',
            onChanged: (_) => _scheduleCommit('tax'),
            onSubmitted: (_) => _commitField('tax'),
          ),
          const SizedBox(height: 14),

          // Only the "driver" field is shown — the one the user actually types.
          if (widget.mode == PricingMode.byProfit)
            _NumericField(
              label: 'Profit Margin',
              helper: 'Markup on price after tax',
              controller: _profitController,
              focusNode: _profitFocus,
              icon: Icons.trending_up_rounded,
              suffix: '%',
              onChanged: (_) => _scheduleCommit('profit'),
              onSubmitted: (_) => _commitField('profit'),
            )
          else
            _NumericField(
              label: 'Final Price',
              helper: 'What the customer pays',
              controller: _finalPriceController,
              focusNode: _finalPriceFocus,
              icon: Icons.sell_outlined,
              suffix: 'DZD',
              onChanged: (_) => _scheduleCommit('final'),
              onSubmitted: (_) => _commitField('final'),
            ),

          const SizedBox(height: 24),

          // ── Preview ──
          _PricePreview(
            basePrice: widget.basePrice,
            taxAmount: taxAmount,
            priceAfterTax: priceAfterTax,
            profitAmount: profitAmount,
            profitPercentage: profitPercentage,
            finalPrice: computedFinal,
          ),
        ],
      ),
    );
  }
}

// ==================== MODE SELECTOR ====================

class _ModeSelector extends StatelessWidget {
  final PricingMode mode;
  final ValueChanged<PricingMode> onChanged;

  const _ModeSelector({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: 'By Profit',
            icon: Icons.trending_up_rounded,
            selected: mode == PricingMode.byProfit,
            onTap: () => onChanged(PricingMode.byProfit),
          ),
          _ModeTab(
            label: 'By Final Price',
            icon: Icons.sell_rounded,
            selected: mode == PricingMode.byFinalPrice,
            onTap: () => onChanged(PricingMode.byFinalPrice),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? colorScheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== NUMERIC FIELD ====================

class _NumericField extends StatelessWidget {
  final String label;
  final String helper;
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData icon;
  final String suffix;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  const _NumericField({
    required this.label,
    required this.helper,
    required this.controller,
    required this.focusNode,
    required this.icon,
    required this.suffix,
    required this.onChanged,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            prefixIcon:
                Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            suffixText: suffix,
            helperText: helper,
            helperStyle: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.15),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ==================== PRICE PREVIEW ====================

class _PricePreview extends StatelessWidget {
  final double basePrice;
  final double taxAmount;
  final double priceAfterTax;
  final double profitAmount;
  final double profitPercentage;
  final double finalPrice;

  const _PricePreview({
    required this.basePrice,
    required this.taxAmount,
    required this.priceAfterTax,
    required this.profitAmount,
    required this.profitPercentage,
    required this.finalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final isProfitPositive = profitAmount >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.15),
            colorScheme.primaryContainer.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BREAKDOWN',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          _PreviewRow(
            label: 'Base price',
            value: _fmt(basePrice, loc),
          ),
          const SizedBox(height: 8),
          _PreviewRow(
            label: 'Tax',
            value: '+ ${_fmt(taxAmount, loc)}',
          ),
          const SizedBox(height: 8),
          _PreviewRow(
            label: 'Price after tax',
            value: _fmt(priceAfterTax, loc),
            muted: true,
          ),
          const SizedBox(height: 8),
          _PreviewRow(
            label: 'Profit (${profitPercentage.toStringAsFixed(2)}%)',
            value: '${isProfitPositive ? '+' : ''} ${_fmt(profitAmount, loc)}',
            valueColor:
                isProfitPositive ? Colors.green.shade700 : colorScheme.error,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          // ── Final price, prominent ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Final price',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                _fmt(finalPrice, loc),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ],
          ),

          // ── Profit badge (only when in byFinalPrice mode) ──
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isProfitPositive ? Colors.green : colorScheme.error)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isProfitPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 14,
                    color: isProfitPositive
                        ? Colors.green.shade700
                        : colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isProfitPositive ? '+' : ''}'
                    '${profitPercentage.toStringAsFixed(2)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isProfitPositive
                          ? Colors.green.shade700
                          : colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double amount, AppLocalizations? loc) {
    if (loc == null) return amount.toStringAsFixed(2);
    return loc.price(amount.toStringAsFixed(2));
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool muted;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: muted
                ? colorScheme.onSurfaceVariant.withOpacity(0.7)
                : colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
