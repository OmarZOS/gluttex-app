import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

class PaymentTypeSection extends StatefulWidget {
  final String selectedType;
  final double totalAmount;
  final double? depositAmount;
  final DateTime? installmentDate;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<double?> onDepositChanged;
  final ValueChanged<DateTime?> onInstallmentDateChanged;

  const PaymentTypeSection({
    super.key,
    required this.selectedType,
    required this.totalAmount,
    this.depositAmount,
    this.installmentDate,
    required this.onTypeChanged,
    required this.onDepositChanged,
    required this.onInstallmentDateChanged,
  });

  @override
  State<PaymentTypeSection> createState() => _PaymentTypeSectionState();
}

class _PaymentTypeSectionState extends State<PaymentTypeSection> {
  late TextEditingController _depositController;
  late TextEditingController _installmentDateController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _depositController = TextEditingController(
      text: widget.depositAmount?.toStringAsFixed(2) ?? '',
    );
    _installmentDateController = TextEditingController(
      text: _formatDate(widget.installmentDate),
    );
    _selectedDate = widget.installmentDate;
  }

  @override
  void didUpdateWidget(covariant PaymentTypeSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.depositAmount != oldWidget.depositAmount) {
      _depositController.text = widget.depositAmount?.toStringAsFixed(2) ?? '';
    }

    if (widget.installmentDate != oldWidget.installmentDate) {
      _selectedDate = widget.installmentDate;
      _installmentDateController.text = _formatDate(widget.installmentDate);
    }
  }

  @override
  void dispose() {
    _depositController.dispose();
    _installmentDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = _selectedDate ?? DateTime.now();
    final firstDate = DateTime.now();
    final lastDate = DateTime(DateTime.now().year + 1);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _installmentDateController.text = _formatDate(pickedDate);
      });
      widget.onInstallmentDateChanged(pickedDate);
    }
  }

  void _onDepositChanged(String value) {
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleanedValue.isNotEmpty) {
      final amount = double.tryParse(cleanedValue);
      widget.onDepositChanged(amount);
    } else {
      widget.onDepositChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final types = [
      ('payment', Icons.payment, loc.fullPayment, loc.fullPaymentDesc),
      (
        'deposit',
        Icons.account_balance_wallet,
        loc.depositOnly,
        loc.depositOnlyDesc
      ),
      (
        'installment',
        Icons.calendar_today,
        loc.installment,
        loc.installmentDesc
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.credit_card,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.paymentType,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc.selectPaymentType,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Type Cards
            Column(
              children: types.map((type) {
                final (id, icon, label, description) = type;
                final isSelected = widget.selectedType == id;

                return GestureDetector(
                  onTap: () => widget.onTypeChanged(id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary.withOpacity(0.05)
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline.withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        // Type header
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      label,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      description,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                                .withOpacity(0.8)
                                            : theme
                                                .colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),

                        // Dynamic content based on selection
                        if (isSelected) ...[
                          Divider(
                            height: 1,
                            color: theme.colorScheme.outline.withOpacity(0.1),
                          ),
                          _buildPaymentDetails(id, theme, loc),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(
      String type, ThemeData theme, AppLocalizations loc) {
    switch (type) {
      case 'payment':
        return _buildFullPaymentDetails(theme, loc);
      case 'deposit':
        return _buildDepositDetails(theme, loc);
      case 'installment':
        return _buildInstallmentDetails(theme, loc);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFullPaymentDetails(ThemeData theme, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.fullPaymentApplied,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.fullPaymentDescDetail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              loc.price(widget.totalAmount.toStringAsFixed(2)),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositDetails(ThemeData theme, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.enterDepositAmount,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _depositController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: loc.enterAmount,
                    prefixIcon: Icon(
                      Icons.money,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: _onDepositChanged,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  loc.price(widget.totalAmount.toStringAsFixed(2)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.depositAmount != null && widget.depositAmount! > 0)
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${loc.remainingAmount}: ${loc.price((widget.totalAmount - widget.depositAmount!).toStringAsFixed(2))}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInstallmentDetails(ThemeData theme, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.selectInstallmentDate,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.installmentDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _installmentDateController.text.isNotEmpty
                              ? _installmentDateController.text
                              : loc.selectDate,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: _installmentDateController.text.isNotEmpty
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.secondary.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.installmentNote,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.totalAmount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  loc.price(widget.totalAmount.toStringAsFixed(2)),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.secondary,
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
