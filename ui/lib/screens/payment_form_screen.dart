import 'package:flutter/material.dart';

/// A self-contained payment form.
///
/// Caller provides everything the screen needs:
///   - [amountDue]: the maximum the user can pay (post-payment validation)
///   - [onSubmit]: async callback that receives the amount + method + notes;
///                 return `null` on success, or an error message to display
///   - [initialAmount]: optional starting amount (defaults to [amountDue])
///   - [currencySymbol]: prefix for displayed amounts (defaults to empty)
///   - [title]: optional header text
class PaymentFormScreen extends StatefulWidget {
  final double amountDue;
  final double? initialAmount;
  final String currencySymbol;
  final String title;
  final Future<String?> Function(double amount, String method, String notes)
      onSubmit;

  const PaymentFormScreen({
    super.key,
    required this.amountDue,
    required this.onSubmit,
    this.initialAmount,
    this.currencySymbol = '',
    this.title = 'Payment',
  });

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  late final TextEditingController _amountController;
  final TextEditingController _notesController = TextEditingController();

  String _method = 'cash';
  String? _error;
  bool _submitting = false;

  static const _methods = <String, IconData>{
    'cash': Icons.payments_rounded,
    'card': Icons.credit_card_rounded,
    'bank_transfer': Icons.account_balance_rounded,
    'mobile_money': Icons.phone_android_rounded,
  };

  @override
  void initState() {
    super.initState();
    final start = widget.initialAmount ?? widget.amountDue;
    _amountController = TextEditingController(
      text: start > 0 ? start.toStringAsFixed(2) : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ==================== VALIDATION ====================

  String? _validateAmount(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 'Enter an amount';
    final value = double.tryParse(trimmed);
    if (value == null) return 'Enter a valid number';
    if (value <= 0) return 'Amount must be greater than zero';
    if (value > widget.amountDue) {
      return 'Amount cannot exceed ${_fmt(widget.amountDue)}';
    }
    return null;
  }

  // ==================== HELPERS ====================

  String _fmt(double amount) => '${widget.currencySymbol}'
      '${amount.toStringAsFixed(2)}';

  double get _currentAmount =>
      double.tryParse(_amountController.text.trim()) ?? 0.0;

  // ==================== SUBMIT ====================

  Future<void> _submit() async {
    final err = _validateAmount(_amountController.text);
    if (err != null) {
      setState(() => _error = err);
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      final result = await widget.onSubmit(
        _currentAmount,
        _method,
        _notesController.text.trim(),
      );

      if (!mounted) return;

      if (result != null) {
        setState(() => _error = result);
        return;
      }

      // Success — show confirmation, then pop.
      await _showSuccess();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showSuccess() async {
    final theme = Theme.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Icon(
          Icons.check_circle_rounded,
          size: 56,
          color: theme.colorScheme.primary,
        ),
        title: const Text('Payment recorded'),
        content: Text(
          '${_fmt(_currentAmount)} paid via ${_method.replaceAll('_', ' ')}.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Summary ──
              _SummaryCard(
                amountDue: widget.amountDue,
                amountEntered: _currentAmount,
                formatter: _fmt,
              ),
              const SizedBox(height: 24),

              // ── Amount field ──
              Text(
                'AMOUNT',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                enabled: !_submitting,
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: widget.currencySymbol,
                  errorText: _error,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.end,
                onChanged: (_) {
                  if (_error != null) {
                    setState(() => _error = null);
                  } else {
                    setState(() {}); // refresh summary + slider
                  }
                },
              ),
              const SizedBox(height: 12),

              // ── Slider ──
              if (widget.amountDue > 0) ...[
                Slider(
                  value: _currentAmount.clamp(0.0, widget.amountDue),
                  min: 0,
                  max: widget.amountDue,
                  divisions: widget.amountDue >= 100
                      ? (widget.amountDue).round().clamp(1, 1000)
                      : null,
                  label: _fmt(_currentAmount),
                  onChanged: _submitting
                      ? null
                      : (value) {
                          setState(() {
                            _amountController.text = value.toStringAsFixed(2);
                            _error = null;
                          });
                        },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                    Text(
                      _fmt(widget.amountDue),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // ── Method picker ──
              Text(
                'METHOD',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _methods.entries.map((e) {
                  final selected = _method == e.key;
                  return ChoiceChip(
                    avatar: Icon(
                      e.value,
                      size: 18,
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    label: Text(e.key.replaceAll('_', ' ').toUpperCase()),
                    selected: selected,
                    onSelected: _submitting
                        ? null
                        : (_) => setState(() => _method = e.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Notes ──
              Text(
                'NOTES',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                enabled: !_submitting,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Optional',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit ──
              FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(
                        'PAY ${_fmt(_currentAmount)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SUMMARY CARD ====================

class _SummaryCard extends StatelessWidget {
  final double amountDue;
  final double amountEntered;
  final String Function(double) formatter;

  const _SummaryCard({
    required this.amountDue,
    required this.amountEntered,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (amountDue - amountEntered).clamp(0.0, amountDue);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUTSTANDING',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatter(amountDue),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (amountEntered > 0 && remaining > 0) ...[
            const SizedBox(height: 12),
            Text(
              '${formatter(remaining)} remaining after this payment',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (amountEntered >= amountDue && amountDue > 0) ...[
            const SizedBox(height: 12),
            Text(
              'This settles the full amount',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
