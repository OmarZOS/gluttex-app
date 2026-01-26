import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_event/finance_change_notifier.dart';
import 'package:gluttex_ui/components/finance/Payment_Type_UI_Manager.dart';
import 'package:gluttex_ui/components/finance/financial_ui_manager.dart';
import 'package:gluttex_ui/components/finance/payment_request_helper.dart';
import 'package:provider/provider.dart';

class PaymentFormScreen extends StatefulWidget {
  final FinancialDocument? sourceDocument;
  final bool isEditing;

  const PaymentFormScreen({
    Key? key,
    this.sourceDocument,
    this.isEditing = false,
  }) : super(key: key);

  @override
  _PaymentFormScreenState createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isLoading = false;
  String _selectedPaymentType = 'deposit';
  DateTime? _selectedInstallmentDate;
  bool _isAmountValid = true;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _initializeFromDocument();

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _depositController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeFromDocument() {
    if (widget.sourceDocument != null) {
      final doc = widget.sourceDocument!;
      if (doc.totalDeposited > 0) {
        _selectedPaymentType = 'deposit';
        _depositController.text = doc.remainingAmount.toStringAsFixed(2);
      } else {
        _selectedPaymentType = 'payment';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Consumer<FinanceChangeNotifier>(
      builder: (context, notifier, _) {
        final doc = widget.sourceDocument;
        final displayTypes = _getPaymentTypesToShow(doc, loc);
        final hasExistingDeposit = (doc?.totalDeposited ?? 0) > 0;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: _buildAppBar(context, theme, loc, doc),
          body: _isLoading || notifier.isLoading
              ? _buildLoadingState(theme)
              : AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      ),
                    );
                  },
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Main content
                      SliverPadding(
                        padding: const EdgeInsets.all(24),
                        sliver: SliverToBoxAdapter(
                          child: Form(
                            key: _formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Document summary card
                                if (doc != null) ...[
                                  _buildDocumentSummary(context, theme, loc,
                                      doc, hasExistingDeposit),
                                  const SizedBox(height: 32),
                                ],

                                // Payment type selection
                                _buildPaymentTypeSection(
                                    context, theme, loc, displayTypes, doc),

                                // const SizedBox(height: 32),

                                // // Only show deposit details immediately if there's already a deposit
                                if (!hasExistingDeposit &&
                                    displayTypes.length != 1)
                                  _buildDetailsSection(
                                      context, theme, loc, doc),
                                // if (_selectedPaymentType.isNotEmpty)
                                //   _buildDetailsSection(
                                //       context, theme, loc, doc),

                                const SizedBox(height: 32),

                                // Notes field
                                _buildNotesSection(theme, loc),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Action buttons - sticky at bottom
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border(
                              top: BorderSide(
                                color:
                                    theme.colorScheme.outline.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    theme.colorScheme.shadow.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: -10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: _buildActionButtons(context, theme, loc,
                              notifier, doc, hasExistingDeposit),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme,
      AppLocalizations loc, FinancialDocument? doc) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        _getAppBarTitle(doc, loc),
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSummary(BuildContext context, ThemeData theme,
      AppLocalizations loc, FinancialDocument doc, bool hasExistingDeposit) {
    // final documentColor =
    //     FinancialUIManager.getDocumentColor(doc.documentType, theme);
    final paymentStatusColor =
        FinancialUIManager.getPaymentStatusColor(doc.paymentStatus, theme);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.08),
            theme.colorScheme.primaryContainer.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FinancialUIManager.getDocumentIcon(doc.documentType),
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FinancialUIManager.getDocumentTypeDisplay(
                          doc.documentType, loc),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.documentNumber,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: paymentStatusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: paymentStatusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        FinancialUIManager.getPaymentStatusDisplay(
                                doc.paymentStatus, loc)
                            .toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: paymentStatusColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Amount breakdown
          Row(
            children: [
              Expanded(
                child: _buildAmountMetric(
                  theme: theme,
                  label: loc.totalAmount,
                  amount: doc.documentAmount,
                  context: context,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
              Expanded(
                child: _buildAmountMetric(
                  theme: theme,
                  label: loc.remainingAmount,
                  amount: doc.remainingAmount,
                  context: context,
                  isRemaining: true,
                ),
              ),
            ],
          ),

          // Existing deposit info
          if (hasExistingDeposit) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.tertiaryContainer.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.tertiaryContainer.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 20,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.depositOnly.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PaymentTypeUIManager.formatAmount(
                              doc.totalDeposited, loc),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer
                                .withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${loc.addDeposit} →',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountMetric({
    required ThemeData theme,
    required String label,
    required double amount,
    required BuildContext context,
    bool isRemaining = false,
  }) {
    final color = isRemaining
        ? (amount > 0 ? theme.colorScheme.error : theme.colorScheme.primary)
        : theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          PaymentTypeUIManager.formatAmount(
              amount, AppLocalizations.of(context)!),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeSection(
      BuildContext context,
      ThemeData theme,
      AppLocalizations loc,
      List<PaymentType> displayTypes,
      FinancialDocument? doc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.paymentType.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        if (displayTypes.length > 1) ...[
          Column(
            children: displayTypes.map((type) {
              final isSelected = _selectedPaymentType == type.id;
              final color = _getPaymentTypeColor(type.id, theme);

              return GestureDetector(
                onTap: () => _onPaymentTypeChanged(type.id, doc),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.08)
                        : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? color.withOpacity(0.3)
                          : theme.colorScheme.outline.withOpacity(0.1),
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          type.icon,
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (type.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                type.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ] else if (displayTypes.length == 1 ||
            _selectedPaymentType == "deposit") ...[
          _buildDetailsWidget(displayTypes.first.id, context, theme, loc, doc),
        ],
      ],
    );
  }

  Color _getPaymentTypeColor(String typeId, ThemeData theme) {
    switch (typeId) {
      case 'payment':
        return theme.colorScheme.primary;
      case 'deposit':
        return theme.colorScheme.tertiary;
      case 'installment':
        return theme.colorScheme.secondary;
      default:
        return theme.colorScheme.primary;
    }
  }

  Widget _buildDetailsSection(BuildContext context, ThemeData theme,
      AppLocalizations loc, FinancialDocument? doc) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child:
          _buildDetailsWidget(_selectedPaymentType, context, theme, loc, doc),
    );
  }

  Widget _buildDetailsWidget(String typeId, BuildContext context,
      ThemeData theme, AppLocalizations loc, FinancialDocument? doc) {
    switch (typeId) {
      case 'payment':
        return _buildFullPaymentDetails(context, theme, loc, doc);
      case 'deposit':
        return _buildDepositDetails(context, theme, loc, doc);
      case 'installment':
        return _buildInstallmentDetails(context, theme, loc, doc);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFullPaymentDetails(BuildContext context, ThemeData theme,
      AppLocalizations loc, FinancialDocument? doc) {
    final color = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.paymentDetails,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  loc.totalAmount.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                PaymentTypeUIManager.formatAmount(
                  doc?.remainingAmount ?? 0.0,
                  loc,
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepositDetails(BuildContext context, ThemeData theme,
      AppLocalizations loc, FinancialDocument? doc) {
    final remainingAmount = doc?.remainingAmount ?? 0.0;
    final currentDeposit = double.tryParse(_depositController.text) ?? 0.0;
    final color = theme.colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.depositDetails,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                PaymentTypeUIManager.formatAmount(currentDeposit, loc),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Amount input
          TextFormField(
            controller: _depositController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: loc.depositAmount,
              labelStyle: TextStyle(color: color),
              hintText: '0.00',
              prefixIcon: Icon(
                Icons.attach_money_rounded,
                color: color,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.auto_fix_high_rounded,
                  color: color.withOpacity(0.7),
                ),
                onPressed: () {
                  setState(() {
                    _depositController.text =
                        remainingAmount.toStringAsFixed(2);
                  });
                },
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: color.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
            validator: (value) => PaymentRequestHelper.validateDepositAmount(
                value, widget.sourceDocument),
            onChanged: (value) {
              setState(() {
                _isAmountValid = PaymentRequestHelper.validateDepositAmount(
                        value, widget.sourceDocument) ==
                    null;
              });
            },
          ),

          const SizedBox(height: 16),

          // Amount slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    PaymentTypeUIManager.formatAmount(remainingAmount, loc),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 12),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 20),
                  valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                  valueIndicatorTextStyle:
                      theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  valueIndicatorColor: color,
                ),
                child: Slider(
                  value: currentDeposit.clamp(0.0, remainingAmount),
                  min: 0,
                  max: remainingAmount,
                  divisions:
                      remainingAmount > 0 ? (remainingAmount / 10).round() : 1,
                  label: PaymentTypeUIManager.formatAmount(currentDeposit, loc),
                  activeColor: color,
                  inactiveColor: color.withOpacity(0.2),
                  onChanged: (value) {
                    setState(() {
                      _depositController.text = value.toStringAsFixed(2);
                      _isAmountValid = true;
                    });
                  },
                ),
              ),
            ],
          ),

          if (!_isAmountValid && _depositController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: theme.colorScheme.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      PaymentRequestHelper.validateDepositAmount(
                              _depositController.text, widget.sourceDocument) ??
                          '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstallmentDetails(BuildContext context, ThemeData theme,
      AppLocalizations loc, FinancialDocument? doc) {
    final color = theme.colorScheme.secondary;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  loc.installmentDetails,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _selectInstallmentDate(context, color),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.dueDate.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedInstallmentDate != null
                              ? PaymentTypeUIManager.formatDate(
                                  _selectedInstallmentDate!)
                              : loc.selectDate,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _selectedInstallmentDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_selectedInstallmentDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      loc.installmentScheduled,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: color.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection(ThemeData theme, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.notes.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: loc.notesOptional,
            hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context,
      ThemeData theme,
      AppLocalizations loc,
      FinanceChangeNotifier notifier,
      FinancialDocument? doc,
      bool hasExistingDeposit) {
    final isDeposit = _selectedPaymentType == 'deposit';
    final buttonText = hasExistingDeposit
        ? loc.addDeposit
        : isDeposit
            ? loc.submitDeposit
            : loc.submitPayment;
    final isValid = _selectedPaymentType != 'installment' ||
        _selectedInstallmentDate != null;
    final isDepositValid = _selectedPaymentType != 'deposit' || _isAmountValid;

    final buttonColor =
        isDeposit ? theme.colorScheme.tertiary : theme.colorScheme.primary;

    return Column(
      children: [
        if (!isValid || !isDepositValid)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.errorContainer.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedPaymentType == 'installment'
                        ? loc.selectDateForInstallment
                        : loc.enterValidAmount,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Material(
            color: (isValid && isDepositValid)
                ? buttonColor
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: (isValid && isDepositValid)
                  ? () => _submitForm(notifier)
                  : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading || notifier.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    Text(
                      buttonText.toUpperCase(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: (isValid && isDepositValid)
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            foregroundColor: theme.colorScheme.onSurfaceVariant,
          ),
          child: Text(
            loc.cancel.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectInstallmentDate(BuildContext context, Color color) async {
    final initialDate = DateTime.now().add(const Duration(days: 30));
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: color,
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _selectedInstallmentDate = selectedDate;
      });
    }
  }

  void _onPaymentTypeChanged(String typeId, FinancialDocument? doc) {
    if (_selectedPaymentType != typeId) {
      setState(() {
        _selectedPaymentType = typeId;
        if (typeId == 'deposit' && doc != null) {
          _depositController.text = doc.remainingAmount.toStringAsFixed(2);
          _isAmountValid = true;
        }
      });
    }
  }

  Future<void> _submitForm(FinanceChangeNotifier notifier) async {
    if (_selectedPaymentType == 'deposit') {
      final validationError = PaymentRequestHelper.validateDepositAmount(
        _depositController.text,
        widget.sourceDocument,
      );
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    if (_selectedPaymentType == 'installment' &&
        _selectedInstallmentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a date for the installment'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sourceDocId = widget.sourceDocument?.documentId;
      final notes = _notesController.text.trim();
      dynamic result;

      if (_selectedPaymentType == 'payment') {
        final payment = PaymentRequestHelper.createPayment(
          amount: widget.sourceDocument?.remainingAmount ?? 0.0,
          sourceDocument: widget.sourceDocument,
          notes: notes,
        );
        result = await notifier.submitPayment(payment, sourceDocId);
      } else if (_selectedPaymentType == 'deposit') {
        final depositAmount = double.tryParse(_depositController.text) ?? 0.0;
        final deposit = PaymentRequestHelper.createDeposit(
          amount: depositAmount,
          sourceDocument: widget.sourceDocument,
          notes: notes,
        );
        result = await notifier.submitDeposit(deposit, sourceDocId);
      } else {
        final installmentData = PaymentRequestHelper.createInstallmentRequest(
          date: _selectedInstallmentDate!,
          notes: notes,
        );
        result = await notifier.submitFinancialDocument(installmentData);
      }

      if (result != null && !(result is String && result.contains('failed'))) {
        await _showSuccessDialog();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifier.refreshAll(calculateAnalytics: true);
        });
        if (mounted) Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result is String ? result : 'Submission failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error submitting form: $e\n$stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showSuccessDialog() async {
    final isDeposit = _selectedPaymentType == 'deposit';
    final hasExistingDeposit = (widget.sourceDocument?.totalDeposited ?? 0) > 0;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final successColor = theme.colorScheme.primary;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: successColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                loc.success.toUpperCase(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hasExistingDeposit
                    ? loc.additionalDepositSubmitted
                    : isDeposit
                        ? loc.depositSubmitted
                        : loc.paymentSubmitted,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: successColor,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      // Navigator.pop(context);
                      Navigator.pop(context, true);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: Text(
                          loc.ok.toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle(FinancialDocument? doc, AppLocalizations loc) {
    if (doc == null) return loc.paymentType;
    if (doc.totalDeposited > 0) return loc.addDeposit;
    return loc.paymentType;
  }

  List<PaymentType> _getPaymentTypesToShow(
      FinancialDocument? doc, AppLocalizations loc) {
    final allTypes = PaymentTypeUIManager.getPaymentTypes(loc);
    if (doc == null) return allTypes;
    if (doc.totalDeposited > 0)
      return [allTypes.firstWhere((type) => type.id == 'deposit')];
    return allTypes.where((type) => type.id != 'installment').toList();
  }
}
